

import UIKit

class TableViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    var fileNotebook = FileNotebook()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fileNotebook.add(Note(uid: "sad", title: "titleNote", content: "noteContent", color: .red, impotance: Impotance.unimpotant, selfDestructionDate: nil))
        tableView.register(UINib(nibName: "NoteTableViewCell", bundle: nil),
                           forCellReuseIdentifier: "note")
        self.tableView.dataSource = self
        self.tableView.delegate = self
    }
    
}

extension TableViewController: UITableViewDataSource, UITableViewDelegate {
    
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
        performSegue(withIdentifier: "ShowNoteEditor", sender: indexPath)
    }
    
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let controller = segue.destination as? ColorPickerViewController,
                 segue.identifier == "ShowNoteEditor", let indexPath = sender as? IndexPath{
            controller.note = Array(fileNotebook.dict.values)[indexPath.row]
            controller.addNewNote = { [weak self] (note: Note) in
                self?.fileNotebook.add(note)
                print("add note with \(note.title)")
            }
            controller.deleteOldNote = { [weak self] (note: Note) in
                self?.fileNotebook.remove(with: note.uid)
                print("remove note with \(note.title)")
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
}
