//
//  IndentedTextFieldCustom.swift
//  KipasKipas
//
//  Created by Azam Mukhtar on 30/03/21.
//  Copyright © 2021 Koanba. All rights reserved.
//

import UIKit


class InsetTextField : UITextField {
	
	var placeholderText : String? {
		didSet {
			attributedPlaceholder = NSAttributedString(string: placeholderText ?? "", attributes: [NSAttributedString.Key.font : UIFont.Roboto(.regular, size: 12), NSAttributedString.Key.foregroundColor: UIColor.placeholder])
		}
	}
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		layer.borderColor = UIColor.black25.cgColor
		layer.cornerRadius = 8
		layer.borderWidth = 0.5
		textColor = .grey
		font = .Roboto(.regular, size: 12)
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func textRect(forBounds bounds: CGRect) -> CGRect {
		return bounds.insetBy(dx: 10, dy: 10)
	}
	override func editingRect(forBounds bounds: CGRect) -> CGRect {
		return bounds.insetBy(dx: 10, dy: 10)
	}
}
