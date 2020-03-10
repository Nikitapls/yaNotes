
import Foundation

class LoadNotesOperation: AsyncOperation {

    private let notebook: FileNotebook
    private var loadFromBackend: LoadNotesBackendOperation
    private let backendQueue: OperationQueue
    private(set) var loadedNotes: [String: Note]?
    private(set) var currentGist: GistDownload?
    init(notebook: FileNotebook,
         backendQueue: OperationQueue,
         dbQueue: OperationQueue,
         token: String?,
         currentGist: GistDownload? ) {
        self.notebook = notebook
        self.backendQueue = backendQueue
        let loadFromDB = LoadNotesDBOperation(fileNotebook: notebook)
        loadFromBackend = LoadNotesBackendOperation(notes: notebook.notes, token: token, currentGist: currentGist)

        super.init()
        
        loadFromBackend.completionBlock = { [weak self] in
            guard let self = self else { return }
            switch self.loadFromBackend.result! {
            case .success(let notes):
                self.loadedNotes = notes
                self.currentGist = self.loadFromBackend.currentGist
                self.finish()
            case .failure:
                dbQueue.addOperation(loadFromDB)
            }
        }
        loadFromDB.completionBlock = { [weak self] in
            guard let self = self else { return }
            self.loadedNotes = loadFromDB.result
            self.finish()
        }
    }

    override func main() {
        backendQueue.addOperation(loadFromBackend)
    }
}
