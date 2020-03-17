
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
        let sortByCreationDate = NSSortDescriptor(key: "creationDate", ascending: true)
        request.sortDescriptors = [sortByCreationDate]
        fetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        print(Thread.current)
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
    
}
