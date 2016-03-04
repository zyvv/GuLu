//
//  WebViewController.swift
//  GuLu
//
//  Created by 张洋威 on 16/2/20.
//  Copyright © 2016年 YangWei Zhang. All rights reserved.
//

import UIKit
import WebKit

class WebViewController: UIViewController, WKNavigationDelegate {

    var webView: WKWebView = WKWebView(frame: CGRectZero)
    var url: String = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configViewController()
        self.webView.frame = self.view.bounds
        self.view.addSubview(self.webView)
        self.webView.loadRequest(NSURLRequest(URL: NSURL(string: url)!))
        self.webView.navigationDelegate = self;
        GLNetworkActivity().addGLNetworkActivityCount(true)
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        webView.addObserver(self, forKeyPath: "title", options: .New, context: nil)
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        webView.removeObserver(self, forKeyPath: "title", context: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if (keyPath == "title") {
            title = webView.title
        }
    }
    
    func webView(webView: WKWebView, didFinishNavigation navigation: WKNavigation!) {
        GLNetworkActivity().addGLNetworkActivityCount(false)
    }
    
    func webView(webView: WKWebView, didFailNavigation navigation: WKNavigation!, withError error: NSError) {
        GLNetworkActivity().addGLNetworkActivityCount(false)
    }

}
