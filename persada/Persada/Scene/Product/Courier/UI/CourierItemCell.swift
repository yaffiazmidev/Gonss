//
//  CourierItemCell.swift
//  Persada
//
//  Created by movan on 23/07/20.
//  Copyright © 2020 Muhammad Noor. All rights reserved.
//

import UIKit

class CourierItemCell: UICollectionViewCell {

	var item: CourierItemPrice? {
		didSet {
            serviceNameLabel.text = item?.service
            durationLabel.text = item?.duration
            priceLabel.text = "\(item?.price?.toMoney() ?? "" )"
		}
	}

    lazy var serviceNameLabel : UILabel = {
        let label = UILabel(text: "", font: .Roboto(.bold, size: 12), textColor: .black, textAlignment: .left, numberOfLines: 1)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
        
    }()
    
    lazy var durationLabel : UILabel = {
        let label = UILabel(text: "", font: .Roboto(.regular, size: 10), textColor: .black, textAlignment: .left, numberOfLines: 1)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var priceLabel : UILabel = {
        let label = UILabel(text: "", font: .Roboto(.bold, size: 12), textColor: .primary, textAlignment: .right, numberOfLines: 1)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override var isSelected: Bool {
            didSet {
                layer.cornerRadius = 8
                backgroundColor = isSelected ? UIColor.secondaryLowTint : UIColor.white
            }
    }

	override init(frame: CGRect) {
		super.init(frame: frame)
		backgroundColor = .white
        
        addSubview(serviceNameLabel)
        addSubview(durationLabel)
        addSubview(priceLabel)
        
        
        serviceNameLabel.anchor(top: topAnchor, left: leftAnchor, paddingTop: 4, paddingLeft: 36)
        durationLabel.anchor(top: serviceNameLabel.topAnchor, left: leftAnchor, bottom: bottomAnchor, paddingLeft: 36, paddingBottom: 4)
        priceLabel.anchor(top: topAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 16, paddingBottom: 16, paddingRight: 24)
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}
