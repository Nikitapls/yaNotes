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
    var notes: [String: Note]
    
    init(notes: [String: Note], token: String?, currentGist: GistDownload?) {
        self.notes = notes
        super.init()
        self.currentGist = currentGist
        self.token = token
    }
    
    override func main() {
        result = .failure(.unreachable)
        if let gist = currentGist {
            uploadGist(gist: gist)
        } else {
            postGist()
        }
    }
    
    func uploadGist(gist: GistDownload) {
        let id = gist.gistId
        let stringUrl = "https://api.github.com/gists/\(id)"
        guard let token = token,
            let url = URL(string: stringUrl) else {
            result = .failure(.unreachable)
            self.finish()
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        
        let jsonEncoder = JSONEncoder()
        let gistLoad = notebookJson()
        let jsonData = try? jsonEncoder.encode(gistLoad)
        request.httpBody = jsonData
        request.setValue("token \(token)", forHTTPHeaderField: "Authorization")
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let response = response as? HTTPURLResponse {
                print("PatchAnswer\(response.statusCode)")
            }
            guard let data = data,
                let gist = try? JSONDecoder().decode(GistDownload.self, from: data) else {
                print("Error while parsing data")
                self.finish()
                return
            }
            self.currentGist = gist
            self.result = .success
            self.finish()
        }
        task.resume()
    }
    
    func notebookJson () -> GistLoad {
        var dictJson = [String: [String: String]]()
        for (uid,note) in notes {
            dictJson[uid] = note.jsonStringString
        }
        
        let jsdata = try? JSONSerialization.data(withJSONObject: dictJson, options: [])
        let str = String(decoding: jsdata!, as: UTF8.self)
        let gist = GistLoad(files: [fileName: GistFileLoad(content: str)])
        return gist
    }
    
    func postGist() {
        let stringUrl = "https://api.github.com/gists"
        guard let token = token else {
            result = .failure(.unreachable)
            self.finish()
            return
        }
        let components = URLComponents(string: stringUrl)
        let gist = notebookJson()
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
                    print(response.statusCode)
                }
                guard let data = data,
                    let gist = try? JSONDecoder().decode(GistDownload.self, from: data) else {
                    print("Error while parsing data")
                    self.finish()
                    return
                }
                self.currentGist = gist
                self.result = .success
                self.finish()//
            }
            task.resume()
        } catch {}
    }
}
