//
//  RBOptionItem.swift
//  KipasKipas
//
//  Created by Daniel Partogi on 24/08/20.
//  Copyright © 2020 Muhammad Noor. All rights reserved.
//


import UIKit

protocol RBOptionItem {
	var text: OptionNames { get }
	var isSelected: Bool { get set }
	var font: UIFont { get set }
}

struct SortOrderOptionItem: RBOptionItem {
	var text: OptionNames
	var font = UIFont.Roboto(.regular, size: 13)
	var isSelected: Bool
}



struct SortByOptionItem: RBOptionItem {
	var text: OptionNames
	var font = UIFont.Roboto(.regular, size: 13)
	var isSelected: Bool
}

extension RBOptionItem {
	func sizeForDisplayText() -> CGSize {
		return text.rawValue.size(withAttributes: [NSAttributedString.Key.font: font])
	}
}

extension UITableViewCell {
	func configure(with optionItem: RBOptionItem) {
		textLabel?.text = optionItem.text.rawValue
		textLabel?.font = optionItem.font
		accessoryType = optionItem.isSelected ? .checkmark : .none
	}
}
