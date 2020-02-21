

import UIKit

class TableViewController: UIViewController {
    @IBOutlet weak var tableViewField: UITableView!
    var fileNotebook = FileNotebook()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Заметки"
        fileNotebook.add(Note(uid: "sad", title: "titleNote", content: "noteContent", color: .red, impotance: Impotance.unimpotant, selfDestructionDate: nil))
        tableViewField.register(UINib(nibName: "NoteTableViewCell", bundle: nil),
                           forCellReuseIdentifier: "note")
        self.tableViewField.dataSource = self
        self.tableViewField.delegate = self
        self.tableViewField.allowsMultipleSelectionDuringEditing = false
    }
    
    @IBAction func addButtonClicked(_ sender: UIBarButtonItem) {
        let note = Note(title: "", content: "", impotance: Impotance.usual)
        fileNotebook.add(note)
        let cell = tableViewField?.dequeueReusableCell(withIdentifier: "note") as! NoteTableViewCell
        cell.colorField?.backgroundColor = note.color
        cell.titleLabel?.text = note.title
        cell.contentLabel?.text = note.content
        
        tableViewField.beginUpdates()
        tableViewField.insertRows(at: [IndexPath(row: 0, section: 0)], with: .fade)
        tableViewField.endUpdates()
        
        tableView(self.tableViewField, didSelectRowAt: IndexPath(row: 0, section: 0))
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

}

extension TableViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return isEditing
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let note = Array(fileNotebook.dict.values)[indexPath.row]
            fileNotebook.remove(with: note.uid)
            tableView.reloadData()
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fileNotebook.dict.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "note", for: indexPath) as! NoteTableViewCell
        let note = Array(fileNotebook.dict.values)[indexPath.row]
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
                 segue.identifier == "ShowNoteEditor", let indexPath = sender as? IndexPath{
            controller.note = Array(fileNotebook.dict.values)[indexPath.row]
            controller.addNewNote = { [weak self] (note: Note) in
                self?.fileNotebook.add(note)
            }
            controller.deleteOldNote = { [weak self] (note: Note) in
                self?.fileNotebook.remove(with: note.uid)
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableViewField.reloadData()
    }
}
