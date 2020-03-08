import Foundation

enum NetworkError {
    case unreachable
}

enum SaveNotesBackendResult {
    case success
    case failure(NetworkError)
}

class SaveNotesBackendOperation: BaseBackendOperation {
    var result: SaveNotesBackendResult?
    var rawUrl: String?
    var notes: [String: Note]
    //private let fileName = "ios-course-notes-db"
    
    init(notes: [String: Note], token: String, rawUrl: String?) {
        self.rawUrl = rawUrl
        self.notes = notes
        super.init()
        self.token = token
    }
    
    override func main() {
        result = .failure(.unreachable)
        finish()
    }
    
    func uploadGist() {
        
    }
    
    func postGist(str: String) {
        let stringUrl = "https://api.github.com/gists"
        guard let token = token else {
            result = .failure(.unreachable)
            return
        }
        let components = URLComponents(string: stringUrl)
        var dictJson = [String: Any]()
        for (uid, value) in notes {
            dictJson[uid] = value.json
        }
        let jsdata = try? JSONSerialization.data(withJSONObject: dictJson, options: [])
        
        let gist = GistLoad(files: [fileName :GistFileLoad(content: jsdata)])
        let jsonEncoder = JSONEncoder()
        do {
            let jsonData = try jsonEncoder.encode(gist)
            let url = components?.url
            var request = URLRequest(url: url!)
            request.setValue("token \(token)", forHTTPHeaderField: "Authorization")
            request.httpMethod = "POST"
            request.httpBody = jsonData
            let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
                if let response = response as? HTTPURLResponse {
                  switch response.statusCode {
                    case 200..<300:
                        print("ok")
                    default:
                        print(response.statusCode)
                    }
                }
            }
            task.resume()
        } catch {}
    }
}
