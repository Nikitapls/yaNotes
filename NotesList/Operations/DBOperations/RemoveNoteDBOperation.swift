import Foundation
import CoreData

class RemoveNoteDBOperation: BaseDBOperation {
    private var note: Note
    private var noteEntityArr: [NoteEntity]?
    
    init(note: Note,fileNotebook: FileNotebook, context: NSManagedObjectContext) {
        self.note = note
        super.init(notebook: fileNotebook, context: context)
    }
    
    override func main() {
        notebook.remove(with: note.uid)
        fetchData()
        if let fetchedNotes = noteEntityArr, fetchedNotes.count == 1 {
            backgroundContext.delete(fetchedNotes[0])
            self.backgroundContext.performAndWait {
                do {
                    try self.backgroundContext.save()
                } catch { print(error.localizedDescription) }
            }
        }
        finish()
    }
    
    func fetchData() {
        let request = NSFetchRequest<NoteEntity>(entityName: "NoteEntity")
        request.predicate = NSPredicate(format: "uid = %@", note.uid)
        do {
            noteEntityArr = try backgroundContext.fetch(request)
        } catch { print(error.localizedDescription) }
    }
}
