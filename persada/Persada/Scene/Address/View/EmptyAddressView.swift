//
//  EmptyAddressView.swift
//  KipasKipas
//
//  Created by Muhammad Noor on 16/08/22.
//  Copyright © 2022 Koanba. All rights reserved.
//

import UIKit

final class EmptyAddressView: UIView {
    
    // MARK:- Public Property
    
    enum ViewTrait {
        static let leftMargin: CGFloat = 10.0
        static let padding: CGFloat = 16.0
        static let cellId: String = String.get(.cellID)
        static let widht = UIScreen.main.bounds.width - 24
        static let placeHolderSearch: String = String.get(.cariAlamatPlaceholder)
    }
    
    lazy var buttonAddAddress: UIButton = {
        let button = UIButton(title: String.get(.tambahAlamatWithPlus), titleColor: .white, font: UIFont.Roboto(.bold, size: 12))
        button.backgroundColor = #colorLiteral(red: 1, green: 0.2588235294, blue: 0.3960784314, alpha: 1)
        button.layer.cornerRadius = 8.0
        button.accessibilityIdentifier = "buttonadd-address"
        return button
    }()
    
    
    lazy var imageEmptyPlaceholder: UIImageView = {
        let image = UIImageView(image: UIImage(named: String.get(.iconPinPoint)))
        image.accessibilityIdentifier = "imgempty-address"
        return image
    }()
    
    lazy var labelEmptyPlaceholder: UILabel = {
        let label = UILabel(textAlignment: .center, numberOfLines: 0)
        
        let myString = NSMutableAttributedString(string: .get(.emptyShopAddressPlaceholder),
                                                 attributes: [
                                                    NSAttributedString.Key.font: UIFont.Roboto(.medium, size: 14),
                                                    NSAttributedString.Key.foregroundColor: UIColor.placeholder,
                                                 ])
        label.attributedText = myString
        label.accessibilityIdentifier = "labelempty-address"
        return label
    }()
    
    // MARK:- Public Methods
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
        [buttonAddAddress, imageEmptyPlaceholder, labelEmptyPlaceholder].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.layer.masksToBounds = false
            $0.layer.cornerRadius = 8
            addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            labelEmptyPlaceholder.centerXAnchor.constraint(equalTo: centerXAnchor),
            labelEmptyPlaceholder.centerYAnchor.constraint(equalTo: centerYAnchor),
            labelEmptyPlaceholder.leftAnchor.constraint(equalTo: leftAnchor, constant: 32),
            labelEmptyPlaceholder.rightAnchor.constraint(equalTo: rightAnchor, constant: -32)
        ])
        
        NSLayoutConstraint.activate([
            imageEmptyPlaceholder.bottomAnchor.constraint(equalTo: labelEmptyPlaceholder.topAnchor, constant: -24),
            imageEmptyPlaceholder.centerXAnchor.constraint(equalTo: centerXAnchor),
            imageEmptyPlaceholder.heightAnchor.constraint(equalToConstant: 50),
            imageEmptyPlaceholder.widthAnchor.constraint(equalToConstant: 50)
        ])
        buttonAddAddress.anchor(left: leftAnchor, bottom: safeAreaLayoutGuide.bottomAnchor, right: rightAnchor, paddingLeft: 20, paddingBottom: 20, paddingRight: 20, height: 48)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
