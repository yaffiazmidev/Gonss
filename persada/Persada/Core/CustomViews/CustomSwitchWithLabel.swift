//
//  CustomSwitchWithLabel.swift
//  KipasKipas
//
//  Created by Daniel Partogi on 27/08/20.
//  Copyright © 2020 Muhammad Noor. All rights reserved.
//

import UIKit

protocol CustomSwitchWithLabelDelegate: AnyObject {
	func handleSwitch(sender: UISwitch, id: Int)
}

class CustomSwitchWithLabel: UIView {

	weak var delegate: CustomSwitchWithLabelDelegate?

	let labelName: String
	let id: Int
	let sizeScale: CGFloat
	var isChecked: Bool {
		didSet {
			switchVal.isOn = isChecked
		}
	}

	required init(label: String, sizeScale: CGFloat, isChecked: Bool, id: Int) {
		self.labelName = label
		self.sizeScale = sizeScale
		self.isChecked = isChecked
		self.id = id
		super.init(frame: .zero)
		draw(.zero)
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	lazy var label: UILabel = {
		let label: UILabel = UILabel()
		label.translatesAutoresizingMaskIntoConstraints = false
		label.textColor = .black
		label.text = self.labelName
		label.font = .Roboto(.medium, size: 12)
		return label
	}()

	lazy var switchVal: UISwitch = {
		let view = UISwitch()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.addTarget(self, action: #selector(self.handleSwitchValue(sender:)), for: .valueChanged)
		view.transform = CGAffineTransform(scaleX: self.sizeScale, y: self.sizeScale)
		view.isOn = false
        view.onTintColor = .primary

		return view
	}()

	override func draw(_ rect: CGRect) {
		addSubViews([self.label, self.switchVal])

		self.label.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: nil, paddingTop: 10, paddingLeft: 16, paddingBottom: 0, paddingRight: 0)
		self.switchVal.anchor(top: topAnchor, left: nil, bottom: bottomAnchor, right: rightAnchor, paddingTop: 10, paddingLeft: 0, paddingBottom: 0, paddingRight: 0)
	}

	@objc func handleSwitchValue(sender: UISwitch!) {
		delegate?.handleSwitch(sender: sender, id: self.id)
	}

}
