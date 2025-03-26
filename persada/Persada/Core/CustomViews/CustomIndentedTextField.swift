//
//  CustomIndentedTextField.swift
//  Persada
//
//  Created by Muhammad Noor on 20/04/20.
//  Copyright © 2020 Muhammad Noor. All rights reserved.
//

import UIKit

@objc protocol IndentedTextFieldDelegate{
	@objc func imageTapped()
	@objc func rightViewItem() -> UIView
}

class CustomIndentedTextField: UITextField {

    var paddingY: CGFloat = 6.0
	let paddingX: CGFloat
	var delegateIndented : IndentedTextFieldDelegate?
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
    var isNumberOnly: Bool = false
    
    var onBeginEditing: (String) -> Void = {_ in}
    var onEditing: (String) -> Void = {_ in}
    var onEndEditing: (String) -> Void = {_ in}

    public init(placeholder: String? = nil, padding: CGFloat = 0, cornerRadius: CGFloat = 0, keyboardType: UIKeyboardType = .default, backgroundColor: UIColor = .clear, isSecureTextEntry: Bool = false, borderWidth: CGFloat = 0, borderColor: UIColor = .gray, prefix: String? = nil, isNumberOnly: Bool = false) {
        self.isNumberOnly = isNumberOnly
		self.paddingX = padding
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
        self.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
	}
    
    
    public init(placeholder: String? = nil, paddingX: CGFloat = 0, paddingY: CGFloat = 0, cornerRadius: CGFloat = 0, keyboardType: UIKeyboardType = .default, backgroundColor: UIColor = .clear, isSecureTextEntry: Bool = false, borderWidth: CGFloat = 0, borderColor: UIColor = .gray, prefix: String? = nil, isNumberOnly: Bool = false) {
        self.isNumberOnly = isNumberOnly
        self.paddingX = paddingX
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
        self.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)

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
			width: rightView.frame.width + paddingX, // add the padding
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
		return bounds.insetBy(dx: paddingX, dy: paddingY)
	}

	override open func editingRect(forBounds bounds: CGRect) -> CGRect {
		return bounds.insetBy(dx: paddingX, dy: paddingY)
	}

	required public init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

}

extension CustomIndentedTextField: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if isNumberOnly {
            let allowedCharacters = CharacterSet(charactersIn:"+0123456789")
            let characterSet = CharacterSet(charactersIn: string)
//            onEditing(textField.text ?? "")
            return allowedCharacters.isSuperset(of: characterSet)
        } else {
            guard let prefix = prefix else { return true }
            if range.location >= prefix.count {
//                onEditing(textField.text ?? "")
                return true
            }
        }
        
        return false
    }

    func textFieldDidBeginEditing(_ textField: UITextField) {
        onBeginEditing(textField.text ?? "")
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        onEndEditing(textField.text ?? "")
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        onEditing(textField.text ?? "")
    }
}

@objc protocol CustomIndentedTextFieldDelegate{
    @objc func imageTapped()
    @objc func rightViewItem() -> UIView
}

class CustomIndentedTextFieldWithButton: UITextField {
    
    let padding = UIEdgeInsets(top: 15, left: 15, bottom: 15, right: 15)
    
    override open func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }
    
    override open func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }
    
    override open func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }
    
}
