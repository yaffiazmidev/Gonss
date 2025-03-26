//
//  FloatingLinkWebViewController.swift
//  KipasKipas
//
//  Created by Rahmat Trinanda Pramudya Amar on 11/04/23.
//  Copyright © 2023 Koanba. All rights reserved.
//

import Foundation
import UIKit
import WebKit

class FloatingLinkWebViewController: UIViewController, UIGestureRecognizerDelegate {
    private let mainView: FloatingLinkWebView!
    private let url: String
    
    var whenDismiss: (() -> Void)?
    
    init(_ url: String){
        self.url = url
        self.mainView = FloatingLinkWebView()
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let closeButton = UIButton(type: .custom)
        closeButton.setImage(UIImage(named: .get(.iconCloseWhite)), for: .normal)
        closeButton.addTarget(self, action: #selector(back), for: .touchUpInside)
        closeButton.frame = CGRect(x: 0, y: 0, width: 16, height: 16)
        let closeItem = UIBarButtonItem(customView: closeButton)
        self.navigationItem.leftBarButtonItem = closeItem
        
        navigationController?.setNavigationBarHidden(false, animated: false)
        navigationController?.navigationBar.backgroundColor = .contentGrey
    }
    
    override func loadView() {
        super.loadView()
        view = mainView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.hideKeyboardWhenTappedAround()
        navigationController?.interactivePopGestureRecognizer?.delegate = self
        mainView.webView.navigationDelegate = self
        
        let request = URLRequest(url: URL(string: self.url)!)
        mainView.webView.load(request)
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.navigationBar.backgroundColor = nil
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        whenDismiss?()
    }
    
    @objc private func back() {
        navigationController?.popViewController(animated: true)
    }
}

extension FloatingLinkWebViewController: AlertDisplayer {
    private func displayAlertFailure(_ errorMessage: String){
        let action = UIAlertAction(title: .get(.ok), style: .default){ _ in
            self.back()
        }
        self.displayAlert(with: .get(.failed), message: errorMessage, actions: [action])
    }
}

extension FloatingLinkWebViewController: WKNavigationDelegate{
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        navigationController?.navigationBar.backgroundColor = .contentGrey
        mainView.loadingIndicator.stopAnimating()
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        navigationController?.navigationBar.backgroundColor = .contentGrey
        mainView.loadingIndicator.stopAnimating()
        displayAlertFailure("Gagal memuat halaman.\n\(error.getErrorMessage())")
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        mainView.loadingIndicator.startAnimating()
    }
    
}
