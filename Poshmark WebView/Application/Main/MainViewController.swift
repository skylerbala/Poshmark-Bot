//
//  ViewController.swift
//  Poshmark WebView
//
//  Created by Skyler Bala on 8/16/18.
//  Copyright © 2018 SkylerBala. All rights reserved.
//

import UIKit
import WebKit

class MainViewController: UIViewController, WKNavigationDelegate {
    
    var webView: WKWebView!
    
    var isScriptActive: Bool = false
    var jsFuncStep: BotStep = BotStep.getUserProfileLinks
    var userProfileLinks: [String] = []
    var currUserLinkCounter: Int = 0
    
    var scriptActions: [UIAlertAction]!
    var scriptMenuAlertController: UIAlertController!
    
    let loginURL: String = "https://poshmark.com/login"
    let homeFeedURL: String = "https://poshmark.com/feed"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setWebView()
        
        setViews()
        setScriptMenu()
        
        setNavBar()
        
        webView.loadUrl(string: loginURL)
    }
    
    func setNavBar() {
        let scriptMenuBarButton = UIBarButtonItem(title: "Scripts", style: UIBarButtonItemStyle.plain, target: self, action: #selector(scriptMenuButtonAction))
        navigationItem.rightBarButtonItem = scriptMenuBarButton
    }
    
    @objc func scriptMenuButtonAction() {
        present(scriptMenuAlertController, animated: true, completion: nil)
    }
    
    func startScript() {
        isScriptActive = true
        jsFuncStep = .getUserProfileLinks
        webView.loadUrl(string: homeFeedURL)
        currUserLinkCounter = 0
    }
    
    func stopScript() {
        isScriptActive = false
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == #keyPath(WKWebView.isLoading) {
            if jsFuncStep == .getUserProfileLinks && !webView.isLoading && isScriptActive {
                webView.evaluateJavaScript("p.getUserProfileLinks()") { (data, error) in
                    self.webView.loadUrl(string: self.userProfileLinks[self.currUserLinkCounter])
                    self.jsFuncStep = .getFollowPageLinks
                }
            }
            else if jsFuncStep == .getFollowPageLinks && !webView.isLoading && isScriptActive {
                webView.evaluateJavaScript("p.getFollowPageLink().click()")
                jsFuncStep = .scrollAndLoad
            }
            else if jsFuncStep == .scrollAndLoad && !webView.isLoading && isScriptActive {
                webView.evaluateJavaScript("p.scrollAndLoad()")
            }
        }
    }
    
    
    func setWebView() {
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
    
    func setScriptMenu() {
        scriptMenuAlertController = UIAlertController(title: "Script Actions", message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
        let startAction = UIAlertAction(title: "Start", style: UIAlertActionStyle.default) { (action) in
            self.startScript()
        }
        let stopAction = UIAlertAction(title: "Stop", style: UIAlertActionStyle.default) { (action) in
            self.stopScript()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil)
        scriptMenuAlertController.addAction(startAction)
        scriptMenuAlertController.addAction(stopAction)
        scriptMenuAlertController.addAction(cancelAction)

    }
}

extension MainViewController: WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if message.name == "nextUser", let messageBody = message.body as? String {
            currUserLinkCounter += 1
            jsFuncStep = .getFollowPageLinks
            webView.loadUrl(string: userProfileLinks[currUserLinkCounter])
        }
        
        if message.name == "userProfileLinks", let messageBody = message.body as? [String] {
            userProfileLinks = messageBody
        }
        
        if message.name == "reset", let messageBody = message.body as? String {
            startScript()
        }
    }
}

enum BotStep: Int {
    case getUserProfileLinks = 0
    case getFollowPageLinks = 1
    case scrollAndLoad = 2
}


