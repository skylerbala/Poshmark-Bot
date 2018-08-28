//
//  ViewController.swift
//  Poshmark WebView
//
//  Created by Skyler Bala on 8/16/18.
//  Copyright © 2018 SkylerBala. All rights reserved.
//

import UIKit
import WebKit
import UserNotifications


class MainViewController: UIViewController, WKNavigationDelegate {
    
    var webView: WKWebView!
    var isWebViewDisplayed: Bool = true
    
    let statusView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black
        return view
    }()
    
    let followCountLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.white
        label.text = "Follows Count: 0"
        return label
    }()
    
    var isScriptActive: Bool = false
    var jsFuncStep: BotStep = BotStep.getUserProfileLinks
    var userProfileLinks: [String] = []
    var currUserLinkCounter: Int = 0
    var followsCount: Int = 0
    
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
        let scriptMenuBarButton = UIBarButtonItem(title: "Scripts", style: .plain, target: self, action: #selector(scriptMenuButtonAction))
        navigationItem.rightBarButtonItem = scriptMenuBarButton
        
        let webViewDisplayButton = UIBarButtonItem(title: "Show Browser", style: .plain, target: self, action: #selector(toggleWebViewDisplay))
        navigationItem.leftBarButtonItem = webViewDisplayButton
    }
    
    @objc func toggleWebViewDisplay() {
        if isWebViewDisplayed {
            navigationItem.leftBarButtonItem?.title = "Hide Browser"
            webView.isHidden = true
            isWebViewDisplayed = false
        }
        else {
            navigationItem.leftBarButtonItem?.title = "Show Browser"
            webView.isHidden = false
            isWebViewDisplayed = true
        }
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
        contentController.add(self, name: "followCountIncrement")
        
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
            let notificationCenter = UNUserNotificationCenter.current()
            let content = UNMutableNotificationContent()
            content.title = "Complete reCaptcha"
            content.subtitle = "Log-In and complete the required reCaptcha to continue"
            let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
            notificationCenter.add(request, withCompletionHandler: { (error) in
            })
        }
        
        if message.name == "followCountIncrement", let messageBody = message.body as? Int {
            followsCount = messageBody
            followCountLabel.text = "Follow Count: \(followsCount)"
        }
    }
}

enum BotStep: Int {
    case getUserProfileLinks = 0
    case getFollowPageLinks = 1
    case scrollAndLoad = 2
}


