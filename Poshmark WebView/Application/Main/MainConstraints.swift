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
        view.addSubview(webView)
        
        let layoutGuide = view.safeAreaLayoutGuide
        
        webView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            webView.leadingAnchor.constraint(equalTo: layoutGuide.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: layoutGuide.trailingAnchor),
            webView.topAnchor.constraint(equalTo: layoutGuide.topAnchor),
            webView.bottomAnchor.constraint(equalTo: layoutGuide.bottomAnchor)
        ])
    }
}
