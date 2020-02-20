

import UIKit

class TableViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    
    var fileNotebook = FileNotebook()
 //   var categories = RecipeCategory.allRecipes
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fileNotebook.add(Note(uid: "sad", title: "titleNote", content: "noteConten_____________________________________________________________________________________________________________________________t", color: .red, impotance: Impotance.unimpotant, selfDestructionDate: nil))
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
    
//    func numberOfSections(in tableView: UITableView) -> Int {
//        return fileNotebook.dict.count
////        return categories.count
//    }
//
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
////        return categories[section].recipes.count
//    }
//
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let note = Array(fileNotebook.dict.values)[indexPath.row]
        let noteViewController = ColorPickerViewController()
        performSegue(withIdentifier: "ShowNoteEditor", sender: nil)
        
    }
    
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let controller = segue.destination as? ColorPickerViewController,
                 segue.identifier == "ShowNoteEditor" {
            controller.note = Array(fileNotebook.dict.values)[0]//bug
        }
    }
    
    @IBAction func unwindToTableViewController(_ unwindSegue: UIStoryboardSegue) {
        let sourceViewController = unwindSegue.source
        if let controller = sourceViewController as? ColorPickerViewController {
            print("yeqp")
        }
        print(sourceViewController)
    }
        
//        let noteViewController = storyboard?.instantiateViewController(identifier: "noteEditorId") as! ColorPickerViewController
        //navigationController?.pushViewController(noteViewController, animated: true)
//        let recipe = categories[indexPath.section].recipes[indexPath.row]
//        print("Did tap recipe with title: \(recipe.title)")
        // showRecipeDetailsViewController(recipe)
    
//
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
////        let cell = tableView.dequeueReusableCell(withIdentifier: "recipe", for: indexPath) as! RecipeTableViewCell
////        let recipe = categories[indexPath.section].recipes[indexPath.row]
////        cell.recipeTitleLabel?.text = recipe.title
////        cell.recipeIngredientsLabel?.text = recipe.ingresients
////        cell.iconImageView?.image = recipe.photo
////
////        tableView.beginUpdates()
////        let indexPaths = [IndexPath(row: 1, section: 0),
////                          IndexPath(row: 5, section: 0)]
////        tableView.insertRows(at: indexPaths, with: .fade)
////        return cell
//    }
//
//    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
// //       return categories[section].title
//    }
//
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return UITableView.automaticDimension
//    }
//
//    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
//        return 120
//    }
//
//    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
//        return .delete
//    }
//
//    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
// //       categories[indexPath.section].recipes.remove(at: indexPath.row)
//  //      tableView.deleteRows(at: [indexPath], with: .left)
//    }
}
