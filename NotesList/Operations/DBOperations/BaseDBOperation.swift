import UIKit
import CoreData

class BaseDBOperation: AsyncOperation {
    let notebook: FileNotebook
    var backgroundContext: NSManagedObjectContext
    
    init(notebook: FileNotebook, context: NSManagedObjectContext) {
        self.notebook = notebook
        let privateContext = NSManagedObjectContext.init(concurrencyType: .privateQueueConcurrencyType)
        privateContext.persistentStoreCoordinator = context.persistentStoreCoordinator
        self.backgroundContext = privateContext
        super.init()
    }
    
    func noteFromNoteEntity(noteEntity: NoteEntity) -> Note? {
        if let uid = noteEntity.uid,
            let title = noteEntity.title,
            let content = noteEntity.content,
            let colorHex = noteEntity.colorHex,
            let color = UIColor.hexStringToUIColor(hex: colorHex),
            let importanceHex = noteEntity.importance,
            let importance = Impotance.init(rawValue: importanceHex),
            let creationDate = noteEntity.creationDate {
            return Note(uid: uid, title: title, content: content, color: color, impotance: importance, selfDestructionDate: noteEntity.selfDestructionDate, creationDate: creationDate)
        } else { return nil }
    }
}
