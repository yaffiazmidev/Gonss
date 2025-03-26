//
//  AreasItemCell.swift
//  KipasKipas
//
//  Created by movan on 12/08/20.
//  Copyright © 2020 Muhammad Noor. All rights reserved.
//

import UIKit

class AreasItemCell: UITableViewCell {
	
	var item: String? {
		didSet {
			nameLabel.text = item ?? "-"
		}
	}
	
	lazy var nameLabel: UILabel = {
		let label: UILabel = UILabel(text: .get(.askingReport), font: .Roboto(.regular, size: 12), textColor: .gray, textAlignment: .left, numberOfLines: 0)
		label.translatesAutoresizingMaskIntoConstraints = false
		label.backgroundColor = .white
		return label
	}()
	
	var highlightIndicator: UIView = {
		let view: UIView = UIView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.backgroundColor = .primaryLowTint
		view.layer.masksToBounds = false
		view.layer.cornerRadius = 10
		view.backgroundColor = .white
		view.isHidden = true
		return view
	}()
	
	
	override var isHighlighted: Bool {
		didSet {
			highlightIndicator.isHidden = !isHighlighted
		}
	}
	
	override var isSelected: Bool {
		didSet {
			if isSelected {
				nameLabel.layer.backgroundColor = UIColor.orangeLowTint.cgColor
			} else {
				nameLabel.layer.backgroundColor = UIColor.white.cgColor
			}
		}
	}

	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		contentView.backgroundColor = .white
		backgroundColor = .white
		selectionStyle = .none
		
		contentView.addSubview(highlightIndicator)
		highlightIndicator.anchor(top: topAnchor, leading: leadingAnchor, bottom: bottomAnchor, trailing: trailingAnchor)
		
		contentView.addSubview(nameLabel)
		nameLabel.anchor(top: contentView.topAnchor, left: contentView.leftAnchor, bottom: contentView.bottomAnchor, right: contentView.rightAnchor, paddingTop: 16, paddingLeft: 20, paddingBottom: 18, paddingRight: 20)
		nameLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: 10).isActive = true
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}
