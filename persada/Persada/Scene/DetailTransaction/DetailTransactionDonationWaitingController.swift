//
//  DetailTransactionDonationWaitingController.swift
//  KipasKipas
//
//  Created by Rahmat Trinanda Pramudya Amar on 29/03/23.
//  Copyright © 2023 Koanba. All rights reserved.
//

import Foundation
import UIKit
import WebKit

class DetailTransactionDonationWaitingController: UIViewController, UIGestureRecognizerDelegate{
    private let mainView: DetailTransactionDonationWaitingView!
    
    var loader: RemoteDetailTransactionOrderLoader!
    private let orderId: String
    private var data: DetailTransactionOrderItem?
    
    init(_ orderId: String){
        self.orderId = orderId
        self.mainView = DetailTransactionDonationWaitingView()
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = true
        navigationController?.setNavigationBarHidden(true, animated: false)
        navigationController?.navigationBar.backgroundColor = .white
    }
    
    override func loadView() {
        super.loadView()
        view = mainView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.hideKeyboardWhenTappedAround()
        navigationController?.interactivePopGestureRecognizer?.delegate = self
        loadData()
        mainView.configure(data)
        mainView.webView.navigationDelegate = self
        setupAction()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.navigationBar.backgroundColor = nil
    }
}

// MARK: - ACTION Handler
extension DetailTransactionDonationWaitingController {
    private func setupAction(){
        mainView.backButton.onTap { self.back() }
    }
    
    @objc private func back() {
        navigationController?.popViewController(animated: true)
    }
}

extension DetailTransactionDonationWaitingController {
    private func loadData(){
        loader.load(request: .init(id: orderId)) { [weak self] (result) in
            guard let self = self else { return }
            
            switch result {
            case .success(let data):
                DispatchQueue.main.async {
                    self.data = data
                    self.mainView.configure(self.data)
                }
            case .failure(let error):
                DispatchQueue.main.async { self.displayAlertFailure(error.getErrorMessage()) }
            }
        }
    }
}


extension DetailTransactionDonationWaitingController: AlertDisplayer {
    private func displayAlertFailure(_ errorMessage: String){
        let action = UIAlertAction(title: .get(.ok), style: .default){ _ in
            self.back()
        }
        self.displayAlert(with: .get(.failed), message: errorMessage, actions: [action])
    }
}

extension DetailTransactionDonationWaitingController: WKNavigationDelegate{
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        mainView.loadingIndicator.stopAnimating()
        mainView.webView.evaluateJavaScript("document.getElementsByClassName('card-pay-button-part')[0].style.display = 'none';")
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        displayAlertFailure("Gagal memuat pembayaran.\n\(error.getErrorMessage())")
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        mainView.loadingIndicator.startAnimating()
    }
    
}
