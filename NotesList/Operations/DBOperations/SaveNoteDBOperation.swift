import Foundation
import CoreData

class SaveNoteDBOperation: BaseDBOperation {
    private let note: Note

    init(note: Note,fileNotebook: FileNotebook, context: NSManagedObjectContext, backgroundContext: NSManagedObjectContext) {
        self.note = note
        super.init(notebook: fileNotebook, context: context, backgroundContext: backgroundContext)
    }
    
    override func main() {
        notebook.add(note)
        do {
            try notebook.saveToFile()
        } catch {
            print("saveToFileError: \(error.localizedDescription)")
        }
        finish()
    }
    
    func addNote(note: Note) {
        DispatchQueue.global(qos: .userInitiated).async {
            [weak self] in
            guard let self = self else { return }
            let noteEntity = NoteEntity(context: self.backgroundContext)
            
            self.backgroundContext.performAndWait {
                do {
                    try self.backgroundContext.save()
                } catch { print(error.localizedDescription) }
                
            }
        }
    }
}
