//
//  FeedCleepOpenBrowserController.swift
//  FeedCleeps
//
//  Created by Muhammad Noor on 10/08/23.
//

import UIKit
import WebKit
import KipasKipasShared

public class FeedCleepOpenBrowserController: UIViewController {
    
    var url: String!
    var urlReq: URLRequest!
    var isUrlRequest = false
    var isFullScreen: Bool!
    var showAction: Bool!

    public var onDismiss: (() -> Void)?
    
    private var webView: WKWebView! {
        didSet {
            webView.translatesAutoresizingMaskIntoConstraints = true
            webView.isOpaque = false
            webView.backgroundColor = .white
            webView.scrollView.backgroundColor = .white
            
            view.addSubview(webView)
            
            
            webView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0).isActive = true
            webView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 0).isActive = true
            webView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -45).isActive = true
            webView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: 0).isActive = true
        }
    }
    
    private var progressView: UIProgressView! {
        didSet {
            progressView.translatesAutoresizingMaskIntoConstraints = false
            
            view.addSubview(progressView)
            
            progressView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0).isActive = true
            webView.widthAnchor.constraint(equalToConstant: view.frame.width).isActive = true
            webView.heightAnchor.constraint(equalToConstant: 2).isActive = true
        }
    }
    
    private lazy var closeButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        
        button.setTitle("    Close", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .primary
        button.layer.cornerRadius = 20.0
        
        if let imageClose = UIImage(named: "iconCloseCircle") {
            button.setImage(.iconCloseWhite, for: .normal)
            button.imageEdgeInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 0)
            button.contentHorizontalAlignment = .left
            button.imageView?.contentMode = .scaleAspectFit
        }
        
        button.addTarget(self, action: #selector(actionCloseController), for: .touchUpInside)
        
        return button
    }()
    
    private lazy var actionBackView: UIView = {
        let image = UIImageView()
        image.image = UIImage(systemName: "chevron.left", withConfiguration: UIImage.SymbolConfiguration(weight: .medium))
        image.tintColor = .white
        image.contentMode = .scaleAspectFit
        
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .contentGrey
        view.clipsToBounds = true
        view.layer.cornerRadius = 20
        
        view.addSubview(image)
        image.anchors.width.equal(16)
        image.anchors.height.equal(18)
        image.anchors.center.align()
        
        return view
    }()
    
    private lazy var actionForwardView: UIView = {
        let image = UIImageView()
        image.image = UIImage(systemName: "chevron.right", withConfiguration: UIImage.SymbolConfiguration(weight: .medium))
        image.tintColor = .white
        image.contentMode = .scaleAspectFit
        
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .contentGrey
        view.clipsToBounds = true
        view.layer.cornerRadius = 20
        
        view.addSubview(image)
        image.anchors.width.equal(16)
        image.anchors.height.equal(18)
        image.anchors.center.align()
        
        return view
    }()
    
    private lazy var actionView: UIStackView = {
        let view = UIStackView(arrangedSubviews: [actionBackView, actionForwardView])
        view.translatesAutoresizingMaskIntoConstraints = false
        view.axis = .horizontal
        view.spacing = 8
        
        actionBackView.anchors.width.equal(58)
        actionBackView.anchors.height.equal(40)
        actionForwardView.anchors.width.equal(58)
        actionForwardView.anchors.height.equal(40)
        
        return view
    }()
    
    public convenience init(url: String, urlReq: URLRequest? = nil, title: String? = nil, isFullScreen: Bool? = false, showAction: Bool = false) {
        self.init(nibName:nil, bundle:nil)
        
        self.urlReq = urlReq
        self.title = title
        self.isFullScreen = isFullScreen
        self.showAction = showAction
        if url == "" {
            isUrlRequest = true
        }else{
            isUrlRequest = false
            self.url = url
        }
    }
    
    deinit {
        print("***** deinit !!!!! \(self)")
        webView.stopLoading()
    }

    
}

extension FeedCleepOpenBrowserController: UIGestureRecognizerDelegate {
    
    public override func loadView() {
        super.loadView()
        
        view.backgroundColor = .white
        
        let pref = WKPreferences()
        pref.javaScriptEnabled = true
        
        let config = WKWebViewConfiguration()
        config.preferences = pref
        config.applicationNameForUserAgent = "Safari"
        webView = WKWebView(frame: view.frame, configuration: config)
        progressView = UIProgressView(progressViewStyle: .default)
        if self.navigationController?.isNavigationBarHidden ?? false {
            self.navigationController?.setNavigationBarHidden(false, animated: false)
        }
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
        self.navigationItem.hidesBackButton = true
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = true
        self.navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.barTintColor = .black
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }
    
    public override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        tabBarController?.tabBar.isHidden = false
        
        webView.removeFromSuperview()
        progressView.removeFromSuperview()
        
        onDismiss?()
    }

    public override func viewWillDisappear(_ animated: Bool) {
        webView.navigationDelegate = nil
        webView.scrollView.delegate = nil

    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        
        setupAction()
        
        if isFullScreen != nil {
            if(isFullScreen) {
                self.navigationController?.isNavigationBarHidden = true
                addButtonClose()
            }
        }

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
    
    @objc func back() {
        self.dismiss(animated: true, completion: nil)
        self.onDismiss?()
    }
    
    public override var preferredStatusBarStyle: UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }
    
    func addButtonClose(){
        view.addSubview(closeButton)
        closeButton.anchors.width.equal(90)
        closeButton.anchors.height.equal(40)
        closeButton.anchors.right.equal(view.anchors.right, constant: -8)
        closeButton.anchors.centerY.equal(actionView.anchors.centerY)
    }

    @objc
    func actionCloseController() {
        self.dismiss(animated: true, completion: nil)
        self.onDismiss?()
    }
}

// MARK: - Action
private extension FeedCleepOpenBrowserController {
    func setupAction() {
        actionView.isHidden = !showAction
        view.addSubview(actionView)
        actionView.anchors.left.equal(view.anchors.left, constant: 8)
        actionView.anchors.bottom.equal(view.safeAreaLayoutGuide.anchors.bottom, constant: -8)
//        actionBackView.onTap(action: actionBack)
//        actionForwardView.onTap(action: actionForward)
        
        actionBackView.onTap { [weak self] in
            guard let self = self else { return }
            self.actionBack()
        }
        
        actionForwardView.onTap {  [weak self] in
            guard let self = self else { return }
            self.actionForward()
        }
        
    }
    
    func actionBack() {
        guard webView.canGoBack else { return }
        webView.goBack()
    }
    
    func actionForward() {
        guard webView.canGoForward else { return }
        webView.goForward()
    }
}

extension FeedCleepOpenBrowserController: WKNavigationDelegate, WKUIDelegate {
    
    public func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
        decisionHandler(.allow)
    }
    
    public func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        decisionHandler(.allow)
    }
    
}


