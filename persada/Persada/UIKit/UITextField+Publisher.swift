//
//  UITextField+Publisher.swift
//  Persada
//
//  Created by movan on 20/07/20.
//  Copyright © 2020 Muhammad Noor. All rights reserved.
//

import UIKit
import Combine

extension UITextField {
	var textPublisher: AnyPublisher<String, Never> {
		NotificationCenter.default
			.publisher(for: UITextField.textDidChangeNotification, object: self)
			.compactMap { $0.object as? UITextField } // receiving notifications with objects which are instances of UITextFields
			.map { $0.text ?? "" } // mapping UITextField to extract text
			.eraseToAnyPublisher()
	}
    
    
    public convenience init(placeholder: String) {
        self.init()
        self.placeholder = placeholder
    }
}

