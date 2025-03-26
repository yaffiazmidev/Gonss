//
//  KKWebViewController.swift
//  KipasKipasDirectMessageUI
//
//  Created by DENAZMI on 10/08/23.
//

import UIKit
import WebKit

class KKWebViewController: UIViewController {
    
    private lazy var webView: WKWebView = {
        let view = WKWebView()
        view.navigationDelegate = self
        return view
    }()
    
    let url: String

    override func viewDidLoad() {
        super.viewDidLoad()
        overrideUserInterfaceStyle = .light
        
        let urlRequest = URLRequest(url: URL(string: url)!)
        webView.load(urlRequest)
    }
    
    init(url: String) {
        self.url = url
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        view = webView
    }
}

extension KKWebViewController: WKNavigationDelegate {}
