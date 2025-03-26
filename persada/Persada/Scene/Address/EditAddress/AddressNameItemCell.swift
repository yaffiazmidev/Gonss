//
//  AddressNameItemCell.swift
//  KipasKipas
//
//  Created by Azam Mukhtar on 15/04/21.
//  Copyright © 2021 Koanba. All rights reserved.
//

import UIKit

class AddressNameItemCell : UICollectionViewCell {
	
	lazy var titleLabel: PaddingLabel = {
		let label = PaddingLabel(text: "", font: .Roboto(.regular, size: 12), textColor: .grey, textAlignment: .center, numberOfLines: 1)
		label.translatesAutoresizingMaskIntoConstraints = false
		label.textColor = .placeholder
		label.backgroundColor = UIColor.white
		label.layer.masksToBounds = false
		label.layer.cornerRadius = 8
		label.layer.borderColor = UIColor.placeholder.cgColor
		label.layer.borderWidth = 1.0
		label.topInset = 16
		label.bottomInset = 16
		label.leftInset = 12
		label.rightInset = 12
		label.numberOfLines = 1
		label.clipsToBounds = true
		label.textAlignment = .center
		label.text = String.get(.rumah)
		return label
	}()
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		
		addSubview(titleLabel)
		titleLabel.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor)
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	
	override var isSelected: Bool {
		 didSet{
				 if self.isSelected {
					PaddingLabel.animate(withDuration: 0.3) { // for animation effect
						self.titleLabel.textColor = .primary
						self.titleLabel.layer.borderColor = UIColor.primary.cgColor
						 }
				 }
				 else {
					PaddingLabel.animate(withDuration: 0.3) { // for animation effect
						self.titleLabel.textColor = .placeholder
						self.titleLabel.layer.borderColor = UIColor.placeholder.cgColor
						 }
				 }
		 }
 }
	
	func setUpCell(category : String) {
		titleLabel.text = category
	}
}
