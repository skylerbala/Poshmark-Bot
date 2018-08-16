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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        webViewSetup()
        setupNavigationBarItems()
        
        view.addSubview(webView)
        
        let layoutGuide = view.safeAreaLayoutGuide
        
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.leadingAnchor.constraint(equalTo: layoutGuide.leadingAnchor).isActive = true
        webView.trailingAnchor.constraint(equalTo: layoutGuide.trailingAnchor).isActive = true
        webView.topAnchor.constraint(equalTo: layoutGuide.topAnchor, constant: 100).isActive = true
        webView.bottomAnchor.constraint(equalTo: layoutGuide.bottomAnchor).isActive = true
        
        if let url = URL(string: "https://www.poshmark.com") {
            webView.load(URLRequest(url: url))
            webView.allowsBackForwardNavigationGestures = true
        }
    }
    
    private func setupNavigationBarItems() {
        let startScriptButton = UIButton(type: UIButtonType.system)
        startScriptButton.setTitle("Start Script", for: UIControlState.normal)
        startScriptButton.frame = CGRect(x: 0, y: 0, width: 100, height: 50)
        startScriptButton.addTarget(self, action: #selector(startScriptButtonAction(_:)), for: UIControlEvents.touchUpInside)
        view.addSubview(startScriptButton)
        
    }
    
    @objc private func startScriptButtonAction(_ sender: UIButton?) {
        
    }
    
    func webViewSetup() {
        let contentController = WKUserContentController()
        contentController.add(self, name: "test")
        
        guard let scriptPath = Bundle.main.path(forResource: "script", ofType: "js"), let scriptSource = try? String(contentsOfFile: scriptPath) else { return }
        
        let script = WKUserScript(source: scriptSource, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
        
        contentController.addUserScript(script)
        
        let config = WKWebViewConfiguration()
        config.userContentController = contentController
        
        webView = WKWebView(frame: .zero, configuration: config)
    }

}

extension MainVC: WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if message.name == "test", let messageBody = message.body as? String {
            print(messageBody)
        }
    }
    
    
}



