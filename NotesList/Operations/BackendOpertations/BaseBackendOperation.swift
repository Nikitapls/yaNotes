import Foundation

class BaseBackendOperation: AsyncOperation {
    let fileName = "ios-course-notes-db"
    var token: String?
    var currentGist: GistDownload?
    
    override init() {
        super.init()
    }
}
