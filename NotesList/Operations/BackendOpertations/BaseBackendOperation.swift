import Foundation

class BaseBackendOperation: AsyncOperation {
    let fileName = "ios-course-notes-db"
    var token: String?
    var currentGist: GistDownload? {
        didSet {
            print("currentGistBaseBAckendOperation changed on \(self.currentGist?.gistId ?? "nil")")
        }
    }
    
    override init() {
        super.init()
    }
}
