//
//  HeaderProductConfirmPriceCell.swift
//  KipasKipas
//
//  Created by Muhammad Noor on 24/02/23.
//  Copyright © 2023 Koanba. All rights reserved.
//

import UIKit

class HeaderProductConfirmPriceCell: UITableViewCell {
    
    private lazy var iconImageView: UIImageView = {
        let image = UIImageView()
        image.translatesAutoresizingMaskIntoConstraints = false
        image.contentMode = .scaleAspectFill
        image.isUserInteractionEnabled = true
        image.backgroundColor = .white
        image.clipsToBounds = true
        image.accessibilityIdentifier = "iconImg-HeaderProductConfirmPriceCell"
        image.setCornerRadius = 8
        return image
    }()
    
    private lazy var titleLabel: UILabel = {
        let label: UILabel = UILabel()
        label.font = .boldSystemFont(ofSize: 13)
        label.textColor = .grey
        label.textAlignment = .left
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        label.backgroundColor = .white
        label.accessibilityIdentifier = "titleLabel-HeaderProductConfirmPriceCell"
        return label
    }()
    
    private lazy var nameLabel: UILabel = {
        let label: UILabel = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .black
        label.backgroundColor = .white
        label.numberOfLines = 0
        label.textAlignment = .justified
        label.font = .Roboto(.bold, size: 12)
        label.accessibilityIdentifier = "nameLabel-HeaderProductConfirmPriceCell"
        return label
    }()
    
    private lazy var priceLabel: UILabel = {
        let label: UILabel = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .primary
        label.isUserInteractionEnabled = false
        label.backgroundColor = .white
        label.font = .Roboto(.bold, size: 12)
        label.accessibilityIdentifier = "priceLabel-HeaderProductConfirmPriceCell"
        return label
    }()
    
    private lazy var titleStackView: UIStackView = {
        let container = UIStackView(arrangedSubviews: [nameLabel, priceLabel, UIView()])
        container.translatesAutoresizingMaskIntoConstraints = false
        container.spacing = 4
        container.distribution = .fill
        container.alignment = .top
        container.axis = .vertical
        container.accessibilityIdentifier = "titleStackView-HeaderProductConfirmPriceCell"
        return container
    }()
    
    private lazy var separator: UIView = {
        let vw = UIView()
        vw.translatesAutoresizingMaskIntoConstraints = false
        vw.backgroundColor = .whiteSmoke
        vw.accessibilityIdentifier = "separator-HeaderProductConfirmPriceCell"
        return vw
    }()
    
    func configure(imageURL: String, title: String, subtitle: String, price: String) {
        iconImageView.loadImage(at: imageURL)
        titleLabel.text = title
        nameLabel.text = subtitle
        priceLabel.text = price
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        contentView.backgroundColor = .white
        
        [titleLabel, iconImageView, titleStackView, separator].forEach { (view) in
            addSubview(view)
        }
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            titleLabel.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -16),
            titleLabel.heightAnchor.constraint(equalToConstant: 20)
        ])
        
        NSLayoutConstraint.activate([
            iconImageView.topAnchor.constraint(equalTo: titleLabel.safeAreaLayoutGuide.bottomAnchor, constant: 6),
            iconImageView.leadingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            iconImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),
            iconImageView.widthAnchor.constraint(equalToConstant: 65),
        ])
        
        NSLayoutConstraint.activate([
            titleStackView.topAnchor.constraint(equalTo: iconImageView.safeAreaLayoutGuide.topAnchor),
            titleStackView.leadingAnchor.constraint(equalTo: iconImageView.safeAreaLayoutGuide.trailingAnchor, constant: 10),
            titleStackView.trailingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            titleStackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8)
        ])
        
        NSLayoutConstraint.activate([
            separator.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            separator.widthAnchor.constraint(equalTo: widthAnchor),
            separator.heightAnchor.constraint(equalToConstant: 1)
        ])
    }
}
