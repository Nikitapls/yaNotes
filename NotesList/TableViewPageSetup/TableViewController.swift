

import UIKit

class TableViewController: UIViewController {
    
    let backendQueue = OperationQueue()
    let dbQueue = OperationQueue()
    let commonQueue = OperationQueue()
    
    @IBOutlet weak var tableViewField: UITableView!
    var fileNotebook = FileNotebook()
    var notes: [Note]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Заметки"
        
//        do {
//            try fileNotebook.loadFromFile()
//
//        } catch {
//            print(error.localizedDescription)
//        }
        
        notes = Array(fileNotebook.notes.values)
        
        tableViewField.register(UINib(nibName: "NoteTableViewCell", bundle: nil),
                           forCellReuseIdentifier: "note")
        self.tableViewField.dataSource = self
        self.tableViewField.delegate = self
        self.tableViewField.allowsMultipleSelectionDuringEditing = false
    }
    
    func addLoadNotesOperation() {
        let loadOperation = LoadNotesOperation(notebook: fileNotebook, backendQueue: backendQueue, dbQueue: dbQueue)
        loadOperation.completionBlock = {
            if let loadNotesResult = loadOperation.notesLoadResult {
                self.fileNotebook.replaceNotes(notes: loadNotesResult)
                var newNotes: [Note] = Array(self.fileNotebook.notes.values)
                newNotes.sort(by: { (lhs: Note, rhs: Note) -> Bool in
                    return lhs.creationDate > rhs.creationDate
                    })
                self.notes = newNotes
            }
        }
        commonQueue.addOperation(loadOperation)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        addLoadNotesOperation()
        tableViewField.reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
//        do {
//            try fileNotebook.saveToFile()
////            print("Dissapear: notes:count")
////            print(fileNotebook.notes.count)
//        } catch {
//            print(error.localizedDescription)
//        }
        super.viewWillDisappear(animated)
    }
    
    func addSaveOperationToQueue(note: Note) {
        let saveNoteOperation = SaveNoteOperation(note: note, notebook: self.fileNotebook, backendQueue: backendQueue, dbQueue: dbQueue)
        commonQueue.addOperation(saveNoteOperation)
    }
    
    func addRemoveNoteOperationToQueue(note: Note) {
        let removeNoteOperation = RemoveNoteOperation(note: note, notebook: fileNotebook, backendQueue: backendQueue, dbQueue: dbQueue)
        commonQueue.addOperation(removeNoteOperation)
    }
    
    @IBOutlet weak var addButton: UIBarButtonItem!
    @IBOutlet weak var editButton: UIBarButtonItem!
    
    @IBAction func addButtonClicked(_ sender: UIBarButtonItem) {
        let note = Note(title: "", content: "", impotance: Impotance.usual)
        tableViewField.beginUpdates()
        addSaveOperationToQueue(note: note)
        //notes?.append(note)
        addLoadNotesOperation()
        let cell = tableViewField?.dequeueReusableCell(withIdentifier: "note") as! NoteTableViewCell
        cell.colorField?.backgroundColor = note.color
        cell.titleLabel?.text = note.title
        cell.contentLabel?.text = note.content
        
        
        tableViewField.insertRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
        tableViewField.endUpdates()
        tableViewField.reloadData()
        let indexPath = IndexPath(row: (notes?.count ?? 1) - 1, section: 0)
        tableView(self.tableViewField, didSelectRowAt: indexPath)
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
            guard controller.newNote == nil else {
                return
            }
            if let note = notes?.popLast() {
                addRemoveNoteOperationToQueue(note: note)
            }//
            tableViewField.reloadData()
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
            let removeNoteOperation = RemoveNoteOperation(note: note, notebook: self.fileNotebook, backendQueue: backendQueue, dbQueue: dbQueue)
            commonQueue.addOperation(removeNoteOperation)
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
    
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let controller = segue.destination as? ColorPickerViewController,
                 segue.identifier == "ShowNoteEditor", let indexPath = sender as? IndexPath {
            guard let note = notes?[indexPath.row] else { return }
            controller.note = note
            controller.addNewNote = { [weak self] (note: Note) in
                self?.addSaveOperationToQueue(note: note)
//                self?.notes?.append(note)
            }
            controller.deleteOldNote = { [weak self] (note: Note) in
                self?.addRemoveNoteOperationToQueue(note: note)
//                guard var notes = self?.notes else { return }
//                if let index = notes.firstIndex(of: note) {
//                    notes.remove(at: index)
//                }
                //self?.notes = notes
            }
        }
    }
}
