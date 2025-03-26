//
//  ShareView.swift
//  KipasKipasShareExtension
//
//  Created by Rahmat Trinanda Pramudya Amar on 10/11/23.
//  Copyright © 2023 Koanba. All rights reserved.
//

import Foundation
import UIKit

protocol ShareViewDelegate {
    func onDismiss()
}

class ShareView: UIView {
    
    var delegate: ShareViewDelegate?
    
    lazy var closeButton: UIButton = {
        let button = UIButton(type: .close)
        button.layer.cornerRadius = 16
        button.clipsToBounds = true
        button.addTarget(self, action: #selector(handleClose), for: .touchUpInside)
        button.isHidden = true
        return button
    }()
    
    lazy var messageLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.text = "Jenis media tidak didukung"
        label.isHidden = true
        return label
    }()
    
    lazy var loadingView: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView()
        view.startAnimating()
        view.isHidden = true
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(closeButton)
        addSubview(loadingView)
        addSubview(messageLabel)
        
        closeButton.anchor(top: topAnchor, leading: nil, bottom: nil, trailing: trailingAnchor, padding: .init(top: 16, left: 0, bottom: 0, right: 16), size: .init(width: 32, height: 32))
        messageLabel.centerInSuperview()
        loadingView.anchor(top: nil, leading: leadingAnchor, bottom: messageLabel.topAnchor, trailing: trailingAnchor)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension ShareView {
    func showLoading() {
        loadingView.isHidden = false
        messageLabel.isHidden = true
        closeButton.isHidden = true
    }
    
    func showMessage() {
        loadingView.isHidden = true
        messageLabel.isHidden = false
        closeButton.isHidden = false
    }
    
    @objc private func handleClose() {
        delegate?.onDismiss()
    }
}
