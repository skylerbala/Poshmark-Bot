//
//  ViewController.swift
//  Poshmark WebView
//
//  Created by Skyler Bala on 8/16/18.
//  Copyright © 2018 SkylerBala. All rights reserved.
//

import UIKit
import WebKit

class MainVC: UIViewController, WKNavigationDelegate {
    
    var webView: WKWebView!
    var scriptStart: Bool = false
    var funcOrder: Int = 0
    var userProfileLinks: [String] = []
    var currLinkCounter: Int = 0
    
    var startScriptButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        webViewSetup()
        setupNavigationBarItems()
        
        view.addSubview(webView)
        addConstraints()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        webView.loadUrl(string: "https://poshmark.com/login")
    }
    
    private func setupNavigationBarItems() {
        startScriptButton = UIButton(type: UIButtonType.system)
        startScriptButton.setTitle("Start Script", for: UIControlState.normal)
        startScriptButton.frame = CGRect(x: 0, y: 0, width: 100, height: 50)
        startScriptButton.addTarget(self, action: #selector(startScriptButtonAction(_:)), for: UIControlEvents.touchUpInside)
        view.addSubview(startScriptButton)
        
    }
    
    @objc private func startScriptButtonAction(_ sender: UIButton?) {
        scriptStart = true
        funcOrder = 0
        currLinkCounter = 0
        webView.loadUrl(string: "https://poshmark.com/feed")
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == #keyPath(WKWebView.isLoading) {
            if funcOrder == 0 && !webView.isLoading && scriptStart {
                webView.evaluateJavaScript("p.getUserProfiles()") { (data, error) in
                    self.webView.loadUrl(string: self.userProfileLinks[self.currLinkCounter])
                    self.funcOrder += 1
                }
            }
            else if funcOrder == 1 && !webView.isLoading && scriptStart {
                webView.evaluateJavaScript("p.getFollowLink().click()")
                funcOrder += 1
            }
            else if funcOrder == 2 && !webView.isLoading && scriptStart {
                webView.evaluateJavaScript("p.scroll()")
            }
        }
    }
    
    private func webViewSetup() {
        let config = WKWebViewConfiguration()
        let contentController = WKUserContentController()
        config.userContentController = contentController

        // Get Script
        guard let scriptPath = Bundle.main.path(forResource: "script", ofType: "js"), let scriptSource = try? String(contentsOfFile: scriptPath) else { return }
        let script = WKUserScript(source: scriptSource, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
        
        // Add Scripts
        contentController.addUserScript(script)
        
        // Add ScriptMessageHandlers
        contentController.add(self, name: "nextUser")
        contentController.add(self, name: "userProfileLinks")
        contentController.add(self, name: "reset")
        
        // Create WebView
        webView = WKWebView(frame: .zero, configuration: config)
        
        // Add Observer
        webView.addObserver(self, forKeyPath: #keyPath(WKWebView.isLoading), options: .new, context: nil)
    }
    
    
    private func addConstraints() {
        let layoutGuide = view.safeAreaLayoutGuide
        
        // WebView                  
        webView.leadingAnchor.constraint(equalTo: layoutGuide.leadingAnchor).isActive = true
        webView.trailingAnchor.constraint(equalTo: layoutGuide.trailingAnchor).isActive = true
        webView.topAnchor.constraint(equalTo: layoutGuide.topAnchor, constant: 100).isActive = true
        webView.bottomAnchor.constraint(equalTo: layoutGuide.bottomAnchor).isActive = true
        webView.translatesAutoresizingMaskIntoConstraints = false
    }

}

extension MainVC: WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if message.name == "nextUser", let messageBody = message.body as? String {
            currLinkCounter += 1
            funcOrder = 1
            webView.loadUrl(string: userProfileLinks[currLinkCounter])
        }
        
        if message.name == "userProfileLinks", let messageBody = message.body as? [String] {
            userProfileLinks = messageBody
        }
        
        if message.name == "reset", let messageBody = message.body as? String {
            startScriptButton.sendActions(for: .touchUpInside)
        }
    }
}

extension WKWebView {
    func loadUrl(string: String) {
        if let url = URL(string: string) {
            load(URLRequest(url: url))
        }
    }
}


