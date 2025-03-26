//
//  KKDefaultWebViewController.swift
//  KipasKipasShared
//
//  Created by DENAZMI on 22/07/24.
//

import UIKit
import WebKit

public class KKDefaultWebViewController: UIViewController, NavigationAppearance {
    
    private lazy var webView: WKWebView = {
        let view = WKWebView()
        view.navigationDelegate = self
        return view
    }()
    
    let url: String

    public override func viewDidLoad() {
        super.viewDidLoad()
        overrideUserInterfaceStyle = .light
        setupNavigationBar(title: "", backIndicator: .iconChevronLeft)
        
        let urlRequest = URLRequest(url: URL(string: url)!)
        webView.load(urlRequest)
    }
    
    public init(url: String) {
        self.url = url
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func loadView() {
        view = webView
    }
}

extension KKDefaultWebViewController: WKNavigationDelegate {}
