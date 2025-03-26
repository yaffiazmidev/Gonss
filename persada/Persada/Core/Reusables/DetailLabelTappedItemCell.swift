//
//  DetailLabelTappedItemCell.swift
//  KipasKipas
//
//  Created by movan on 14/08/20.
//  Copyright © 2020 Muhammad Noor. All rights reserved.
//

import UIKit

class DetailLabelTappedItemCell: UITableViewCell {
	
	var handler: (() -> Void)?
	
	private enum ViewTrait {
		static let padding: CGFloat = 16
	}
	
	lazy var customLabel: CustomTappedLabel = {
		let view = CustomTappedLabel()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.backgroundColor = .whiteSnow
		view.isUserInteractionEnabled = true
		view.layer.masksToBounds = false
		view.layer.cornerRadius = 8
		let gesture = UITapGestureRecognizer(target: self, action: #selector(handleGesture(_:)))
		view.addGestureRecognizer(gesture)
		return view
	}()

	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		backgroundColor = .white
		addSubview(customLabel)
		customLabel.fillSuperviewSafeAreaLayoutGuide(padding: UIEdgeInsets(top: ViewTrait.padding, left: ViewTrait.padding, bottom: ViewTrait.padding, right: ViewTrait.padding))
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	@objc private func handleGesture(_ sender: UITapGestureRecognizer) {
		self.handler?()
	}
}
