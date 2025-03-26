//
//  CheckoutAddressItemCell.swift
//  Persada
//
//  Created by movan on 23/07/20.
//  Copyright © 2020 Muhammad Noor. All rights reserved.
//

import UIKit

class CheckoutAddressItemCell: UICollectionViewCell {
	
	var value: String? {
		didSet {
			self.addressLabel.text = value
		}
	}
	
	var handler: (() -> Void)?
	
	lazy var titleLabel: UILabel = {
		let label: UILabel = UILabel(text: .get(.diKirimKe), font: .AirBnbCereal(.bold, size: 12), textColor: .black, textAlignment: .left, numberOfLines: 0)
		label.translatesAutoresizingMaskIntoConstraints = false
		return label
	}()
	
	lazy var subtitleLabel: UILabel = {
		let label: UILabel = UILabel(text: .get(.tambahAlamat), font: .AirBnbCereal(.book, size: 12), textColor: .secondary, textAlignment: .right, numberOfLines: 1)
		label.translatesAutoresizingMaskIntoConstraints = false
		label.tintColor = .systemBlue
		label.isUserInteractionEnabled = true
		let imageTapGesture = UITapGestureRecognizer(target: self, action: #selector(handleWhenTappedLabel))
		label.addGestureRecognizer(imageTapGesture)
		return label
	}()
	
	lazy var addressLabel: UILabel = {
		let label: UILabel = UILabel(text: .get(.belumAdaAlamatTerpilih), font: .AirBnbCereal(.book, size: 13), textColor: .black, textAlignment: .left, numberOfLines: 0)
		label.translatesAutoresizingMaskIntoConstraints = false
		return label
	}()
	
	override init(frame: CGRect) {
		super.init(frame: frame)

		titleLabel.constrainHeight(20)
		subtitleLabel.constrainHeight(20)
		
		stack(hstack(titleLabel, subtitleLabel), addressLabel, spacing: 8, alignment: .fill, distribution: .fillProportionally)
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	func configure(title: String, text: String, show: Bool) {
		titleLabel.text = title
		addressLabel.text = text
	}
	
	@objc func handleWhenTappedLabel() {
		self.handler?()
	}
	
}
