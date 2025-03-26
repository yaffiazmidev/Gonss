//
//  CheckoutCourierItemCell.swift
//  Persada
//
//  Created by movan on 23/07/20.
//  Copyright © 2020 Muhammad Noor. All rights reserved.
//

import UIKit

class CheckoutCourierItemCell: UICollectionViewCell {
	
	var value: String? {
		didSet {
			self.chooseButton.setTitle(value, for: .normal)
		}
	}
	
	var handlerCourier: (() -> Void)?
	
	lazy var titleLabel: UILabel = {
		let label: UILabel = UILabel()
		label.text = "Pilih Kurir & Durasi Pengiriman"
		label.textColor = .black
		return label
	}()
	
	lazy var subtitleLabel: UILabel = {
		let label: UILabel = UILabel()
		label.textColor = .black
		label.text = "Pilih Kurir"
		return label
	}()
	
	lazy var chooseButton: UIButton = {
		let button = UIButton(type: .system)
		button.contentHorizontalAlignment = .leading
		button.backgroundColor = .whiteSnow
		button.layer.masksToBounds = false
		button.layer.cornerRadius = 16
		button.addTarget(self, action: #selector(handleButton), for: .touchUpInside)
		return button
	}()
	
	lazy var buttonView: UIView = {
		let view: UIView = UIView()
		[chooseButton, subtitleLabel].forEach { view.addSubview($0) }
		subtitleLabel.fillSuperview()
		chooseButton.fillSuperview()
		return view
	}()
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		
		[titleLabel, buttonView].forEach { view in
			view.translatesAutoresizingMaskIntoConstraints = false
			addSubview(view)
		}
		
		subtitleLabel.text = "Pilih Kurir"
		
		titleLabel.anchor(top: safeAreaLayoutGuide.topAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 8, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 30)
		
		buttonView.anchor(top: titleLabel.bottomAnchor, left: leftAnchor, bottom: safeAreaLayoutGuide.bottomAnchor, right: rightAnchor, paddingTop: 8, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	func configure(title: String, subtitle: String, show: Bool) {
		titleLabel.text = title
		subtitleLabel.text = subtitle
		subtitleLabel.textColor = .systemBlue
		subtitleLabel.isHidden = !show
	}
	
	@objc func handleButton() {
		self.handlerCourier?()
	}
}

