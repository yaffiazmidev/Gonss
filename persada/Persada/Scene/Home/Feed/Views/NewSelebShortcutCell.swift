//
//  NewSelebShortcutCell.swift
//  Persada
//
//  Created by NOOR on 23/06/20.
//  Copyright © 2020 Muhammad Noor. All rights reserved.
//

import UIKit

class NewSelebShortcutCell: UICollectionViewCell {

	// MARK:- Public Property
	
	private lazy var textButton: UIButton = {
		let button = UIButton(type: .system)
		button.tintColor = .orangeLowTint
		button.setTitleColor(.primary, for: .normal)
		button.layer.cornerRadius = 16
		button.layer.masksToBounds = false
		button.translatesAutoresizingMaskIntoConstraints = false
		button.addTarget(self, action: #selector(self.handleTextButton), for: .touchUpInside)
		return button
	}()
	
	var handleShortcut: (() -> Void)?

	// MARK:- Public Method

	deinit {
		handleShortcut = nil
	}

	override init(frame: CGRect) {
		super.init(frame: .zero)
		addSubview(textButton)
		textButton.fillSuperviewSafeAreaLayoutGuide()
	}

	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	
	@objc private func handleTextButton() {
		self.handleShortcut?()
	}
	
	func configure(text: String) {
		textButton.setTitle(text, for: .normal)
	}

}

