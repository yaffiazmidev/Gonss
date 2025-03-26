//
//  ResellerProductErrorView.swift
//  KipasKipas
//
//  Created by Rahmat Trinanda Pramudya Amar on 22/02/23.
//  Copyright © 2023 Koanba. All rights reserved.
//

import UIKit

class ResellerProductErrorView: UIView {
    lazy var imageView: UIImageView = {
        let view = UIImageView(image: UIImage(named: .get(.iconResellerProductEmpty)), contentMode: .scaleAspectFit)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.clipsToBounds = true
        return view
    }()
    
    lazy var titleLabel: UILabel = {
        let label = UILabel(font: .Roboto(.medium, size: 14), textColor: .greyAlpha9, textAlignment: .center)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        return label
    }()
    
    lazy var messageLabel: UILabel = {
        let label = UILabel(font: .Roboto(size: 12), textColor: .placeholder, textAlignment: .center)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        return label
    }()
    
    lazy var actionButton: PrimaryButton = {
        let button = PrimaryButton(type: .system)
        button.setup(color: .primary, textColor: .white, font: .Roboto(.bold, size: 16))
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let container = UIView()
        container.addSubViews([imageView, titleLabel, messageLabel, actionButton])
        imageView.anchor(top: container.topAnchor, width: 102, height: 80)
        imageView.centerXTo(container.centerXAnchor)
        titleLabel.anchor(top: imageView.bottomAnchor, left: container.leftAnchor, right: container.rightAnchor, paddingTop: 16)
        messageLabel.anchor(top: titleLabel.bottomAnchor, left: container.leftAnchor, right: container.rightAnchor, paddingTop: 4)
        actionButton.anchor(top: messageLabel.bottomAnchor, left: container.leftAnchor, right: container.rightAnchor, paddingTop: 16)
        
        addSubview(container)
        container.anchor(left: leftAnchor, right: rightAnchor, paddingLeft: 48, paddingRight: 48)
        container.centerYTo(centerYAnchor)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup(title: String, message: String, titleButton: String? = nil, onTap: (() -> Void)? = nil){
        titleLabel.text = title
        messageLabel.text = message
        actionButton.isHidden = titleButton == nil && onTap == nil
        if let title = titleButton, let action = onTap {
            actionButton.setTitle(title, for: .normal)
            actionButton.onTap(action: action)
        }
    }
}
