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
    
    var isFBOTActive: Bool = false
    var isCSBOTActive: Bool = false
    var jsFuncStep: Int = 0
    var links: [String] = []
    var currLinkCounter: Int = 0
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
    
    func startFBOT() {
        isFBOTActive = true
        jsFuncStep = 0
        webView.loadUrl(string: homeFeedURL)
        currLinkCounter = 0
    }
    
    func startCSBOT() {
        isCSBOTActive = true
        jsFuncStep = 0
        webView.loadUrl(string: homeFeedURL)
        currLinkCounter = 0
    }
    
    func stopFBOT() {
        isFBOTActive = false
    }
    
    func stopCSBOT() {
        isCSBOTActive = false
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == #keyPath(WKWebView.isLoading) {
            if jsFuncStep == 0 && !webView.isLoading && isFBOTActive {
                webView.evaluateJavaScript("FBOT.getUserProfileLinks()") { (data, error) in
                    self.webView.loadUrl(string: self.links[self.currLinkCounter])
                    self.jsFuncStep += 1
                }
            }
            else if jsFuncStep == 1 && !webView.isLoading && isFBOTActive {
                webView.evaluateJavaScript("FBOT.getFollowPageLink()")
                jsFuncStep += 1
            }
            else if jsFuncStep == 2 && !webView.isLoading && isFBOTActive {
                webView.evaluateJavaScript("FBOT.scroll()")
            }
            
            if jsFuncStep == 0 && !webView.isLoading && isCSBOTActive {
                webView.evaluateJavaScript("CSBOT.scroll()")
            }
            else if jsFuncStep == 1 && !webView.isLoading && isCSBOTActive {
                webView.evaluateJavaScript("CSBOT.commentShare()")
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
        contentController.add(self, name: "FBOTnextUser")
        contentController.add(self, name: "FBOTuserProfileLinks")
        contentController.add(self, name: "FBOTreset")
        contentController.add(self, name: "FBOTfollowCountIncrement")
        
        contentController.add(self, name: "CSBOTgetItemLinks")
        contentController.add(self, name: "CSBOTnext")
        
        // Create WebView
        webView = WKWebView(frame: .zero, configuration: config)
        
        // Add Observer
        webView.addObserver(self, forKeyPath: #keyPath(WKWebView.isLoading), options: .new, context: nil)
    }
    
    func setScriptMenu() {
        scriptMenuAlertController = UIAlertController(title: "Script Actions", message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
        let FBOT = UIAlertAction(title: "Start Follow Bot", style: UIAlertActionStyle.default) { (action) in
            self.startFBOT()
        }
        let CSBOT = UIAlertAction(title: "Start Comment Share Bot", style: UIAlertActionStyle.default) { (action) in
            self.startCSBOT()
        }
        let stopAction = UIAlertAction(title: "Stop All Bots", style: UIAlertActionStyle.default) { (action) in
            self.stopFBOT()
            self.stopCSBOT()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil)
        scriptMenuAlertController.addAction(FBOT)
        scriptMenuAlertController.addAction(CSBOT)
        scriptMenuAlertController.addAction(stopAction)
        scriptMenuAlertController.addAction(cancelAction)

    }
}

extension MainViewController: WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if message.name == "FBOTnextUser", let messageBody = message.body as? String {
            currLinkCounter += 1
            jsFuncStep = 1
            webView.loadUrl(string: links[currLinkCounter])
        }
        
        if message.name == "FBOTuserProfileLinks", let messageBody = message.body as? [String] {
            links = messageBody
        }
        
        if message.name == "FBOTreset", let messageBody = message.body as? String {
            let notificationCenter = UNUserNotificationCenter.current()
            let content = UNMutableNotificationContent()
            content.title = "Complete reCaptcha"
            content.subtitle = "Log-In and complete the required reCaptcha to continue"
            let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
            notificationCenter.add(request, withCompletionHandler: { (error) in
            })
        }
        
        
        
        if message.name == "CSBOTgetItemLinks", let messageBody = message.body as? [String] {
            links = messageBody
            jsFuncStep += 1
            webView.loadUrl(string: links[currLinkCounter])
        }
        
        if message.name == "CSBOTnext", let messageBody = message.body as? String {
            currLinkCounter += 1
            jsFuncStep = 1
            webView.loadUrl(string: links[currLinkCounter])
        }
        
        if message.name == "FBOTfollowCountIncrement", let messageBody = message.body as? Int {
            followsCount = messageBody
            followCountLabel.text = "Follow Count: \(followsCount)"
        }
    }
}


