//
//  ProductArchiveItemCell.swift
//  KipasKipas
//
//  Created by IEN-Yasin-MacbookPro on 22/05/21.
//  Copyright © 2021 Koanba. All rights reserved.
//

import UIKit

protocol ProductArchiveItemCellDelegate {
    func popView(textActiveProduct: String,textEditProduct: String,textDeleteProduct: String, idProduct: String)
}

class ProductArchiveItemCell: UICollectionViewCell {
    
    var handleOption: (() -> Void)?
    
    var delegate: ProductArchiveItemCellDelegate?
    var archiveProduct: Product? = nil
    
    lazy var imageView: UIImageView = {
        let image = UIImageView(frame: .zero)
        image.translatesAutoresizingMaskIntoConstraints = false
        image.layer.cornerRadius = 8
        image.backgroundColor = .gray
        image.clipsToBounds = true
        image.contentMode = .scaleAspectFill
        image.isUserInteractionEnabled = true
        return image
    }()
    
    let titleLabel: UILabel = {
        let label: UILabel = UILabel(font: .Roboto(.medium, size: 12), textColor: .contentGrey, textAlignment: .left, numberOfLines: 3)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    let priceLabel: UILabel = {
        let label: UILabel = UILabel(font: .Roboto(.bold, size: 12), textColor: .primary, textAlignment: .left, numberOfLines: 2)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.layer.masksToBounds = false
        return label
    }()
    
    lazy private var optionButton: UIButton = {
        let button = UIButton(image: UIImage(named: String.get(.iconReport))!, target: self, action: #selector(handleOptionButton))
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .black
        button.layer.masksToBounds = false
        button.layer.cornerRadius = 32 / 2
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.white.cgColor
        button.alpha = 0.8
        return button
    }()
    
    lazy private var optionMore: UIButton = {
        let button = UIButton(image: UIImage(named: String.get(.iconKebabEllipsis))!, target: self, action: #selector(handleOptionMore))
        return button
    }()
    
    @objc func handleOptionButton() {
        self.handleOption?()
    }
    
    @objc func handleOptionMore() {
        if let id = archiveProduct?.id {
            self.delegate?.popView(textActiveProduct: String.get(.activeProduct), textEditProduct: String.get(.editProduct), textDeleteProduct: String.get(.deleteProduct), idProduct: id )
        }
    }
    
    // MARK: - Public Method
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .white
        
        addSubview(imageView)
        addSubview(titleLabel)
        addSubview(priceLabel)
        
        imageView.anchor(top: topAnchor, left: leftAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingRight: 0)
        titleLabel.anchor(top: imageView.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 12, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 18)
        priceLabel.anchor(top: titleLabel.bottomAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 18)
        let imageConstraint = imageView.bottomAnchor.constraint(greaterThanOrEqualTo: titleLabel.topAnchor, constant: 8)
        imageConstraint.priority = UILayoutPriority(750)
        imageConstraint.isActive = true
        
        imageView.addSubview(optionButton)
        optionButton.anchor(bottom: imageView.safeAreaLayoutGuide.bottomAnchor, right: imageView.safeAreaLayoutGuide.rightAnchor, paddingBottom: 12, paddingRight: 12, width: 32, height: 32)
        
        imageView.addSubview(optionMore)
        optionMore.anchor(bottom: imageView.safeAreaLayoutGuide.bottomAnchor, right: imageView.safeAreaLayoutGuide.rightAnchor, paddingBottom: 12, paddingRight: 12, width: 32, height: 32)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func hideOptions(hide: Bool) {
        self.optionButton.isHidden = hide
    }
    
    func configure(_ item: Product) {
        imageView.loadImage(at: item.medias?.first?.thumbnail?.small ?? "")
        priceLabel.text = item.price?.toMoney() ?? "0".toMoney()
        titleLabel.text = item.name
        archiveProduct = item
    }
}

