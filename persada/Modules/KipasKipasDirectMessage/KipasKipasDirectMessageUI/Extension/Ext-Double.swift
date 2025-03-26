//
//  Ext-Double.swift
//  KipasKipasDirectMessageUI
//
//  Created by DENAZMI on 20/07/23.
//

import Foundation

extension Double {
    func reduceScale(to places: Int) -> Double {
        let multiplier = pow(10, Double(places))
        let newDecimal = multiplier * self // move the decimal right
        let truncated = Double(Int(newDecimal)) // drop the fraction
        let originalDecimal = truncated / multiplier // move the decimal back
        return originalDecimal
    }
    
    func toCurrency() -> String {
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
