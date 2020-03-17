import Foundation
import CoreData
class SaveNoteOperation: AsyncOperation {
    private let saveToDb: SaveNoteDBOperation
    private let dbQueue: OperationQueue
    private(set) var currentGist: GistDownload?
    private(set) var result: Bool? = false
    
    init(note: Note,
         notebook: FileNotebook,
         backendQueue: OperationQueue,
         dbQueue: OperationQueue,
         token: String?,
         currentGist: GistDownload?,
         backgroundContext: NSManagedObjectContext) {
        
        saveToDb = SaveNoteDBOperation(note: note, fileNotebook: notebook, backgroundContext: backgroundContext)
        self.dbQueue = dbQueue
        
        super.init()
        self.currentGist = currentGist
        saveToDb.completionBlock = {
            let saveToBackend = SaveNotesBackendOperation(notes: notebook.notes, token: token, currentGist: currentGist)
            saveToBackend.completionBlock = {
                switch saveToBackend.result {
                case .success:
                    self.result = true
                case .failure:
                    self.result = false
                case .none:
                    self.result = false
                }
                self.currentGist = saveToBackend.currentGist
                self.finish()
            }
            backendQueue.addOperation(saveToBackend)
        }
    }
    
    override func main() {
        dbQueue.addOperation(saveToDb)
    }
}
