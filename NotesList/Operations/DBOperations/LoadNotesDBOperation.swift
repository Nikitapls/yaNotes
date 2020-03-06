
import Foundation

class LoadNotesDBOperation: BaseDBOperation {
    var result: [String: Note]?
    
    init(fileNotebook: FileNotebook) {
        super.init(notebook: fileNotebook)
    }
    
    override func main() {
        result = notebook.notes
        finish()
    }
}
