//
//  ProductPriceConfirmResellerCell.swift
//  KipasKipas
//
//  Created by Muhammad Noor on 24/02/23.
//  Copyright © 2023 Koanba. All rights reserved.
//

import UIKit

class ProductPriceConfirmResellerCell: UITableViewCell {

    private lazy var titleLabel: UILabel = {
        let label: UILabel = UILabel()
        label.font = .Roboto(.regular, size: 11)
        label.textColor = .grey
        label.textAlignment = .left
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        label.backgroundColor = .white
        label.text = "Harga Produk"
        label.accessibilityIdentifier = "titleLabel-ProductPriceConfirmResellerCell"
        return label
    }()
    
    private lazy var subtitleLabel: UILabel = {
        let label: UILabel = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .grey
        label.backgroundColor = .white
        label.numberOfLines = 0
        label.font = .Roboto(.regular, size: 11)
        label.accessibilityIdentifier = "subtitleLabel-ProductPriceConfirmResellerCell"
        return label
    }()
    
    private lazy var priceLabel: CustomIndentedTextField = {
        let label: CustomIndentedTextField = CustomIndentedTextField(padding: 12)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.backgroundColor = .whiteSmoke
        label.isUserInteractionEnabled = false
        label.layer.cornerRadius = 8
        label.textColor = .grey
        label.backgroundColor = UIColor(hexString: "F9F9F9", alpha: 1)
        label.font = .Roboto(.medium, size: 11)
        label.accessibilityIdentifier = "priceLabel-ProductPriceConfirmResellerCell"
        return label
    }()
    
    func configure(title: String, price: String, desc: String) {
        titleLabel.text = title
        subtitleLabel.text = desc
        priceLabel.text = price
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = .white
        
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupViews() {
        [titleLabel, priceLabel, subtitleLabel].forEach {
            contentView.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.topAnchor, constant: 8),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            titleLabel.heightAnchor.constraint(equalToConstant: 20)
        ])

        NSLayoutConstraint.activate([
            priceLabel.topAnchor.constraint(equalTo: titleLabel.safeAreaLayoutGuide.bottomAnchor, constant: 8),
            priceLabel.leadingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            priceLabel.trailingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            priceLabel.heightAnchor.constraint(equalToConstant: 40)
        ])
        
        NSLayoutConstraint.activate([
            subtitleLabel.topAnchor.constraint(equalTo: priceLabel.safeAreaLayoutGuide.bottomAnchor, constant: 8),
            subtitleLabel.leadingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            subtitleLabel.trailingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            subtitleLabel.bottomAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.bottomAnchor, constant: -8)
        ])
    }
}
