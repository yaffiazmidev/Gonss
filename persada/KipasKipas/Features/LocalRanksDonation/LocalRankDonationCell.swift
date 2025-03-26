//
//  LocalRankDonationCell.swift
//  KipasKipas
//
//  Created by Muhammad Noor on 22/09/23.
//  Copyright © 2023 Koanba. All rights reserved.
//

import UIKit
import KipasKipasShared

class LocalRankDonationCell: UITableViewCell {
    
    public var rank: Int = 0 {
        didSet {
            configureAppearanceBasedOnRank()
        }
    }
    
    lazy var rankIcon: UIImageView = {
        var image = UIImageView()
        image.layer.masksToBounds = false
        image.translatesAutoresizingMaskIntoConstraints = false
        image.backgroundColor = .white
        image.image = UIImage(systemName: "bell.badge")
        image.contentMode = .center
        image.layer.cornerRadius = 30 / 2
        image.clipsToBounds = true
        return image
    }()
    
    lazy var profileImageView: UIImageView = {
        let image = UIImageView()
        image.layer.masksToBounds = false
        image.translatesAutoresizingMaskIntoConstraints = false
        image.backgroundColor = .white
        image.image = UIImage(systemName: "person")
        image.layer.cornerRadius = 40 / 2
        image.clipsToBounds = true
        image.contentMode = .scaleAspectFit
        image.layer.borderWidth = 2
        image.layer.borderColor = UIColor.carrot.cgColor
        image.backgroundColor = .mauve
        return image
    }()
    
    lazy var verifyIcon: UIImageView = {
        let image = UIImageView()
        image.contentMode = .scaleAspectFit
        image.translatesAutoresizingMaskIntoConstraints = false
        image.backgroundColor = .white
        image.image = UIImage(contentsOfFile: .get(.iconVerified))
        return image
    }()
    
    lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.font = .Roboto(.regular, size: 11)
        label.textColor = .contentGrey
        label.textAlignment = .left
        label.numberOfLines = 1
        label.text = "Muhammad Noor"
        label.translatesAutoresizingMaskIntoConstraints = false
        label.adjustsFontSizeToFitWidth = false
        label.lineBreakMode = .byTruncatingTail
        return label
    }()
    
    lazy var priceLabel: UILabel = {
        let label = UILabel()
        label.font = .Roboto(.regular, size: 12)
        label.textAlignment = .right
        label.textColor = .placeholder
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        label.adjustsFontSizeToFitWidth = false
        label.text = "Rp 10.000.000"
        label.lineBreakMode = .byTruncatingTail
        return label
    }()

    lazy var usernameStackView: UIStackView = {
        let view = UIStackView(arrangedSubviews: [nameLabel, verifyIcon, UIView()])
        view.translatesAutoresizingMaskIntoConstraints = false
        view.axis = .horizontal
        view.alignment = .fill
        view.distribution = .fill
        view.spacing = 1
        return view
    }()

    private let rankLabel = UILabel()
    
    private func configureAppearanceBasedOnRank() {
        rankLabel.text = String(rank)
        rankLabel.textColor = .white
        
        switch rank {
        case 1:
            rankIcon.image = .ribbonRank1
        case 2:
            rankIcon.image = .ribbonRank2
            
        case 3:
            rankIcon.image = .ribbonRank3
            
        default:
            rankIcon.image = .ribbonRankGlobal
            rankLabel.textColor = .gravel
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        backgroundColor = .white
        contentView.addSubview(rankIcon)
        contentView.addSubview(profileImageView)
        contentView.addSubview(usernameStackView)
        contentView.addSubview(priceLabel)
        
        rankIcon.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 0).isActive = true
        rankIcon.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 12).isActive = true
        rankIcon.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: 0).isActive = true
        rankIcon.widthAnchor.constraint(equalToConstant: 30).isActive = true
        
        profileImageView.leadingAnchor.constraint(equalTo: rankIcon.trailingAnchor, constant: 12).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 40).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        priceLabel.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 0).isActive = true
        priceLabel.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -12).isActive = true
        priceLabel.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: 0).isActive = true
        priceLabel.widthAnchor.constraint(equalToConstant: 100).isActive = true
        
        usernameStackView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 0).isActive = true
        usernameStackView.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 12).isActive = true
        usernameStackView.trailingAnchor.constraint(equalTo: priceLabel.leadingAnchor, constant: -12).isActive = true
        usernameStackView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: 0).isActive = true
        
        configureRankLabel()
    }
    
    func configureRankLabel() {
        rankLabel.font = .Roboto(.medium, size: 9)
        
        rankIcon.addSubview(rankLabel)
        rankLabel.anchors.centerX.align()
        rankLabel.anchors.centerY.align(offset: -2)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
