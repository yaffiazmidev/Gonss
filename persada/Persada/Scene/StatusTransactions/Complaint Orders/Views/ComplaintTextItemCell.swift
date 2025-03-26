//
//  ComplaintTextItemCell.swift
//  KipasKipas
//
//  Created by NOOR on 02/02/21.
//  Copyright © 2021 Koanba. All rights reserved.
//

import UIKit

final class ComplaintTextItemCell: UITableViewCell {
	lazy var titleLabel: UILabel = {
		let label = UILabel(font: .Roboto(.regular, size: 14), textColor: .black, textAlignment: .left, numberOfLines: 0)
		label.translatesAutoresizingMaskIntoConstraints = false
		return label
	}()
	
	override func setSelected(_ selected: Bool, animated: Bool) {
		super.setSelected(selected, animated: animated)
		
		// Configure the view for the selected state
		if selected {
			let view =  UIView()
			view.backgroundColor = .secondaryLowTint
			self.selectedBackgroundView = view
		} else {
			self.backgroundColor = .white
			
		}
	}
	
	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		backgroundColor = .white
		
		addSubview(titleLabel)
		titleLabel.anchor(top: safeAreaLayoutGuide.topAnchor, left: safeAreaLayoutGuide.leftAnchor, bottom: safeAreaLayoutGuide.bottomAnchor, right: safeAreaLayoutGuide.rightAnchor, paddingTop: 16, paddingLeft: 16, paddingBottom: 16, paddingRight: 16)
	}
	
	required init?(coder: NSCoder) {
		super.init(coder: coder)
	}
}
