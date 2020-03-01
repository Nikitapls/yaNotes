
import Foundation

class LoadNotesOperation: AsyncOperation {

    private let notebook: FileNotebook
    private var loadFromBackend: LoadNotesBackendOperation
    private let backendQueue: OperationQueue
    private(set) var notesLoadResult: [String: Note]?

    init(notebook: FileNotebook,
         backendQueue: OperationQueue,
         dbQueue: OperationQueue) {
        self.notebook = notebook
        self.backendQueue = backendQueue
        let loadFromDB = LoadNotesDBOperation(fileNotebook: notebook)
        loadFromBackend = LoadNotesBackendOperation(notes: notebook.notes)

        super.init()
        
        loadFromBackend.completionBlock = { [weak self] in
            guard let self = self else { return }
            switch self.loadFromBackend.result! {
            case .success(let notes):
                self.notesLoadResult = notes
                self.finish()
            case .failure:
                dbQueue.addOperation(loadFromDB)
            }
        }
        loadFromDB.completionBlock = { [weak self] in
            guard let self = self else { return }
            self.notesLoadResult = loadFromDB.result
            self.finish()
        }
    }

    override func main() {
        backendQueue.addOperation(loadFromBackend)
    }
}
