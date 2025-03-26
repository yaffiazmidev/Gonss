//
//  NotificationArchiveView.swift
//  KipasKipas
//
//  Created by Rahmat Trinanda Pramudya Amar on 28/03/23.
//  Copyright © 2023 Koanba. All rights reserved.
//

import Foundation
import UIKit
import KipasKipasShared

class NotificationArchiveView: UIView {
    lazy var imageView: UIImageView = {
        let image = UIImageView()
        image.translatesAutoresizingMaskIntoConstraints = false
        image.image = UIImage(named: .get(.iconBin))
        image.contentMode = .scaleAspectFill
        return image
    }()
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Produk diarsipkan"
        label.font = .Roboto(.bold, size: 14)
        label.textColor = .contentGrey
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let descriptionLabel: UILabel = {
        let label = UILabel()
        label.text = "Produk yang kamu pilih telah diarsipkan oleh seller."
        label.font = .Roboto(.regular, size: 12)
        label.textColor =  .placeholder
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - Public Method
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
        
        let container = UIView()
        addSubview(container)
        container.addSubviews([imageView, titleLabel, descriptionLabel])
        container.anchor(left: leftAnchor, right: rightAnchor, paddingLeft: 46, paddingBottom: 100, paddingRight: 46)
        container.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -64).isActive = true
        
        imageView.anchor(top: container.topAnchor, width: 48, height: 48)
        imageView.centerXTo(container.centerXAnchor)
        titleLabel.anchor(top: imageView.bottomAnchor, left: container.leftAnchor, right: container.rightAnchor, paddingTop: 12)
        descriptionLabel.anchor(top: titleLabel.bottomAnchor, left: container.leftAnchor, right: container.rightAnchor, paddingTop: 10)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
