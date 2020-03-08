import Foundation

enum LoadNotesBackendResult {
  case success([String: Note])
  case failure(NetworkError)
}

class LoadNotesBackendOperation: BaseBackendOperation {

    var result: LoadNotesBackendResult?
    
    init(notes: [String: Note], token: String) {
        super.init()
        self.token = token
    }
    
    override func main() {
        updateData()
       // waitUntilFinished()
        finish()
    }
    
    func updateData() {
        let stringUrl = "https://api.github.com/gists"
//        let fileName = "ios-course-notes-db"
        //let token = "26151f23b63e588415729feb76658d125e61075d"
        let components = URLComponents(string: stringUrl)
        guard let url = components?.url else { return }
        var request = URLRequest(url: url)
        guard let token = token else { return }
        request.setValue("token \(token)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "GET"
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard let data = data else { return }
            guard let gistArr = try? JSONDecoder().decode([GistDownload].self, from: data) else {
                print("Error while parsing data")
                return
            }
            guard let index = gistArr.firstIndex(where: {
                if ($0.files.firstIndex(where: {
                    print($0.key)
                    if $0.key == self.fileName {
                        return true
                    }
                    return false
                }) != nil) {
                    return true
                } else { return false }
            }) else { print("no");return }
            //print(gistArr[index].files[self.fileName]?.rawUrl)
            self.notesFromGistDownload(gist: gistArr[index])
        }
        task.resume()
    }
    
    func notesFromGistDownload(gist: GistDownload) {
        guard let urlPath = gist.files[self.fileName]?.rawUrl,
        let url = URL(string: urlPath) else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard let data = data else { return }
            let dictData = try? JSONSerialization.jsonObject(with: data, options: [])
            if let dictData = dictData as? Dictionary<String, Dictionary<String,Any>> {
                var dictInput = [String: Note]()
                for (key, value) in dictData {
                    dictInput[key] = Note.parse(json: value)
                }
                self.result = .success(dictInput)
            }
        }
        task.resume()
    }
}
