import Foundation
import CoreData

class SaveNoteDBOperation: BaseDBOperation {
    let note: Note

    init(note: Note,fileNotebook: FileNotebook, context: NSManagedObjectContext) {
        self.note = note
        super.init(notebook: fileNotebook, context: context)
    }
    
    override func main() {
        addNote(note: note)
        if notebook.notes[note.uid] != note {
            notebook.add(note)
        }
        backgroundContext.perform {
            do {
                try self.backgroundContext.save()
            } catch { print(error.localizedDescription) }
        }
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
