
import Foundation
import CoreData

enum OperationType {
    case backend
    case database
}

class LoadNotesOperation: AsyncOperation {
    private(set) var loadedFrom: OperationType?
    private let notebook: FileNotebook
    private var loadFromBackend: LoadNotesBackendOperation
    private let backendQueue: OperationQueue
    private(set) var loadedNotes: [String: Note]?
    private(set) var currentGist: GistDownload?
    
    init(notebook: FileNotebook,
         backendQueue: OperationQueue,
         dbQueue: OperationQueue,
         token: String?,
         currentGist: GistDownload?,
         backgroundContext: NSManagedObjectContext) {
        
        self.notebook = notebook
        self.backendQueue = backendQueue
        let loadFromDB = LoadNotesDBOperation(fileNotebook: notebook, backgroundContext: backgroundContext)
        loadFromBackend = LoadNotesBackendOperation(notes: notebook.notes, token: token, currentGist: currentGist)

        super.init()
        
        loadFromBackend.completionBlock = { [weak self] in
            guard let self = self else { return }
            switch self.loadFromBackend.result {
            case .success(let notes):
                self.loadedNotes = notes
                self.currentGist = self.loadFromBackend.currentGist
                self.loadedFrom = .backend
                self.finish()
            case .failure:
                self.loadedFrom = .database
                dbQueue.addOperation(loadFromDB)
            case .none:
                self.loadedFrom = .database
                dbQueue.addOperation(loadFromDB)
            }
        }
        loadFromDB.completionBlock = { [weak self] in
            guard let self = self else { return }
            self.loadedNotes = loadFromDB.result
            self.finish()
        }//
    }

    override func main() {
        backendQueue.addOperation(loadFromBackend)
    }
}
