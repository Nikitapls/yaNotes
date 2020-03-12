
import Foundation

class RemoveNoteOperation: AsyncOperation {
    
    private var removeFromDb: RemoveNoteDBOperation
    private let dbQueue: OperationQueue
    private(set) var result: Bool? = false
    
    init(note: Note,
    notebook: FileNotebook,
    backendQueue: OperationQueue,
    dbQueue: OperationQueue,
    token: String?,
    currentGist: GistDownload?) {

        self.dbQueue = dbQueue
        removeFromDb = RemoveNoteDBOperation(note: note, fileNotebook: notebook)
        super.init()
        
        removeFromDb.completionBlock = {
            let removeFromBackend = SaveNotesBackendOperation(notes: notebook.notes, token: token, currentGist: currentGist)
            removeFromBackend.completionBlock = { [weak self] in
                guard let self = self else { return }
                switch removeFromBackend.result {
                case .success:
                    self.result = true
                case .failure(.unreachable):
                    self.result = false
                case .none:
                    self.result = false
                }
                self.finish()
            }
            backendQueue.addOperation(removeFromBackend)
        }
        
        
    }
    
    override func main() {
        dbQueue.addOperation(removeFromDb)
    }
}
