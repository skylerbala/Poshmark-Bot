//
//  WKWebView+Additions.swift
//  Poshmark WebView
//
//  Created by Skyler Bala on 8/27/18.
//  Copyright © 2018 SkylerBala. All rights reserved.
//

import Foundation
import WebKit

extension WKWebView {
    func loadUrl(string: String) {
        if let url = URL(string: string) {
            load(URLRequest(url: url))
        }
    }
}
