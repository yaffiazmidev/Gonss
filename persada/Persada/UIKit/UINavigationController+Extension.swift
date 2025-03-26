//
//  UINavigationController+Extension.swift
//  Persada
//
//  Created by movan on 22/07/20.
//  Copyright © 2020 Muhammad Noor. All rights reserved.
//

import UIKit

extension UINavigationController {
	
	public func setPlainBarStyle() {
		setPlainBar(with: .white)
	}
	
	public func setPlainBar(with color: UIColor) {
		self.navigationBar.isTranslucent = false
		self.navigationBar.shadowImage = nil
		self.view.backgroundColor = color
		self.navigationBar.setBackgroundImage(nil, for: .default)
		self.navigationBar.backgroundColor = color
		self.navigationBar.barTintColor = color
	}
	
	public func hideBarIfNecessary() {
		if self.isNavigationBarHidden != true {
			self.setNavigationBarHidden(true, animated: true)
		}
	}
	
	public func showBarIfNecessary() {
		if self.isNavigationBarHidden {
			self.setNavigationBarHidden(false, animated: true)
		}
	}
}

