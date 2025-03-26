//
//  UINavigationController.swift
//  KipasKipas
//
//  Created by Daniel Partogi on 12/10/20.
//  Copyright © 2020 Muhammad Noor. All rights reserved.
//

import UIKit

extension UINavigationController {
    func displayShadowToNavBar(status: Bool, _ color: UIColor = UIColor.lightGray, _ opacity: Float = 0.8, _ radius: CGFloat = 1) {
		if status {
			self.navigationBar.layer.masksToBounds = false
			self.navigationBar.layer.shadowColor = color.cgColor
			self.navigationBar.layer.shadowOpacity = opacity
			self.navigationBar.layer.shadowOffset = CGSize(width: 0, height: 1.0)
			self.navigationBar.layer.shadowRadius = radius
		} else {
			self.navigationBar.layer.masksToBounds = true
			self.navigationBar.layer.shadowColor = UIColor.white.cgColor
			self.navigationBar.layer.shadowOpacity = 0
			self.navigationBar.layer.shadowOffset = CGSize(width: 0, height: 0)
			self.navigationBar.layer.shadowRadius = 0
		}
		
	}
}
