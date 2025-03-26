//
//  DonationCartViewCell.swift
//  KipasKipas
//
//  Created by Rahmat Trinanda Pramudya Amar on 01/02/24.
//  Copyright © 2024 Koanba. All rights reserved.
//

import UIKit
import KipasKipasShared

class DonationCartViewCell: UICollectionViewCell {
    
    lazy var checkbox: KKCheckbox = {
        let view = KKCheckbox()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isUsingSFSymbols = true
        view.isThreeState = false
        view.tintColor = .secondary
        
        return view
    }()
    
    lazy var checkboxView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(checkbox)
        checkbox.anchor(width: 14, height: 14)
        checkbox.centerInSuperview()
        
        return view
    }()
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 2
        label.textColor = .contentGrey
        label.font = .systemFont(ofSize: 14, weight: .medium)
        
        return label
    }()
    
    lazy var amountLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .black
        label.font = .systemFont(ofSize: 14, weight: .bold)
        
        return label
    }()
    
    lazy var changeLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Ubah"
        label.textColor = .secondary
        label.font = .systemFont(ofSize: 14, weight: .regular)
        
        return label
    }()
    
    lazy var removeView: UIView = {
        let icon = UIImageView()
        icon.translatesAutoresizingMaskIntoConstraints = false
        icon.image = .iconTrashFillGrey
        
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(icon)
        icon.anchor(bottom: view.bottomAnchor, right: view.rightAnchor, paddingBottom: 2, width: 14, height: 14)
        return view
    }()
    
    lazy var bottomView: UIView = {
        let action = UIStackView(arrangedSubviews: [changeLabel, removeView])
        action.translatesAutoresizingMaskIntoConstraints = false
        action.axis = .horizontal
        action.spacing = 10
        action.alignment = .lastBaseline
        action.distribution = .fill
        removeView.anchor(width: 26, height: 26)
        
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubviews([amountLabel, action])
        amountLabel.anchor(left: view.leftAnchor, bottom: view.bottomAnchor)
        action.anchor(left: amountLabel.rightAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingLeft: 22)
        
        return view
    }()
    
    lazy var mainView: UIView = {
        let spacer = UIView()
        spacer.translatesAutoresizingMaskIntoConstraints = false
        
        let container = UIStackView(arrangedSubviews: [titleLabel, spacer, bottomView])
        container.translatesAutoresizingMaskIntoConstraints = false
        container.axis = .vertical
        
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = true
        
        view.addSubviews([checkboxView, container])
        checkboxView.anchor(top: view.topAnchor, left: view.leftAnchor, width: 20, height: 20)
        container.anchor(top: view.topAnchor, left: checkbox.rightAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingLeft: 8)
        
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
        layer.cornerRadius = 8
        addSubview(mainView)
        mainView.anchors.edges.pin(insets: 12)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with data: DonationCart) {
        checkbox.setState(data.checked ? .on : .clear)
        checkbox.tintColor = data.checked ? .secondary : .grey
        titleLabel.text = data.title
        
        let formatter = NumberFormatter()
        formatter.locale = .init(identifier: "id_ID")
        formatter.numberStyle = .currency
        amountLabel.text = formatter.string(from: data.amount as NSNumber)
    }
}
