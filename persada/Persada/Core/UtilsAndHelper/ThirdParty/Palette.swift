//
//  Palette.swift
//  RnDPersada
//
//  Created by Muhammad Noor on 11/04/20.
//  Copyright © 2020 Muhammad Noor. All rights reserved.
//

import UIKit

struct Palette {
	static let defaultTextColor = Palette.colorFromRGB(9, green: 26, blue: 51, alpha: 0.4)
	static let highlightTextColor: UIColor = .white
	static let segmentedControlBackgroundColor: UIColor = .contentGrey
	static let sliderColor: UIColor = .gradientStoryOne
	
	static func colorFromRGB(_ red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat = 1.0) -> UIColor {
		func amount(_ amount: CGFloat, with alpha: CGFloat) -> CGFloat {
			return (1 - alpha) * 255 + alpha * amount
		}
		
		let red = amount(red, with: alpha)/255
		let green = amount(green, with: alpha)/255
		let blue = amount(blue, with: alpha)/255
		return UIColor(red: red, green: green, blue: blue, alpha: 1)
	}
	
}
