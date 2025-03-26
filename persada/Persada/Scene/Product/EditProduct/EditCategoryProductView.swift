//
//  EditCategoryProductView.swift
//  KipasKipas
//
//  Created by Muhammad Noor on 27/01/23.
//  Copyright © 2023 Koanba. All rights reserved.
//

import UIKit

class EditCategoryProductView: UIView {
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .Roboto(.regular, size: 12)
        label.textColor = .black
        label.numberOfLines = 1
        label.text = "Shop"
        return label
    }()

    lazy var iconClose: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "xmark")!)
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .black
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupFrameView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupFrameView() {
        addSubview(titleLabel)
        NSLayoutConstraint.activate([
            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 16),
            titleLabel.heightAnchor.constraint(equalToConstant: 20),
            titleLabel.widthAnchor.constraint(equalToConstant: 120)
        ])
        
        addSubview(iconClose)
        NSLayoutConstraint.activate([
            iconClose.centerYAnchor.constraint(equalTo: centerYAnchor),
            iconClose.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -16),
            iconClose.heightAnchor.constraint(equalToConstant: 15),
            iconClose.widthAnchor.constraint(equalToConstant: 15)
        ])
    }
    
    func setup(text: String) {
        titleLabel.text = text
    }
}
