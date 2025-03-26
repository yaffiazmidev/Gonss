//
//  ProductCategoryItemCell.swift
//  KipasKipas
//
//  Created by IEN-Yasin-MacbookPro on 09/05/21.
//  Copyright © 2021 Koanba. All rights reserved.
//

import UIKit

class ProductCategoryItemCell: UICollectionViewCell {
    
    // MARK: - Public Property
    
    var sampleData: [[String: Any]] = []
    
    lazy var imageView: UIImageView = {
        let image = UIImageView(frame: .zero)
        image.translatesAutoresizingMaskIntoConstraints = false
//        image.layer.cornerRadius = 8
//        image.backgroundColor = .gray
        image.clipsToBounds = true
        image.contentMode = .scaleToFill
        image.isUserInteractionEnabled = true
        return image
    }()
    
    let titleLabel: UILabel = {
        let label: UILabel = UILabel(font: .Roboto(.medium, size: 16), textColor: .white, textAlignment: .left, numberOfLines: 3)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    @objc func handleOptionFavorite() {
        print("I'am Favorite")
    }

    // MARK: - Public Method
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .white
        
        addSubview(imageView)
        addSubview(titleLabel)
        
        imageView.anchor(top: topAnchor, left: leftAnchor,bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingRight: 0)
        titleLabel.centerXAnchor.constraint(equalTo: imageView.centerXAnchor).isActive = true
        titleLabel.centerYAnchor.constraint(equalTo: imageView.centerYAnchor).isActive = true
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(data:[String: Any]) {
        imageView.image = data ["image"] as? UIImage
        titleLabel.text = data ["title"] as? String
        
    }
}

