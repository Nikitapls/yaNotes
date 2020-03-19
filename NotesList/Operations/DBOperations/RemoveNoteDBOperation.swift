import Foundation
import CoreData

class RemoveNoteDBOperation: BaseDBOperation {
    var fetchedResultsController: NSFetchedResultsController<NoteEntity>?
    private var note: Note
    //
    init(note: Note,fileNotebook: FileNotebook, backgroundContext: NSManagedObjectContext) {
        self.note = note
        super.init(notebook: fileNotebook, backgroundContext: backgroundContext)
    }
    
    override func main() {
        notebook.remove(with: note.uid)
        setupFetchedResultsControler(for: backgroundContext)
        fetchData()
        if let fetchedNotes = fetchedResultsController?.fetchedObjects,
            fetchedNotes.count == 1 {
            backgroundContext.delete(fetchedNotes[0])
            self.backgroundContext.performAndWait {
                do {
                    try self.backgroundContext.save()
                } catch { print(error.localizedDescription) }
            }
        }
        finish()
    }
    
    func setupFetchedResultsControler(for context: NSManagedObjectContext) {
        let request = NSFetchRequest<NoteEntity>(entityName: "NoteEntity")
        let sortByCreationDate = NSSortDescriptor(key: "creationDate", ascending: true)
        request.sortDescriptors = [sortByCreationDate]
        request.predicate = NSPredicate(format: "uid = %@", note.uid)
        //fetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
    }

    func fetchData() {
        do {
            try fetchedResultsController?.performFetch()
        } catch { print(error) }
    }
}
