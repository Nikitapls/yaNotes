//
//  AuthorizationViewController.swift
//  NotesList
//
//  Created by ios_school on 3/6/20.
//  Copyright © 2020 ios_school. All rights reserved.
//
import WebKit
import UIKit

protocol AuthorizationViewControllerDelegate: class {
    func handleTokenChanged(token: String)
}

enum PostKeys: String {
    case clientId = "client_id"
    case clientSecret = "client_secret"
    case code = "code"
}

struct AccessToken: Codable{
    let token: String
    enum CodingKeys: String, CodingKey {
        case token = "access_token"
    }
}

class AuthorizationViewController: UIViewController {
    private let clientId = "dc53c6ebf90d679280d2"
    private let clientSecret = "a53698aee79a290375f461e0c79a7b28651f2177"
    
    @IBOutlet weak var webView: WKWebView!
    var delegate: AuthorizationViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        webView.navigationDelegate = self
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadAuthorizationPage()
    }
    //let reditectUrl = "yanotes"
    private func loadAuthorizationPage() {
        let stringUrl = "https://github.com/login/oauth/authorize"
        var components = URLComponents(string: stringUrl)
        components?.queryItems = [URLQueryItem(name: "client_id", value: clientId)]
        let urlOptional = components?.url
        guard let url = urlOptional else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        webView.load(request)
        
    }
}


extension AuthorizationViewController: WKNavigationDelegate {

    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        defer {
            decisionHandler(.allow)
        }

        if let url = navigationAction.request.url {
            guard let components = URLComponents(string: url.absoluteString) else { return }
            if let token = components.queryItems?.first(where: { $0.name == "code" })?.value {
                postRequest(code: token)
            }
        }
    }
    
    private func postRequest(code: String) {
        var urlComponents = URLComponents(string: "https://github.com/login/oauth/access_token")
        urlComponents?.queryItems = [
            URLQueryItem(name: PostKeys.clientId.rawValue, value: clientId),
            URLQueryItem(name: PostKeys.clientSecret.rawValue, value: clientSecret),
            URLQueryItem(name: PostKeys.code.rawValue, value: code)
        ]
        if let url = urlComponents?.url {
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Accept")
            let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
                if let response = response as? HTTPURLResponse {
                    switch response.statusCode {
                    case 200..<300:
                        print("ok")
                    default:
                        print(response.statusCode)
                        return
                    }
                    guard let tokenData = data, let accessToken = try? JSONDecoder().decode(AccessToken.self, from: tokenData) else {
                        print("Error while parsing data")
                        return
                    }
                    self.delegate?.handleTokenChanged(token: accessToken.token)
                    DispatchQueue.main.async {
                        self.navigationController?.popViewController(animated: true)
                    }
                }
            }
            task.resume()
        }
    }
}
