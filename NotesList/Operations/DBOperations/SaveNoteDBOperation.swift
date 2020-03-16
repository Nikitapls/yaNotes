import Foundation
import CoreData

class SaveNoteDBOperation: BaseDBOperation {
    private let note: Note

    init(note: Note,fileNotebook: FileNotebook, context: NSManagedObjectContext, backgroundContext: NSManagedObjectContext) {
        self.note = note
        super.init(notebook: fileNotebook, context: context, backgroundContext: backgroundContext)
    }
    
    override func main() {
//        notebook.add(note)
//        do {
//            try notebook.saveToFile()
//        } catch {
//            print("saveToFileError: \(error.localizedDescription)")
//        }
//        finish()
        addNote(note: note)
        notebook.add(note)
    }
    
    func addNote(note: Note) {
        DispatchQueue.global(qos: .userInitiated).async {
            [weak self] in
            guard let self = self else { return }
            let noteEntity = NoteEntity(context: self.backgroundContext)
            noteEntity.color = note.color.toHex()
            noteEntity.content = note.content
            noteEntity.creationDate = note.creationDate
            noteEntity.importance = note.impotance.rawValue
            noteEntity.selfDestructionDate = note.selfDestructionDate
            noteEntity.title = note.title
            noteEntity.uid = note.uid
            
            self.backgroundContext.performAndWait {
                do {
                    try self.backgroundContext.save()
                } catch { print(error.localizedDescription) }
            }
        }
    }
}
