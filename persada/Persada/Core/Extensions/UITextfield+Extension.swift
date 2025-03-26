//
//  UITextfield+Extension.swift
//  KipasKipas
//
//  Created by Azam Mukhtar on 31/03/21.
//  Copyright © 2021 Koanba. All rights reserved.
//

import Foundation
import UIKit

private var __maxLengths = [UITextField: Int]()
extension UITextField {
		@IBInspectable var maxLength: Int {
				get {
						guard let l = __maxLengths[self] else {
								return 150 // (global default-limit. or just, Int.max)
						}
						return l
				}
				set {
						__maxLengths[self] = newValue
						addTarget(self, action: #selector(fix), for: .editingChanged)
				}
		}
		@objc func fix(textField: UITextField) {
				if let t = textField.text {
						textField.text = String(t.prefix(maxLength))
				}
		}
}
