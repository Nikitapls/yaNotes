import Foundation

enum LoadNotesBackendResult {
  case success([String: Note])
  case failure(NetworkError)
}

class LoadNotesBackendOperation: BaseBackendOperation {

    var result: LoadNotesBackendResult? //= .failure(.unreachable)
    //var rawUrl: String?
    
    init(notes: [String: Note], token: String?, currentGist: GistDownload?) {
        super.init()
        self.currentGist = currentGist
        self.token = token
    }
    
    override func main() {
       // result = .failure(.unreachable)
        if currentGist == nil {
            print("currentGistNil nil")
            findRequest()
        } else {
            loadData()//tut
        }
        
        //wriaitUntilFinished()
        //finish()
    }
    
    func loadData() {
        guard let rawUrl = currentGist?.files[fileName]?.rawUrl else {
            self.finish()
            return
        }
        
        var request = URLRequest(url: URL(string: rawUrl)!)
        request.httpMethod = "GET"
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            //print(String(decoding: data!, as: UTF8.self))
            //self.result = .failure(.unreachable)
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
            //self.notesFromGistDownload(gist: gist)
        }
        task.resume()
        
    }
    
    func findRequest() {
        let stringUrl = "https://api.github.com/gists"
//        let fileName = "ios-course-notes-db"
        //let token = "26151f23b63e588415729feb76658d125e61075d"
        let components = URLComponents(string: stringUrl)
        guard let url = components?.url else {
            result = .failure(.unreachable)
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
                self.result = .failure(.unreachable)
                self.finish()
                return
            }
            guard let gistArr = try? JSONDecoder().decode([GistDownload].self, from: data) else {
                print("Error while parsing data")
                self.result = .failure(.unreachable)
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
                self.result = .failure(.unreachable)
                self.finish()
                return
            }
           // print(gistArr[index].files[self.fileName]?.rawUrl)
            self.currentGist = gistArr[index]
            self.notesFromGistDownload(gist: gistArr[index])
        }
        task.resume()
    }
    
    func notesFromGistDownload(gist: GistDownload) {
        
        guard let urlPath = gist.files[self.fileName]?.rawUrl,
        let url = URL(string: urlPath) else {
            self.result = .failure(.unreachable)
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
                return
            } else {
                self.result = .failure(.unreachable)
                self.finish()
                return
            }
            
    
        }
        task.resume()
    }
}
