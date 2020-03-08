import Foundation

class BaseBackendOperation: AsyncOperation {
    let fileName = "ios-course-notes-db"
    var token: String?
    
    override init() {
        super.init()
    }
}
