//
//  CheckoutNoteItemCell.swift
//  Persada
//
//  Created by movan on 23/07/20.
//  Copyright © 2020 Muhammad Noor. All rights reserved.
//

import UIKit

class CheckoutNoteItemCell: UICollectionViewCell {
	
	var text: String? {
		didSet {
			textField.text = text
		}
	}
	
	lazy var titleLabel: UILabel = {
		let label: UILabel = UILabel( font: .AirBnbCereal(.book, size: 12), textColor: .black, textAlignment: .left, numberOfLines: 1)
		label.translatesAutoresizingMaskIntoConstraints = false
		return label
	}()
	
	lazy var subtitleLabel: UILabel = {
		let label: UILabel = UILabel( font: .AirBnbCereal(.book, size: 12), textColor: .secondary, textAlignment: .left, numberOfLines: 0)
		label.translatesAutoresizingMaskIntoConstraints = false
		label.text = ""
		label.textColor = .black
		return label
	}()
	
	lazy var textField: UITextField = {
		let text = UITextField()
		text.placeholder = "Warna, Varian, dll"
		text.layer.masksToBounds = false
		text.layer.cornerRadius = 8
		text.textColor = .black
		text.backgroundColor = .whiteSnow
		return text
	}()
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		
		titleLabel.constrainHeight(20)
		subtitleLabel.constrainHeight(20)
		
		stack(hstack(titleLabel, subtitleLabel, spacing: 4, alignment: .fill, distribution: .fillEqually),
					textField, spacing: 4, alignment: .fill, distribution: .fillProportionally)
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	func configure(title: String, subtitle: String, show: Bool) {
		titleLabel.text = title
		subtitleLabel.text = subtitle
		subtitleLabel.isHidden = !show
	}
	
}
