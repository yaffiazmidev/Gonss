//
//  BrowserController.swift
//  Persada
//
//  Created by movan on 27/07/20.
//  Copyright © 2020 Muhammad Noor. All rights reserved.
//

import UIKit
import WebKit
import KipasKipasShared

class AlternativeBrowserController: UIViewController {
    
    var isUrlRequest = false
    
    private var webView: WKWebView! {
        didSet {
            webView.translatesAutoresizingMaskIntoConstraints = true
            webView.isOpaque = false
            webView.backgroundColor = .white
            webView.scrollView.backgroundColor = .white
            
            view.addSubview(webView)
            
            webView.fillSuperview(padding: UIEdgeInsets(top: 0, left: 0, bottom: 45, right: 0))
        }
    }
    
    private var progressView: UIProgressView! {
        didSet {
            progressView.translatesAutoresizingMaskIntoConstraints = false
            
            view.addSubview(progressView)
            
            progressView.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: nil, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: view.frame.width, height: 2)
        }
    }
    
    var url: String!
    var urlReq: URLRequest!
    
    convenience init(url: String, urlReq: URLRequest? = nil, title: String? = nil) {
        self.init(nibName:nil, bundle:nil)
        
        self.urlReq = urlReq
        self.title = title
        if url == "" {
            isUrlRequest = true
        }else{
            isUrlRequest = false
            self.url = url
        }
    }
    
}

extension AlternativeBrowserController: UIGestureRecognizerDelegate {
    
    override func loadView() {
        super.loadView()
        
        view.backgroundColor = .white
        
        let pref = WKPreferences()
        pref.javaScriptEnabled = true
        
        let config = WKWebViewConfiguration()
        config.preferences = pref
        config.applicationNameForUserAgent = "Safari"
        webView = WKWebView(frame: view.frame, configuration: config)
        progressView = UIProgressView(progressViewStyle: .default)
        self.navigationController?.showBarIfNecessary()
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
        
        let backButton = UIBarButtonItem(image: UIImage(named: .get(.arrowleft)), style: .plain, target: self, action: #selector(back))
        
        self.navigationItem.hidesBackButton = true
        self.navigationItem.leftBarButtonItem = backButton
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = true
        self.navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.barTintColor = .black
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        tabBarController?.tabBar.isHidden = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        webView.navigationDelegate = self
        webView.uiDelegate = self
        let value = webView.estimatedProgress
        let progress = Float(value)
        if progress == 1 {
            self.progressView.isHidden = true
        } else {
            self.progressView.isHidden = false
            self.progressView.progress = progress
        }
        print("URL Req : ", isUrlRequest)
        if isUrlRequest == false {
            webView.load(URLRequest(url: URL(string: url)!))
        }else{
            webView.load(urlReq)
        }
    }
    
    public override var preferredStatusBarStyle: UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }
    
    @objc func back(sender: UIBarButtonItem) {
        smartBack(animated: true)
    }
}

extension AlternativeBrowserController: WKNavigationDelegate, WKUIDelegate {
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
        decisionHandler(.allow)
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        decisionHandler(.allow)
    }
}
