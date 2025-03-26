//
//  CategoryShopCell.swift
//  KipasKipas
//
//  Created by Muhammad Noor on 18/01/23.
//  Copyright © 2023 Koanba. All rights reserved.
//

import UIKit

class CategoryShopCell: UITableViewCell {
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel(font: .Roboto(.regular, size: 14), textColor: .black, textAlignment: .left, numberOfLines: 0)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.accessibilityIdentifier = "titleLabel-CategoryShopCell"
        return label
    }()
    
    private lazy var categoryImageView: UIImageView = {
        let imageView: UIImageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.backgroundColor = .whiteSnow
        imageView.contentMode = .scaleAspectFit
        imageView.layer.cornerRadius = 16
        imageView.clipsToBounds = true
        imageView.setBorderColor = .white
        imageView.setBorderWidth = 1.5
        imageView.accessibilityIdentifier = "categoryImageView-CategoryShopCell"
        return imageView
    }()
    
    private lazy var separatorView: UIView = {
        let view = UIView(backgroundColor: .whiteSmoke)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.accessibilityIdentifier = "separatorView-CategoryShopCell"
        return view
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupView() {
        backgroundColor = .white
        addSubview(categoryImageView)
        NSLayoutConstraint.activate([
            categoryImageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            categoryImageView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 16),
            categoryImageView.heightAnchor.constraint(equalToConstant: 40),
            categoryImageView.widthAnchor.constraint(equalToConstant: 40)
        ])
        
        addSubview(titleLabel)
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: categoryImageView.trailingAnchor, constant: 8),
            titleLabel.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -18),
            titleLabel.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 18),
            titleLabel.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -18),
        ])
        
        addSubview(separatorView)
        NSLayoutConstraint.activate([
            separatorView.leadingAnchor.constraint(equalTo: categoryImageView.leadingAnchor),
            separatorView.bottomAnchor.constraint(equalTo: bottomAnchor),
            separatorView.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            separatorView.heightAnchor.constraint(equalToConstant: 1)
        ])
        
        selectionStyle = .none
    }
    
    func configure(url: String, text: String) {
        categoryImageView.setImage(url: url)
        titleLabel.text = text
    }
}
