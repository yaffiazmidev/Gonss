//
//  DRHTextFieldWithCharacterCount.swift
//  DRHTextFieldWithCharacterCount
//
//  Created by Stanislav Ostrovskiy on 8/29/16.
//  Copyright © 2016 Stanislav Ostrovskiy. All rights reserved.
//
import UIKit

//
//  DRHTextFieldWithCharacterCount.swift
//  Persada
//
//  Created by Muhammad Noor on 20/04/20.
//  Copyright © 2020 Muhammad Noor. All rights reserved.
//

import UIKit

@objc protocol DRHTextFieldWithCharacterCountDelegate{
	@objc func imageTapped()
	@objc func rightViewItem() -> UIView
}

class DRHTextFieldWithCharacterCount: UITextField {

	var lengthLimit: Int = 0
	let padding: CGFloat
    var paddingY: CGFloat
	var delegateIndented : DRHTextFieldWithCharacterCountDelegate?
	let prefix: String?
	var value: String {
		get {
			guard let text = text else { return "" }
			if let prefix = prefix {
				return String(text.dropFirst(prefix.count))
			}
			return text
		}
		set {
			if let prefix = prefix {
				text = prefix + newValue
				return
			}
			text = newValue
		}
	}
	var onBeginEditing: (String) -> Void = {_ in}
	var onEditing: (String) -> Void = {_ in}
	var onEndEditing: (String) -> Void = {_ in}

	public init(placeholder: String? = nil, padding: CGFloat = 0, paddingY: CGFloat = 6, cornerRadius: CGFloat = 0, keyboardType: UIKeyboardType = .default, backgroundColor: UIColor = .clear, isSecureTextEntry: Bool = false, borderWidth: CGFloat = 0, borderColor: UIColor = .gray, prefix: String? = nil) {
		self.padding = padding
        self.paddingY = paddingY
		self.prefix = prefix
		super.init(frame: .zero)
		layer.cornerRadius = cornerRadius
		self.backgroundColor = backgroundColor
		self.keyboardType = keyboardType
		self.isSecureTextEntry = isSecureTextEntry
		self.layer.borderWidth = borderWidth
		self.layer.borderColor = borderColor.cgColor
		self.font =  .Roboto(.medium, size: 12)
		self.attributedPlaceholder = NSAttributedString(string: placeholder ?? "", attributes: [NSAttributedString.Key.font : UIFont.Roboto(.regular, size: 12), NSAttributedString.Key.foregroundColor: UIColor.placeholder])
		text = prefix
		delegate = self
	}
	@objc func imageTapped(tapGestureRecognizer: UITapGestureRecognizer)
	{
		delegateIndented?.imageTapped()
		// Your action
	}

	func reload() {
		self.rightViewMode = UITextField.ViewMode.always
		let rightView = delegateIndented?.rightViewItem() ?? UIView()
		let view = UIView(frame: CGRect(
			x: 0, y: 0, // keep this as 0, 0
			width: rightView.frame.width + padding, // add the padding
			height: rightView.frame.height))
		view.addSubview(rightView)

		self.rightView = view
		let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
		self.rightView?.isUserInteractionEnabled = true
		self.rightView?.addGestureRecognizer(tapGestureRecognizer)

	}

	func addIndicator(_ asset: AssetEnum, _ color: UIColor, _ action: @escaping () -> ()){
		let img = UIImage(named: asset.rawValue)?.withTintColor(color, renderingMode: .alwaysOriginal)
		let img_view = UIImageView(image: img)
		img_view.translatesAutoresizingMaskIntoConstraints = false
		img_view.contentMode = .center
		img_view.onTap {
			action()
		}
		self.addSubview(img_view)
		NSLayoutConstraint.activate([
			img_view.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: 0),
			img_view.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -16),
			img_view.widthAnchor.constraint(equalToConstant: 24),
			img_view.heightAnchor.constraint(equalToConstant: 24)
		])
	}

	override open func textRect(forBounds bounds: CGRect) -> CGRect {
		return bounds.insetBy(dx: padding, dy: paddingY)
	}

	override open func editingRect(forBounds bounds: CGRect) -> CGRect {
		return bounds.insetBy(dx: padding, dy: paddingY)
	}

	required public init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

}

extension DRHTextFieldWithCharacterCount: UITextFieldDelegate {
	func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
		guard let text = textField.text , lengthLimit != 0 else { return true }
				
		let newLength = text.utf16.count + string.utf16.count - range.length
		
		return newLength <= lengthLimit
	}

	func textFieldDidBeginEditing(_ textField: UITextField) {
		onBeginEditing(textField.text ?? "")
	}

	func textFieldDidEndEditing(_ textField: UITextField) {
		onEndEditing("end edit \(textField.text)" ?? "")
	}
}
