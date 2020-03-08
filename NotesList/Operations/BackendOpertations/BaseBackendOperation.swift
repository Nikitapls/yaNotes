import Foundation

class BaseBackendOperation: AsyncOperation {
    
    var token: String?
    
    override init() {
        super.init()
    }
}
