
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
        var resultDict = [String: Note]()
        fetchedResultsController?.fetchedObjects?.forEach({ (noteEntity) in
            if let note = noteFromNoteEntity(noteEntity: noteEntity) {
                resultDict[note.uid] = note
            }
        })
        self.result = resultDict
        finish()
    }
    
    func noteFromNoteEntity(noteEntity: NoteEntity) -> Note? {
        if let uid = noteEntity.uid,
            let title = noteEntity.title,
            let content = noteEntity.content,
            let colorHex = noteEntity.color,
            let color = UIColor.hexStringToUIColor(hex: colorHex),
            let importanceHex = noteEntity.importance,
            let importance = Impotance.init(rawValue: importanceHex),
            let creationDate = noteEntity.creationDate {
            return Note(uid: uid, title: title, content: content, color: color, impotance: importance, selfDestructionDate: noteEntity.selfDestructionDate, creationDate: creationDate)
        } else { return nil }
    }
}
