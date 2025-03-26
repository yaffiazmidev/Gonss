//
//  DetailTransactionDonationWaitingView.swift
//  KipasKipas
//
//  Created by Rahmat Trinanda Pramudya Amar on 29/03/23.
//  Copyright © 2023 Koanba. All rights reserved.
//

import Foundation
import UIKit
import WebKit

class DetailTransactionDonationWaitingView: UIView {
    lazy var loadingIndicator: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView()
        view.color = .primary
        return view
    }()
    
    lazy var webView: WKWebView = {
        let view = WKWebView()
        return view
    }()
    
    lazy var backButton: PrimaryButton = {
        let button = PrimaryButton(type: .system)
        button.setTitle(.get(.back), for: .normal)
        button.setup(color: .whiteSnow, textColor: .contentGrey, font: .Roboto(.bold, size: 14))
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
        
        addSubViews([webView, backButton, loadingIndicator])
        backButton.anchor(left: leftAnchor, bottom: safeAreaLayoutGuide.bottomAnchor, right: rightAnchor, paddingLeft: 20, paddingBottom: 20, paddingRight: 20)
        webView.anchor(top: safeAreaLayoutGuide.topAnchor, left: leftAnchor, bottom: backButton.topAnchor, right: rightAnchor, paddingBottom: 20)
        
        loadingIndicator.anchor(width: 20, height: 20)
        loadingIndicator.centerXTo(centerXAnchor)
        loadingIndicator.centerYTo(centerYAnchor)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(_ data: DetailTransactionOrderItem?){
        webView.isHidden = data == nil
        backButton.isHidden = data == nil
        
        guard let data = data else {
            loadingIndicator.startAnimating()
            return
        }
        
        loadingIndicator.stopAnimating()
        let request = URLRequest(url: URL(string: data.orderDetail.urlPaymentPage)!)
        webView.load(request)
    }
}
