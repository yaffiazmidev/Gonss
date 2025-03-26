//
//  CustomSelectButtonWithText.swift
//  KipasKipas
//
//  Created by Daniel Partogi on 26/08/20.
//  Copyright © 2020 Muhammad Noor. All rights reserved.
//

import UIKit

class CustomOptionButtonWithText: UIStackView {

	let options: [String]
	let checkBoxStyle: CheckBox.Style
	let margin: UIEdgeInsets
	let space: CGFloat

	public var valueChanged: ((_ isChecked: Bool, _ option: CustomOption) -> Void)?

	required init(options: [String], checkBoxStyle: CheckBox.Style = .square, margin: UIEdgeInsets, space: CGFloat) {
		self.options = options
		self.checkBoxStyle = checkBoxStyle
		self.margin = margin
		self.space = space
		super.init(frame: .zero)
		draw(.zero)
	}

	required init(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	override func draw(_ rect: CGRect) {

		axis = .vertical
		spacing = space
		layoutMargins = margin
		isLayoutMarginsRelativeArrangement = true


		options.forEach { option in

			let customOption = CustomOption(option: option)
			customOption.valueChanged = { check, opt in
				self.valueChanged?(check, opt)
			}

			addArrangedSubview(customOption)
		}
	}

}


class CustomOption : UIStackView {
	var option: String

	required init(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	public var valueChanged: ((_ isChecked: Bool, _ option: CustomOption) -> Void)?

	required init(option: String) {
		self.option = option
		super.init(frame: .zero)
		draw(.zero)
	}

	override func draw(_ rect: CGRect) {

		let label = UILabel(text: option, font: .Roboto(.medium, size: 12), textColor: .black, textAlignment: .left, numberOfLines: 1)

		let tickBox = CustomCheckBox(frame: CGRect(x: 30, y: 40, width: 25, height: 25))
		tickBox.borderStyle = .square
		tickBox.checkmarkStyle = .tick
		tickBox.checkmarkSize = 0.7
		tickBox.valueChanged = { (value) in
			self.check(value, self)
		}

		tickBox.heightAnchor.constraint(equalToConstant: 20).isActive = true
		tickBox.widthAnchor.constraint(equalToConstant: 20).isActive = true
		tickBox.setContentHuggingPriority(.defaultHigh, for: .horizontal)
		label.setContentHuggingPriority(.defaultLow, for: .horizontal)

		addArrangedSubview(label)
		addArrangedSubview(tickBox)
	}

	@objc func check(_ isChecked: Bool, _ sender: CustomOption) {
		valueChanged?(isChecked, sender)
	}
}
