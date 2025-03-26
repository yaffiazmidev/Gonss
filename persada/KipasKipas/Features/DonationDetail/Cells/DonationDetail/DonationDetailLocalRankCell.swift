//
//  DonationDetailLocalRankCell.swift
//  KipasKipas
//
//  Created by Muhammad Noor on 25/09/23.
//  Copyright © 2023 Koanba. All rights reserved.
//

import UIKit
import KipasKipasShared

final class DonationDetailLocalRankCell: UITableViewCell {
    
    private(set) var photoImageView = BadgedImageViewV2()
    private let stackLabel = UIStackView()
    private let nameStack = UIStackView()
    private let badgeStack = UIStackView()
    
    private(set) var nameLabel = UILabel()
    private(set) var usernameLabel = UILabel()
    private(set) var priceLabel = UILabel()
    private(set) var numberLabel = UILabel()
    private(set) var levelBadgeLabel = UILabel()
    private(set) var badgeImage = UIImageView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
        
    override func prepareForReuse() {
        super.prepareForReuse()
        photoImageView.userImageView.setImage(url: "")
        photoImageView.userImageView.image = nil
        badgeImage.image = nil
    }

}

// MARK: UI
private extension DonationDetailLocalRankCell {
    func configureUI() {
        backgroundColor = UIColor(hexString: "#320647")
        configureNumberLabel()
        configureUserImageView()
        configureStackLabel()
    }
    
    func configureNumberLabel() {
        numberLabel.font = .rye(.regular, size: 14)
        numberLabel.textColor = .white
        numberLabel.accessibilityIdentifier = "numberLabel"
        
        contentView.addSubview(numberLabel)
        numberLabel.anchors.leading.equal(contentView.anchors.leading, constant: 12)
        numberLabel.anchors.centerY.align()
        numberLabel.anchors.height.equal(20)
        numberLabel.anchors.width.equal(10)
    }
    
    func configureUserImageView() {
        photoImageView.contentMode = .scaleAspectFit
        photoImageView.accessibilityIdentifier = "photoImageView"
        
        contentView.addSubview(photoImageView)
        photoImageView.anchors.leading.equal(numberLabel.anchors.trailing, constant: 12)
        photoImageView.anchors.centerY.align()
        photoImageView.anchors.height.equal(60)
        photoImageView.anchors.width.equal(60)
    }
    
    func configureStackLabel() {
        stackLabel.axis = .vertical
        stackLabel.spacing = 4
        stackLabel.accessibilityIdentifier = "stackLabel"
        
        contentView.addSubview(stackLabel)
        stackLabel.anchors.centerY.align()
        stackLabel.anchors.trailing.equal(contentView.anchors.trailing, constant: -12)
        stackLabel.anchors.leading.spacing(15, to: photoImageView.anchors.trailing)
        
        configureNameStack()
        configureUsernameLabel()
        configurePriceLabel()
    }
    
    func configureNameStack() {
        nameStack.axis = .horizontal
        nameStack.spacing = 4
        nameStack.accessibilityIdentifier = "nameStack"
        nameStack.anchors.height.equal(20)
        
        stackLabel.addArrangedSubview(nameStack)
        configureBadgeStack()
        configureNameLabel()
    }
    
    func configureBadgeStack() {
        badgeStack.axis = .horizontal
        badgeStack.spacing = 5
        badgeStack.backgroundColor = UIColor(white: 1, alpha: 0.4)
        badgeStack.layer.cornerRadius = 4
        badgeStack.alignment = .fill
        badgeStack.distribution = .fillEqually
        badgeStack.accessibilityIdentifier = "badgeStack"
        badgeStack.layoutMargins = UIEdgeInsets(top: 0, left: 4, bottom: 0, right: 0)
        badgeStack.isLayoutMarginsRelativeArrangement = true

        nameStack.addArrangedSubview(badgeStack)
        nameStack.addArrangedSubview(nameLabel)
        
        configureBadgeImage()
        configureLevelBadge()
    }
    
    func configureNameLabel() {
        nameLabel.font = .rye(.regular, size: 14)
        nameLabel.textColor = .white
        nameLabel.accessibilityIdentifier = "nameLabel"
        
        nameStack.addArrangedSubview(nameLabel)
    }
    
    func configureUsernameLabel() {
        usernameLabel.font = .roboto(.regular, size: 11)
        usernameLabel.textColor = .ashGrey
        usernameLabel.accessibilityIdentifier = "usernameLabel"
        
        stackLabel.addArrangedSubview(usernameLabel)
        stackLabel.addArrangedSubview(priceLabel)
    }
    
    func configurePriceLabel() {
        priceLabel.font = .roboto(.regular, size: 11)
        priceLabel.textColor = .ashGrey
        priceLabel.accessibilityIdentifier = "priceLabel"
        stackLabel.addArrangedSubview(priceLabel)
    }
    
    func configureBadgeImage() {
        badgeImage.contentMode = .scaleAspectFill
        badgeImage.accessibilityIdentifier = "badgeImage"
        badgeImage.anchors.height.equal(12)
        badgeImage.anchors.width.equal(12)
        
        badgeStack.addArrangedSubview(badgeImage)
    }
    
    func configureLevelBadge() {
        levelBadgeLabel.font = .roboto(.bold, size: 11)
        levelBadgeLabel.textColor = .white
        levelBadgeLabel.accessibilityIdentifier = "levelBadgeLabel"
        levelBadgeLabel.anchors.width.equal(15)
        
        badgeStack.addArrangedSubview(levelBadgeLabel)
    }
    
}

