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
    //var rawUrl: String?
    var notes: [String: Note]
    //private let fileName = "ios-course-notes-db"
    
    init(notes: [String: Note], token: String?, rawUrl: String?) {
        self.notes = notes
        super.init()
        self.rawUrl = rawUrl
        self.token = token
    }
    
    override func main() {
        result = .failure(.unreachable)
        postGist()
        //waitUntilFinished()
        //finish()
    }
    
    func uploadGist() {
        
    }
    
    func postGist() {
        let stringUrl = "https://api.github.com/gists"
        guard let token = token else {
            result = .failure(.unreachable)
            self.finish()
            return
        }
        let components = URLComponents(string: stringUrl)
        var dictJson = [String: [String: String]]()
        
        for (uid,note) in notes {
            dictJson[uid] = note.jsonStringString
        }
        
        let jsdata = try? JSONSerialization.data(withJSONObject: dictJson, options: [])
        let str = String(decoding: jsdata!, as: UTF8.self)
//        print(str)
        let gist = GistLoad(files: [fileName: GistFileLoad(content: str)])
        let jsonEncoder = JSONEncoder()
        do {
            let jsonData = try jsonEncoder.encode(gist)
            let url = components?.url
            var request = URLRequest(url: url!)
            request.setValue("token \(token)", forHTTPHeaderField: "Authorization")
            request.httpMethod = "POST"
            request.httpBody = jsonData
            //let str = String(decoding: jsonData, as: UTF8.self)
            //print(str)
            let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
                if let response = response as? HTTPURLResponse {
                    print(response.statusCode)
                }
                self.finish()
            }
            task.resume()
        } catch {}
    }
}
