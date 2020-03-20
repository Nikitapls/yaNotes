
import UIKit
import CoreData

class LoadNotesDBOperation: BaseDBOperation {
    var result: [String: Note]?
    var fetchedResultsController: NSFetchedResultsController<NoteEntity>?
    var noteEntityArr: [NoteEntity]?
    
    init(fileNotebook: FileNotebook, backgroundContext: NSManagedObjectContext) {
        super.init(notebook: fileNotebook, backgroundContext: backgroundContext)
    }
    
    func fetchData() {
        let request = NSFetchRequest<NoteEntity>(entityName: "NoteEntity")
        do {
            noteEntityArr = try backgroundContext.fetch(request)
        } catch { print(error.localizedDescription) }
    }
    
    override func main() {
        fetchData()
        var resultDict = [String: Note]()
        guard let noteEntities = noteEntityArr else {
            finish()
            result = resultDict
            return
        }
        noteEntities.forEach({ (noteEntity) in
            if let note = noteFromNoteEntity(noteEntity: noteEntity) {
                resultDict[note.uid] = note
            }
        })
        result = resultDict
        finish()
    }
    
}
