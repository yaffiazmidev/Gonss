//
//  Int.swift
//  KipasKipas
//
//  Created by Daniel Partogi on 18/08/20.
//  Copyright © 2020 Muhammad Noor. All rights reserved.
//

import Foundation

extension Int {
	func toMoney() -> String {
		let double = Double(self)

		let currencyFormatter = NumberFormatter()
		currencyFormatter.usesGroupingSeparator = true
		currencyFormatter.numberStyle = .currency
		currencyFormatter.locale = Locale(identifier: "ID_id")
        var money = currencyFormatter.string(from: NSNumber(value: double)) ?? "Rp 0"
        money.insert(" ", at: money.index(money.startIndex, offsetBy: 2))
        return money
	}
}

extension Double {
	func toMoney() -> String {
		let double = Double(self)

		let currencyFormatter = NumberFormatter()
		currencyFormatter.usesGroupingSeparator = true
		currencyFormatter.numberStyle = .currency
		currencyFormatter.locale = Locale(identifier: "ID_id")
        var money = currencyFormatter.string(from: NSNumber(value: double)) ?? "Rp 0"
        money.insert(" ", at: money.index(money.startIndex, offsetBy: 2))
        return money
	}
}
