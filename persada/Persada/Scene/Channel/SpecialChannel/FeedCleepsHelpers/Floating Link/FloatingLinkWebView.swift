//
//  FloatingLinkWebView.swift
//  KipasKipas
//
//  Created by Rahmat Trinanda Pramudya Amar on 11/04/23.
//  Copyright © 2023 Koanba. All rights reserved.
//

import Foundation
import WebKit

class FloatingLinkWebView: UIView {
    lazy var loadingIndicator: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView()
        view.color = .primary
        return view
    }()
    
    lazy var webView: WKWebView = {
        let view = WKWebView()
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
        
        addSubViews([webView, loadingIndicator])
        webView.anchor(top: safeAreaLayoutGuide.topAnchor, left: leftAnchor, bottom: safeAreaLayoutGuide.bottomAnchor, right: rightAnchor)
        
        loadingIndicator.anchor(width: 20, height: 20)
        loadingIndicator.centerXTo(centerXAnchor)
        loadingIndicator.centerYTo(centerYAnchor)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
