//
//  Ext-Int.swift
//  KipasKipasDirectMessageUI
//
//  Created by DENAZMI on 20/07/23.
//

import Foundation

extension Int {
    func formatViews() -> String {
        let num = abs(Double(self))
        let sign = (self < 0) ? "-" : ""

        switch num {
        case 1_000_000_000...:
            var formatted = num / 1_000_000_000
            formatted = formatted.reduceScale(to: 1)
            return "\(sign)\(formatted)B"

        case 1_000_000...:
            var formatted = num / 1_000_000
            formatted = formatted.reduceScale(to: 1)
            return "\(sign)\(formatted)M"

        case 1_000...:
            var formatted = num / 1_000
            formatted = formatted.reduceScale(to: 1)
            return "\(sign)\(formatted)K"

        case 0...:
            return "\(self)"

        default:
            return "\(sign)\(self)"
        }
    }
    
    func timeAgoDisplay() -> String {
        return Date(timeIntervalSince1970: TimeInterval(self) / 1000).timeAgoDisplay()
    }
    
    func toDateString(with format: String = "dd-MM-yyyy") -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "id_ID")
        dateFormatter.timeZone = TimeZone(identifier: "GMT")
        dateFormatter.dateFormat = format
        let date = Date(timeIntervalSince1970: TimeInterval(self / 1000))
        let dateString = dateFormatter.string(from: date)
        return dateString
    }
    
    func toDate(with format: String = "dd-MM-yyyy") -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "id_ID")
        dateFormatter.timeZone = TimeZone(identifier: "GMT")
        dateFormatter.dateFormat = format
        let date = Date(timeIntervalSince1970: TimeInterval(self / 1000))
        return date
    }
    
    func toCurrency() -> String {
        let double = Int(self)

        let currencyFormatter = NumberFormatter()
        currencyFormatter.usesGroupingSeparator = true
        currencyFormatter.numberStyle = .currency
        currencyFormatter.locale = Locale(identifier: "ID_id")
        var money = currencyFormatter.string(from: NSNumber(value: double)) ?? "Rp 0"
        money.insert(" ", at: money.index(money.startIndex, offsetBy: 2))
        return money
    }
}
