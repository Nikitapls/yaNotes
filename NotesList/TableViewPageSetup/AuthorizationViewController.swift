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
class AuthorizationViewController: UIViewController {
    
    @IBOutlet weak var webView: WKWebView!
    var delegate: AuthorizationViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadAuthorizationPage()
    }
    let reditectUrl = "yaNotes"
    private func loadAuthorizationPage() {
        let stringUrl = "https://github.com/login/oauth/authorize"
        var components = URLComponents(string: stringUrl)
        components?.queryItems = [URLQueryItem(name: "client_id", value: "dc53c6ebf90d679280d2"),
                                  URLQueryItem(name: "redirect_uri", value: reditectUrl)]
        let urlOptional = components?.url
        guard let url = urlOptional else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        webView.load(request)
        
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}


extension AuthorizationViewController: WKNavigationDelegate {

    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if let url = navigationAction.request.url, url.scheme == reditectUrl {
            //let targetString = url.absoluteString.replacingOccurrences(of: "#", with: "?")
            guard let components = URLComponents(string: url.absoluteString) else { return }

            if let token = components.queryItems?.first(where: { $0.name == "access_token" })?.value {
                delegate?.handleTokenChanged(token: token)
            }
            dismiss(animated: true, completion: nil)
        }
        defer {
            decisionHandler(.allow)
        }
    }
}
