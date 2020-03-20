import Foundation
import CoreData

class SaveNoteDBOperation: BaseDBOperation {
    private let note: Note

    init(note: Note,fileNotebook: FileNotebook, backgroundContext: NSManagedObjectContext) {
        self.note = note
        super.init(notebook: fileNotebook, backgroundContext: backgroundContext)
    }
    
    override func main() {
        addNote(note: note)
        if notebook.notes[note.uid] != note {
            notebook.add(note)
        }
        if backgroundContext.hasChanges {
            backgroundContext.perform {
                do {
                    try self.backgroundContext.save()
                } catch { print(error.localizedDescription) }
            }
        }
        print("\(note.title) saved")
        finish()
    }
    
    func addNote(note: Note) {
        let noteEntity = NoteEntity(context: self.backgroundContext)
        noteEntity.colorHex = note.color.toHex()
        noteEntity.content = note.content
        noteEntity.creationDate = note.creationDate
        noteEntity.importance = note.impotance.rawValue
        noteEntity.selfDestructionDate = note.selfDestructionDate
        noteEntity.title = note.title
        noteEntity.uid = note.uid
    }
}
