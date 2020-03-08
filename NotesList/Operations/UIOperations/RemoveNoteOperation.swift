
import Foundation

class RemoveNoteOperation: AsyncOperation {
    
    private var removeFromBackend: SaveNotesBackendOperation
    private let backendQueue: OperationQueue
    private(set) var result: Bool? = false
    
    init(note: Note,
    notebook: FileNotebook,
    backendQueue: OperationQueue,
    dbQueue: OperationQueue,
    token: String) {

        self.backendQueue = backendQueue
        let removeFromDb = RemoveNoteDBOperation(note: note, fileNotebook: notebook)
        removeFromBackend = SaveNotesBackendOperation(notes: notebook.notes, token: token)
        super.init()
        
        removeFromBackend.completionBlock = { [weak self] in
            guard let self = self else { return }
            switch self.removeFromBackend.result! {
            case .success:
                    self.result = true
            case .failure(.unreachable):
                    self.result = false
            }
            dbQueue.addOperation(removeFromDb)
        }
        
        removeFromDb.completionBlock = { [weak self] in
        guard let self = self else { return }
            self.finish()
        }
    }
    
    override func main() {
        backendQueue.addOperation(removeFromBackend)
    }
}
