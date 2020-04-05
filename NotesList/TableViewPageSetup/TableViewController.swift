

import UIKit
import CoreData

protocol LoadDataDelegate {
    func addLoadNotesOperation()
}

class TableViewController: UIViewController, LoadDataDelegate {
    
    let backendQueue = OperationQueue()
    let dbQueue = OperationQueue()
    let commonQueue = OperationQueue()
    let refreshQueue = OperationQueue()
    
    @IBOutlet weak var addButton: UIBarButtonItem!
    @IBOutlet weak var editButton: UIBarButtonItem!
    @IBOutlet weak var tableViewField: UITableView!
    var fileNotebook = FileNotebook()
    var notes: [Note]?
    var token: String?
    var currentGist: GistDownload?
    var context: NSManagedObjectContext!{
        didSet {
            print("backgroundSet")
            addLoadNotesOperation()
        }
    }
    
    @objc func refresh(refreshControl: UIRefreshControl) {
        
        let updateOperation = BlockOperation { [weak self] in
            guard let self = self else { return }
            self.commonQueue.waitUntilAllOperationsAreFinished()
            let loadOperation = self.loadOperationWithCompletionBlock()
            let endRefreshOperation = BlockOperation {
                OperationQueue.main.addOperation {
                    refreshControl.endRefreshing()
                }
            }
            endRefreshOperation.addDependency(loadOperation)
            self.commonQueue.addOperation(loadOperation)
            self.commonQueue.addOperation(endRefreshOperation)
        }
        refreshQueue.addOperation(updateOperation)
    }
    
    @objc func managedObjectContextDidSave(notification: Notification) {
        context.perform { [unowned self] in
            self.context.mergeChanges(fromContextDidSave: notification)
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(managedObjectContextDidSave(notification:)), name: NSNotification.Name.NSManagedObjectContextDidSave, object: nil)
        title = "Заметки"
        notes = Array(fileNotebook.notes.values)
        
        tableViewField.register(UINib(nibName: "NoteTableViewCell", bundle: nil),
                           forCellReuseIdentifier: "note")
        self.tableViewField.dataSource = self
        self.tableViewField.delegate = self
        self.tableViewField.allowsMultipleSelectionDuringEditing = false
        let refreshControl = UIRefreshControl()
       
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(refresh), for: UIControl.Event.valueChanged)
        tableViewField.refreshControl = refreshControl
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableViewField.reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    private func loadOperationWithCompletionBlock() -> LoadNotesOperation {
        let loadOperation = LoadNotesOperation(notebook: fileNotebook, backendQueue: backendQueue, dbQueue: dbQueue, token: token, currentGist: currentGist, context: context)
        loadOperation.completionBlock = { [weak self] in
            guard let self = self else { return }
            self.currentGist = loadOperation.currentGist
            if let loadNotesResult = loadOperation.loadedNotes {
                self.fileNotebook.replaceNotes(notes: loadNotesResult)
                var newNotes: [Note] = Array(self.fileNotebook.notes.values)
                newNotes.sort(by: { (lhs: Note, rhs: Note) -> Bool in
                    return lhs.creationDate > rhs.creationDate })
                self.notes = newNotes
        
                if loadOperation.loadedFrom == .backend {
                    self.clearCoreData()
                    self.addNotesToNSPersistentContainer(notes: newNotes)
                }
            }
            OperationQueue.main.addOperation {
                self.tableViewField.reloadData()
            }
        }
        return loadOperation
    }
    
    func addLoadNotesOperation() {
        let loadOperation = loadOperationWithCompletionBlock()
        commonQueue.addOperation(loadOperation)
    }
    
