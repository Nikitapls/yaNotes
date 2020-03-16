
import UIKit
import CoreData

class LoadNotesDBOperation: BaseDBOperation {
    var result: [String: Note]?
    var fetchedResultsController: NSFetchedResultsController<NoteEntity>?
    
    init(fileNotebook: FileNotebook, context: NSManagedObjectContext, backgroundContext: NSManagedObjectContext) {
        super.init(notebook: fileNotebook, context: context, backgroundContext: backgroundContext)
    }
    
    func setupFetchedResultsControler(for context: NSManagedObjectContext) {
        let request = NSFetchRequest<NoteEntity>(entityName: "NoteEntity")
        let sortByCreationDate = NSSortDescriptor(key: "creationDate", ascending: true, comparator: { // comparator function
            id1, id2 in
            if let lhs = id1 as? Date, let rhs = id2 as? Date {
                if lhs < rhs { return .orderedAscending }
                if lhs > rhs { return .orderedDescending }
                return .orderedSame
            }
            print("error Sort descriptor \(id1),\(id2)")
            return .orderedSame
        })
        request.sortDescriptors = [sortByCreationDate]
        fetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
    }
    
    func fetchData() {
        do {
            try fetchedResultsController?.performFetch()
        } catch { print(error) }
    }
    
    override func main() {
//        do {
//            try notebook.loadFromFile()
//            result = notebook.notes
//        } catch {
//            print("loadFromFileError: \(error.localizedDescription)")
//            result = [String: Note]()
//        }
//        finish()
        setupFetchedResultsControler(for: backgroundContext)
        fetchData()
        
    }
    
    func noteFromNoteEntity(note: NoteEntity) ->Note {
        note.
        //Impotance.init(rawValue: note.importance)
        return Note(uid: note.uid, title: note.title, content: note.content, color: <#T##UIColor?#>, impotance: , selfDestructionDate: <#T##Date?#>, creationDate: <#T##Date#>)
    }
}
