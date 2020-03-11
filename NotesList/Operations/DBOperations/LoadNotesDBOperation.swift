
import Foundation

class LoadNotesDBOperation: BaseDBOperation {
    var result: [String: Note]?
    
    init(fileNotebook: FileNotebook) {
        super.init(notebook: fileNotebook)
    }
    
    override func main() {
        do {
            try notebook.loadFromFile()
            result = notebook.notes
        } catch {
            print("loadFromFileError: \(error.localizedDescription)")
            result = [String: Note]()
        }
        finish()
    }
}
