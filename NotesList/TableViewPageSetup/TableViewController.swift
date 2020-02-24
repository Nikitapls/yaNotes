

import UIKit

class TableViewController: UIViewController {
    @IBOutlet weak var tableViewField: UITableView!
    var fileNotebook = FileNotebook()
    var notes: [Note]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Заметки"
        
        do {
            try fileNotebook.loadFromFile()

        } catch {
            print(error.localizedDescription)
        }
        
        if fileNotebook.dict.count == 0 { //add test value if needed
            fileNotebook.add(Note(uid: "sad", title: "titleNote", content: "noteContent", color: .red, impotance: Impotance.unimpotant, selfDestructionDate: nil)) }
        
        notes = Array(fileNotebook.dict.values)
        
        tableViewField.register(UINib(nibName: "NoteTableViewCell", bundle: nil),
                           forCellReuseIdentifier: "note")
        self.tableViewField.dataSource = self
        self.tableViewField.delegate = self
        self.tableViewField.allowsMultipleSelectionDuringEditing = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        do {
            try fileNotebook.saveToFile()
        } catch {
            print(error.localizedDescription)
        }
        super.viewWillDisappear(animated)
    }
    
    @IBAction func addButtonClicked(_ sender: UIBarButtonItem) {
        tableViewField.beginUpdates()
        let note = Note(title: "", content: "", impotance: Impotance.usual)
               
        fileNotebook.add(note)
        notes?.append(note)
        
        let cell = tableViewField?.dequeueReusableCell(withIdentifier: "note") as! NoteTableViewCell
        cell.colorField?.backgroundColor = note.color
        cell.titleLabel?.text = note.title
        cell.contentLabel?.text = note.content
        
        tableViewField.insertRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
        tableViewField.endUpdates()
        tableViewField.reloadData()
        let indexPath = IndexPath(row: (notes?.count ?? 1) - 1, section: 0)
        print(indexPath.row)
        tableView(self.tableViewField, didSelectRowAt: indexPath)
    }
    
    @IBOutlet weak var addButton: UIBarButtonItem!
    @IBOutlet weak var editButton: UIBarButtonItem!
    
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
//        let sourceViewController = unwindSegue.source as? ColorPickerViewController
//        // Use data from the view controller which initiated the unwind segue
//        guard _ = sourceViewController.newNote? else {}
        if let controller = unwindSegue.source as? ColorPickerViewController {
            guard let newNote = controller.newNote else {
                return
            }
           // if let
            if let note = notes?.popLast() {
                fileNotebook.remove(with: note.uid)
            }
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
            fileNotebook.remove(with: note.uid)
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
        
        tableView.beginUpdates()
        tableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .fade)
        tableView.endUpdates()
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
            print(indexPath)
            guard let note = notes?[indexPath.row] else {return}
            controller.note = note
            controller.addNewNote = { [weak self] (note: Note) in
                self?.fileNotebook.add(note)
                self?.notes?.append(note)
            }
            controller.deleteOldNote = { [weak self] (note: Note) in
                self?.fileNotebook.remove(with: note.uid)
                
                guard var notes = self?.notes else { return }
                if let index = notes.firstIndex(of: note) {
                    notes.remove(at: index)
                }
                self?.notes = notes
            }
        }
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableViewField.reloadData()
    }
}
