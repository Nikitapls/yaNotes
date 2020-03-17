
import Foundation
import CoreData
class RemoveNoteOperation: AsyncOperation {
    
    private var removeFromDb: RemoveNoteDBOperation
    private let dbQueue: OperationQueue
    private(set) var result: Bool? = false
    private(set) var currentGist: GistDownload?
    
    init(note: Note,
    notebook: FileNotebook,
    backendQueue: OperationQueue,
    dbQueue: OperationQueue,
    token: String?,
    currentGist: GistDownload?,
    backgroundContext: NSManagedObjectContext) {

        self.dbQueue = dbQueue
        removeFromDb = RemoveNoteDBOperation(note: note, fileNotebook: notebook, backgroundContext: backgroundContext)
        super.init()
        self.currentGist = currentGist
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
                self.currentGist = removeFromBackend.currentGist
                self.finish()
            }
            backendQueue.addOperation(removeFromBackend)
        }
        
        
    }
    
    override func main() {
        dbQueue.addOperation(removeFromDb)
    }
}
