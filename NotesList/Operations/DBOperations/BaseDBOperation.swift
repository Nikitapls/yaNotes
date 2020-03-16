import Foundation
import CoreData

class BaseDBOperation: AsyncOperation {
    let notebook: FileNotebook
    var context: NSManagedObjectContext
    var backgroundContext: NSManagedObjectContext
    
    init(notebook: FileNotebook, context: NSManagedObjectContext, backgroundContext: NSManagedObjectContext) {
        self.notebook = notebook
        self.context = context
        self.backgroundContext = backgroundContext
        super.init()
    }
}