    func clearCoreData() {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "NoteEntity")
        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: request)
        batchDeleteRequest.resultType = .resultTypeObjectIDs
        do {
            try context.execute(batchDeleteRequest)
            try context.save()
        } catch {
          print (error)
        }
    }
    
    func addNotesToNSPersistentContainer(notes: [Note]) {
        for note in notes {
            let saveNoteDBOperation = SaveNoteDBOperation(note: note, fileNotebook: fileNotebook, context: context)
            saveNoteDBOperation.completionBlock = {
                print(saveNoteDBOperation.note.title)
            }
            dbQueue.addOperation(saveNoteDBOperation)
        }
    }
    
    func addSaveOperationToQueue(note: Note) {
        let saveNoteOperation = SaveNoteOperation(note: note, notebook: fileNotebook, backendQueue: backendQueue, dbQueue: dbQueue, token: token, currentGist: currentGist, context: context)
        saveNoteOperation.completionBlock = {
            self.currentGist = saveNoteOperation.currentGist
        }
        commonQueue.addOperation(saveNoteOperation)
        print(commonQueue.operationCount)
    }
    
    func addRemoveNoteOperationToQueue(note: Note) {
        let removeNoteOperation = RemoveNoteOperation(note: note, notebook: fileNotebook, backendQueue: backendQueue, dbQueue: dbQueue, token: token, currentGist: currentGist, context: context)
        removeNoteOperation.completionBlock = {
            self.currentGist = removeNoteOperation.currentGist
            OperationQueue.main.addOperation {
                self.tableViewField.reloadData()
            }
        }
        commonQueue.addOperation(removeNoteOperation)
    }
    
    @IBAction func addButtonClicked(_ sender: UIBarButtonItem) {
        if !isEditing {
            let note = Note(title: "", content: "", impotance: Impotance.usual)
            tableViewField.beginUpdates()
            notes?.insert(note, at: 0)
            tableViewField.insertRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
            tableViewField.endUpdates()
        
            performSegue(withIdentifier: "ShowNoteEditor", sender: IndexPath(row: 0, section: 0))
        }
    }
    @IBAction func authorizationButtonClicked(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "showAuthViewController", sender: nil)
    }

    @IBAction func editButtonClicked(_ sender: UIBarButtonItem) {
       isEditing = !isEditing
        if(isEditing) {
            editButton.title = "done"
            addButton.isEnabled = false
        } else {
            editButton.title = "edit"
            addButton.isEnabled = true
        }
    }
    
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let controller = segue.destination as? ColorPickerViewController,
                 segue.identifier == "ShowNoteEditor", let indexPath = sender as? IndexPath {
            guard let note = notes?[indexPath.row] else { return }
            controller.note = note
            controller.addNewNote = { [weak self] (note: Note) in
                self?.addSaveOperationToQueue(note: note)
                self?.notes?.remove(at: indexPath.row)
                self?.notes?.insert(note, at: 0)
            }
        } else if let controller = segue.destination as? AuthorizationViewController,
            segue.identifier == "showAuthViewController" {
            controller.delegate = self
            controller.loadDataDelegate = self
        }
    }

    @IBAction func unwindToTableViewController(_ unwindSegue: UIStoryboardSegue) {
        if let controller = unwindSegue.source as? ColorPickerViewController {
            guard controller.newNote == nil, let controllerNote = controller.note else {
                return
            }
            if let index = notes?.firstIndex(of: controllerNote),
                let note = notes?.remove(at: index) {
                addRemoveNoteOperationToQueue(note: note)
            }
        }
    }
}

extension TableViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return isEditing
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            guard var notes = notes else { return }
            let note = notes[indexPath.row]
            addRemoveNoteOperationToQueue(note: note)
            if let index = notes.firstIndex(of: note) {
                notes.remove(at: index)
            }
            self.notes = notes
            tableView.reloadData()
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notes?.count ?? 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "note", for: indexPath) as! NoteTableViewCell
        guard let note = notes?[indexPath.row] else {return cell}
        cell.colorField?.backgroundColor = note.color
        cell.titleLabel?.text = note.title
        cell.contentLabel?.text = note.content
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if !isEditing {
        performSegue(withIdentifier: "ShowNoteEditor", sender: indexPath)
        }
    }
    
}

extension TableViewController: AuthorizationViewControllerDelegate {
    func handleTokenChanged(token: String) {
        self.token = token
    }
}
