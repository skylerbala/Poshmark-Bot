//
//  MainVC+Constraints.swift
//  Poshmark WebView
//
//  Created by Skyler Bala on 8/27/18.
//  Copyright © 2018 SkylerBala. All rights reserved.
//

import Foundation
import UIKit

extension MainViewController {
    
    
    
    func setViews() {
        let layoutGuide = view.safeAreaLayoutGuide

        view.addSubview(webView)
        view.addSubview(statusView)
        statusView.addSubview(followCountLabel)
        
        
        webView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            webView.leadingAnchor.constraint(equalTo: layoutGuide.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: layoutGuide.trailingAnchor),
            webView.topAnchor.constraint(equalTo: statusView.bottomAnchor),
            webView.bottomAnchor.constraint(equalTo: layoutGuide.bottomAnchor)
        ])
        
        statusView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            statusView.leadingAnchor.constraint(equalTo: layoutGuide.leadingAnchor),
            statusView.trailingAnchor.constraint(equalTo: layoutGuide.trailingAnchor),
            statusView.topAnchor.constraint(equalTo: layoutGuide.topAnchor),
            statusView.heightAnchor.constraint(equalToConstant: 30)
        ])
        
        followCountLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            followCountLabel.leadingAnchor.constraint(equalTo: layoutGuide.leadingAnchor, constant: 5),
            followCountLabel.centerYAnchor.constraint(equalTo: statusView.centerYAnchor),
        ])
    }
}
