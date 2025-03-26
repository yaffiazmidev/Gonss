//
//  NewsCategoryCell.swift
//  KipasKipas
//
//  Created by movan on 24/11/20.
//  Copyright © 2020 Muhammad Noor. All rights reserved.
//

import UIKit

class NewsCategoryCell: UICollectionViewCell {
	
	lazy var titleLabel: PaddingLabel = {
		let label = PaddingLabel(text: "", font: .Roboto(.regular, size: 10), textColor: .grey, textAlignment: .center, numberOfLines: 2)
		label.translatesAutoresizingMaskIntoConstraints = false
		label.textColor = .contentGrey
		label.backgroundColor = UIColor.whiteSnow
		label.layer.masksToBounds = false
		label.layer.cornerRadius = 8
		label.topInset = 5
		label.bottomInset = 5
		label.leftInset = 16
		label.rightInset = 16
		label.numberOfLines = 1
		label.clipsToBounds = true
		label.textAlignment = .center
		label.text = String.get(.new)
		return label
	}()
	var isFirstAppear = false
    
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
						self.titleLabel.backgroundColor = .orangeLowTint
						 }
				 }
				 else {
					PaddingLabel.animate(withDuration: 0.3) { // for animation effect
						self.titleLabel.textColor = .contentGrey
						self.titleLabel.backgroundColor = .whiteSnow
						 }
				 }
		 }
 }
	
	func setUpCell(category : NewsCategoryData) {
		titleLabel.text = category.name?.uppercased()
//        if !isFirstAppear {
//            if category.selected ?? false {
//                self.titleLabel.textColor = .primary
//                self.titleLabel.backgroundColor = .orangeLowTint
//                self.isFirstAppear = true
//            }
//        }
        
	}
	
}
