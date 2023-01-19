//
//  WebView.swift
//  RSS
//
//  Created by Shyam Kumar on 1/11/23.
//

import SwiftUI
import WebKit

struct WebViewSafari: UIViewRepresentable {
    var url: URL
    
    func makeUIView(context: Context) -> WKWebView {
        return WKWebView()
    }
    
    func updateUIView(_ webView: WKWebView, context: Context) {
        let request = URLRequest(url: url)
        webView.load(request)
    }
}
