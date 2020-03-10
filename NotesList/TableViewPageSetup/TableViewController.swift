

import UIKit

class TableViewController: UIViewController {
    
    let backendQueue = OperationQueue()
    let dbQueue = OperationQueue()
    let commonQueue = OperationQueue()
    
    @IBOutlet weak var tableViewField: UITableView!
    var fileNotebook = FileNotebook()
    var notes: [Note]?
    private var first = true
    var token: String?
    var currentGist: GistDownload? {
        didSet {
            print("currentGist changed \(self.currentGist?.gistId ?? "nil")")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Заметки"
        notes = Array(fileNotebook.notes.values)
        
        tableViewField.register(UINib(nibName: "NoteTableViewCell", bundle: nil),
                           forCellReuseIdentifier: "note")
        self.tableViewField.dataSource = self
        self.tableViewField.delegate = self
        self.tableViewField.allowsMultipleSelectionDuringEditing = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //tableViewField.reloadData()
        super.viewWillAppear(animated)
        addLoadNotesOperation()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if first {
            performSegue(withIdentifier: "showAuthViewController", sender: nil)
            first = false
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        //addLoadNotesOperation()
    }
    
    func addLoadNotesOperation() {
        //guard let token = token else { return }
        let loadOperation = LoadNotesOperation(notebook: fileNotebook, backendQueue: backendQueue, dbQueue: dbQueue, token: token, currentGist: currentGist)
        loadOperation.completionBlock = {
            self.currentGist = loadOperation.currentGist
            if let loadNotesResult = loadOperation.loadedNotes {
                self.fileNotebook.replaceNotes(notes: loadNotesResult)
                var newNotes: [Note] = Array(self.fileNotebook.notes.values)
                newNotes.sort(by: { (lhs: Note, rhs: Note) -> Bool in
                    return lhs.creationDate > rhs.creationDate
                    })
                self.notes = newNotes
                //self.rawUrl = loadOperation.raw
            }
            print("endLoadNotesOperation")
            DispatchQueue.main.async {
                self.tableViewField.reloadData()
            }
        }
        commonQueue.addOperation(loadOperation)
    }
    
    func addSaveOperationToQueue(note: Note) {
        //guard let token = token else { return }
        let saveNoteOperation = SaveNoteOperation(note: note, notebook: self.fileNotebook, backendQueue: backendQueue, dbQueue: dbQueue, token: token, currentGist: currentGist)
        saveNoteOperation.completionBlock = {
            print("endSaveNotesOperation")
            self.currentGist = saveNoteOperation.currentGist
            //DispatchQueue.main.async {
                self.addLoadNotesOperation()
                //saself.tableViewField.reloadData()
            //}
        }
        commonQueue.addOperation(saveNoteOperation)
        print(commonQueue.operationCount)
    }
    
    func addRemoveNoteOperationToQueue(note: Note) {
        //guard let token = token else { return }
        let removeNoteOperation = RemoveNoteOperation(note: note, notebook: fileNotebook, backendQueue: backendQueue, dbQueue: dbQueue, token: token, currentGist: currentGist)
        removeNoteOperation.completionBlock = {
            print("endRemoveNotesOperation")
        }
        commonQueue.addOperation(removeNoteOperation)
    }
    
    @IBOutlet weak var addButton: UIBarButtonItem!
    @IBOutlet weak var editButton: UIBarButtonItem!
    
    @IBAction func addButtonClicked(_ sender: UIBarButtonItem) {
        let note = Note(title: "", content: "", impotance: Impotance.usual)
        tableViewField.beginUpdates()
        notes?.insert(note, at: 0)
        tableViewField.insertRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
        tableViewField.endUpdates()
        addSaveOperationToQueue(note: note)
        if !isEditing, let notesCount = notes?.count{
            performSegue(withIdentifier: "ShowNoteEditor", sender: IndexPath(row: 0, section: 0))
        }
       // addSaveOperationWhenAddButtonClicked(note: note)
    }
    /* следующая функция не используется, так скажем legacy*/
    func addSaveOperationWhenAddButtonClicked(note: Note) {
        let saveNoteOperation = SaveNoteOperation(note: note, notebook: self.fileNotebook, backendQueue: backendQueue, dbQueue: dbQueue, token: token, currentGist: currentGist)
        saveNoteOperation.completionBlock = {
            
            DispatchQueue.main.async {
                self.tableViewField.beginUpdates()
                //self.notes?.append(note)
                self.notes?.insert(note, at: 0)
                self.tableViewField.insertRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
                self.tableViewField.endUpdates()
                if !self.isEditing {
//                    self.performSegue(withIdentifier: "ShowNoteEditor", sender: IndexPath(row: notesCount - 1, section: 0))
                    self.performSegue(withIdentifier: "ShowNoteEditor", sender: IndexPath(row: 0, section: 0))

                }
                
                //saself.tableViewField.reloadData()
            }
            self.addLoadNotesOperation()
        }
        commonQueue.addOperation(saveNoteOperation)
        print(commonQueue.operationCount)
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
        //reloaddata when editin style = .delete?
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
        print("index = \(indexPath.row)")
       // guard indexPath.row < notes?.count else {return cell}
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
    
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let controller = segue.destination as? ColorPickerViewController,
                 segue.identifier == "ShowNoteEditor", let indexPath = sender as? IndexPath {
            guard let note = notes?[indexPath.row] else { return }
            controller.note = note
            controller.addNewNote = { [weak self] (note: Note) in
                self?.addSaveOperationToQueue(note: note)
                self?.notes?[indexPath.row] = note
            }
        } else if let controller = segue.destination as? AuthorizationViewController,
            segue.identifier == "showAuthViewController" {
            controller.delegate = self
        }
    }
}

extension TableViewController: AuthorizationViewControllerDelegate {
    func handleTokenChanged(token: String) {
        self.token = token
        print(token)
    }
}
