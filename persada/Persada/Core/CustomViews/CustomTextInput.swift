//
//  CustomTextInput.swift
//  KipasKipas
//
//  Created by Daniel Partogi on 26/08/20.
//  Copyright © 2020 Muhammad Noor. All rights reserved.
//

import UIKit

class CustomTextInput: UIView {

	// MARK: - Public Property

	let type: UIKeyboardType
	let prefix: String?
	var placeholder: String {
		didSet {
			textField.placeholder = placeholder
		}
	}
	var labelTitle: String {
		didSet {
			label.text = labelTitle
		}
	}
	var titleColor: UIColor {
		didSet {
			label.textColor = titleColor
		}
	}

	lazy var label: UILabel = {
		let label = UILabel(text: labelTitle, font: .Roboto(.medium, size:12), textColor: .black, textAlignment: .left, numberOfLines: 0)
		label.textColor = .placeholder
		return label
	}()

	lazy var textField: CustomIndentedTextField = {
		let tf :CustomIndentedTextField = CustomIndentedTextField(placeholder: placeholder, padding: 16, cornerRadius: 8, keyboardType: type, isSecureTextEntry: false, prefix: prefix)
		tf.contentVerticalAlignment = .fill
		tf.font = .Roboto(.medium, size: 12)
		tf.textColor = .black
		//todo prefix
		return tf
	}()

	let viewFrame = UIView()

	// MARK: - Public Method

	required init(keyboardType: UIKeyboardType = .default, labelTitle: String, placeholder: String, labelColor: UIColor = .placeholder, textColor: UIColor = .black, textSize: CGFloat = 12, borderWidth: CGFloat = 1, borderColor: UIColor = .whiteSmoke, borderRadius: CGFloat = 8, prefix: String? = nil) {

		self.labelTitle = labelTitle
		self.placeholder = placeholder
		self.titleColor = labelColor
		self.type = keyboardType
		self.prefix = prefix

		super.init(frame: .zero)

		textField.font = .Roboto(.medium, size: textSize)
		textField.layer.borderWidth = borderWidth
		textField.layer.borderColor = borderColor.cgColor
		textField.layer.cornerRadius = borderRadius

		draw(.zero)
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}



	override func draw(_ rect: CGRect) {
		super .draw(rect)

		addSubview(viewFrame)
		viewFrame.translatesAutoresizingMaskIntoConstraints = false
		viewFrame.fillSuperview()

		viewFrame.addSubview(label)
		viewFrame.addSubview(textField)

		label.anchor(top: viewFrame.topAnchor, left: viewFrame.leftAnchor, bottom: nil, right: viewFrame.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)

		textField.anchor(top: label.bottomAnchor, left: viewFrame.leftAnchor, bottom: viewFrame.safeAreaLayoutGuide.bottomAnchor, right: viewFrame.rightAnchor, paddingTop: 4, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)

		label.textColor = titleColor

	}



	func textFieldIsEmpty() -> Bool  {
		if textField.text?.isEmpty ?? false {
			return false
		} else {
			return true
		}
	}
    
    func addIndicator(_ asset: AssetEnum, _ color: UIColor, _ action: @escaping () -> ()){
        let img = UIImage(named: asset.rawValue)?.withTintColor(color, renderingMode: .alwaysOriginal)
        let img_view = UIImageView(image: img)
        img_view.translatesAutoresizingMaskIntoConstraints = false
        img_view.contentMode = .center
        img_view.onTap {
            action()
        }
        textField.addSubview(img_view)
        NSLayoutConstraint.activate([
            img_view.centerYAnchor.constraint(equalTo: textField.centerYAnchor, constant: 0),
            img_view.trailingAnchor.constraint(equalTo: textField.trailingAnchor, constant: -16),
            img_view.widthAnchor.constraint(equalToConstant: 24),
            img_view.heightAnchor.constraint(equalToConstant: 24)
        ])
    }

}
