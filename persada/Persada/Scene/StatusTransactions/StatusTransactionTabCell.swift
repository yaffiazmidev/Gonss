//
//  StatusTransactionTabCell.swift
//  KipasKipas
//
//  Created by Azam Mukhtar on 03/05/21.
//  Copyright © 2021 Koanba. All rights reserved.
//

import UIKit

class StatusTransactionTabCell : UICollectionViewCell {
		
		// MARK: - Properties
		
		var option: ProfileFilterOptions! {
				didSet { titleLabel.text = option.description }
		}
		
		let titleLabel: UILabel = {
			let label: UILabel = UILabel(font: .Roboto(.bold, size: 14), textColor: .placeholder, textAlignment: .center, numberOfLines: 1)
				return label
		}()
		
		
		
		private let underlineView: UIView = {
				let view: UIView = UIView()
				view.backgroundColor = .white
				return view
		}()
		
		override var isSelected: Bool {
				didSet {
						titleLabel.textColor = isSelected ? .primary : .lightGray
						underlineView.backgroundColor = isSelected ? .primaryLowTint : .white
				}
		}
		
		override init(frame: CGRect) {
				super.init(frame: frame)
				backgroundColor = .white
				
				titleLabel.fillSuperview()
				addSubview(titleLabel)
				titleLabel.centerXToSuperview()
				titleLabel.centerYToSuperview()
				
				addSubview(underlineView)
				underlineView.anchor(top: titleLabel.bottomAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: frame.width, height: 2)
		}
		
		required init?(coder: NSCoder) {
				fatalError("init(coder:) has not been implemented")
		}
}

