//
//  CustomEmptyView.swift
//  KipasKipas
//
//  Created by DENAZMI on 29/06/22.
//  Copyright © 2022 Koanba. All rights reserved.
//

import UIKit

struct CustomEmptyViewData {
    var icon: String?
    var title: String?
    var message: String?
    
    init(icon: String? = nil, title: String? = nil, message: String? = nil){
        self.icon = icon
        self.title = title
        self.message = message
    }
}

class CustomEmptyView: UICollectionReusableView {
    
    lazy var iconImage: UIImageView = {
        let img = UIImageView(image: UIImage(named: .get(.iconEmptyBold)), contentMode: .scaleAspectFit)
        img.translatesAutoresizingMaskIntoConstraints = false
        img.clipsToBounds = true
        return img
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
    
    override func layoutSubviews() {
        super.layoutSubviews()
        addSubview(iconImage)
        addSubview(titleLabel)
        addSubview(messageLabel)
        
        NSLayoutConstraint.activate([
            iconImage.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -80),
            iconImage.centerXAnchor.constraint(equalTo: centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: iconImage.bottomAnchor, constant: 16),
            titleLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: 32),
            titleLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: -32),
            messageLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            messageLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: 32),
            messageLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: -32)
        ])
        
        iconImage.withSize(CGSize(width: 50, height: 50))
    }
    
    func setup(icon: String? = nil, title: String? = nil, message: String? = nil) {
        iconImage.image = UIImage(named: icon ?? "")
        titleLabel.text = title
        messageLabel.text = message
    }
    
    func setup(data: CustomEmptyViewData? = nil) {
        iconImage.image = UIImage(named: data?.icon ?? "")
        titleLabel.text = data?.title
        messageLabel.text = data?.message
    }
}
