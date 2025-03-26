//
//  UsernameConfirmResellerCell.swift
//  KipasKipas
//
//  Created by Muhammad Noor on 06/03/23.
//  Copyright © 2023 Koanba. All rights reserved.
//

import UIKit

class UsernameConfirmResellerCell: UITableViewCell {
    
    private lazy var iconImageView: UIImageView = {
        let image = UIImageView()
        image.translatesAutoresizingMaskIntoConstraints = false
        image.contentMode = .scaleAspectFill
        image.isUserInteractionEnabled = true
        image.clipsToBounds = true
        image.accessibilityIdentifier = "iconImageView-UsernameConfirmResellerCell"
        image.layer.cornerRadius = 17
        return image
    }()
    
    private lazy var titleLabel: UILabel = {
        let label: UILabel = UILabel()
        label.font = .Roboto(.regular, size: 11)
        label.textColor = .gray
        label.textAlignment = .left
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        label.backgroundColor = .white
        label.text = "Seller"
        label.accessibilityIdentifier = "titleLabel-UsernameConfirmResellerCell"
        return label
    }()
    
    private lazy var nameLabel: UILabel = {
        let label: UILabel = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .black
        label.backgroundColor = .white
        label.numberOfLines = 0
        label.font = .Roboto(.bold, size: 12)
        label.accessibilityIdentifier = "nameLabel-UsernameConfirmResellerCell"
        return label
    }()
    
    private lazy var usernameLabel: UILabel = {
        let label: UILabel = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .contentGrey
        label.isUserInteractionEnabled = false
        label.backgroundColor = .white
        label.font = .Roboto(.regular, size: 10)
        label.accessibilityIdentifier = "priceLabel-UsernameConfirmResellerCell"
        return label
    }()
    
    private lazy var iconVerified: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: String.get(.iconVerified)))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.isHidden = true
        return imageView
    }()
    
    private lazy var usernameStack: UIStackView = {
        let container = UIStackView(arrangedSubviews: [nameLabel, usernameLabel, UIView()])
        container.translatesAutoresizingMaskIntoConstraints = false
        container.spacing = 4
        container.distribution = .fill
        container.alignment = .top
        container.axis = .vertical
        container.accessibilityIdentifier = "usernameStack-UsernameConfirmResellerCell"
        return container
    }()
    
    private lazy var separator: UIView = {
        let vw = UIView()
        vw.translatesAutoresizingMaskIntoConstraints = false
        vw.backgroundColor = .whiteSmoke
        vw.accessibilityIdentifier = "separator-HeaderProductConfirmPriceCell"
        return vw
    }()
    
    func configure(imageURL: String, title: String, name: String, username: String, isVerified: Bool = false) {
        iconImageView.loadImage(at: imageURL)
        titleLabel.text = title
        nameLabel.text = name
        usernameLabel.text = username
        iconVerified.isHidden = !isVerified
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = .white
        
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func setupViews() {
        [titleLabel, iconImageView, usernameStack, separator].forEach { (view) in
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
            iconImageView.widthAnchor.constraint(equalToConstant: 34),
        ])
        
        NSLayoutConstraint.activate([
            usernameStack.topAnchor.constraint(equalTo: iconImageView.safeAreaLayoutGuide.topAnchor),
            usernameStack.leadingAnchor.constraint(equalTo: iconImageView.safeAreaLayoutGuide.trailingAnchor, constant: 10),
            usernameStack.trailingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            usernameStack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8)
        ])
        
        usernameLabel.addSubview(iconVerified)
        NSLayoutConstraint.activate([
            iconVerified.leadingAnchor.constraint(equalTo: usernameLabel.trailingAnchor),
            iconVerified.heightAnchor.constraint(equalToConstant: 12),
            iconVerified.widthAnchor.constraint(equalToConstant: 12),
        ])
        
        NSLayoutConstraint.activate([
            separator.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            separator.widthAnchor.constraint(equalTo: widthAnchor),
            separator.heightAnchor.constraint(equalToConstant: 1)
        ])
    }
}
