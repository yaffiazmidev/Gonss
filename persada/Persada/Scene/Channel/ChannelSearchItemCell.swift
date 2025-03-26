//
//  ChannelSearchItemCell.swift
//  KipasKipas
//
//  Created by Muhammad Noor on 16/04/21.
//  Copyright © 2021 Koanba. All rights reserved.
//

import UIKit

class ChannelSearchItemCell: UICollectionViewCell {
	
	// MARK: - Properties
	
	var option: ProfileFilterOptions! {
		didSet { titleLabel.text = option.description }
	}
	
	let titleLabel: UILabel = {
		let label: UILabel = UILabel(font: .Roboto(.bold, size: 14), textColor: .gray, textAlignment: .center, numberOfLines: 1)
		return label
	}()
	
	
	private let underlineView: UIView = {
		let view: UIView = UIView()
		view.backgroundColor = .white
		return view
	}()
	
	override var isSelected: Bool {
		didSet {
			titleLabel.textColor = isSelected ? .contentGrey : .grey
			underlineView.backgroundColor = isSelected ? .whiteSmoke : .clear
		}
	}
	
	// MARK: - Lifecycle
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		backgroundColor = .white
		
		addSubview(titleLabel)
		addSubview(underlineView)
		
		titleLabel.centerXToSuperview()
		titleLabel.centerYToSuperview()
		
		underlineView.anchor(top: titleLabel.bottomAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: frame.width, height: 2)
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}

