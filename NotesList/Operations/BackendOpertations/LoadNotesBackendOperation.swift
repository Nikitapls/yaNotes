import Foundation

enum LoadNotesBackendResult {
  case success([String: Note])
  case failure(NetworkError)
}

class LoadNotesBackendOperation: BaseBackendOperation {

    var result: LoadNotesBackendResult? //= .failure(.unreachable)
    var rawUrl: String?
    
    init(notes: [String: Note], token: String?) {
        super.init()
        self.token = token
    }
    
    override func main() {
       // result = .failure(.unreachable)
        updateData()
        
        //wriaitUntilFinished()
        //finish()
    }
    
    func updateData() {
        let stringUrl = "https://api.github.com/gists"
//        let fileName = "ios-course-notes-db"
        //let token = "26151f23b63e588415729feb76658d125e61075d"
        let components = URLComponents(string: stringUrl)
        guard let url = components?.url else {
            self.finish()
            return
        }
        var request = URLRequest(url: url)
        guard let token = token else {
            result = .failure(.unreachable)
            self.finish()
            return
        }
        request.setValue("token \(token)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "GET"
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard let data = data else {
                self.finish()
                return
            }
            guard let gistArr = try? JSONDecoder().decode([GistDownload].self, from: data) else {
                print("Error while parsing data")
                self.finish()
                return
            }
            guard let index = gistArr.firstIndex(where: {
                if ($0.files.firstIndex(where: {
                    if $0.key == self.fileName {
                        return true
                    }
                    return false
                }) != nil) {
                    return true
                } else { return false }
            }) else {
                print("no")
                self.finish()
                return
            }
           // print(gistArr[index].files[self.fileName]?.rawUrl)
            self.rawUrl = gistArr[index].files[self.fileName]?.rawUrl
            self.notesFromGistDownload(gist: gistArr[index])
        }
        task.resume()
    }
    
    func notesFromGistDownload(gist: GistDownload) {
        guard let urlPath = gist.files[self.fileName]?.rawUrl,
        let url = URL(string: urlPath) else {
            self.finish()
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard let data = data else { self.finish(); return }
            let dictData = try? JSONSerialization.jsonObject(with: data, options: [])
            if let dictData = dictData as? Dictionary<String, Dictionary<String,Any>> {
                var dictInput = [String: Note]()
                for (key, value) in dictData {
                    dictInput[key] = Note.parse(json: value)
                }
                self.result = .success(dictInput)
                self.finish()
            } else {
                self.result = .failure(.unreachable)
                self.finish()
            }
        }
        task.resume()
    }
}
