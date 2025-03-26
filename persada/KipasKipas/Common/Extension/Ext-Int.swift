//
//  Ext-Int.swift
//  KipasKipas
//
//  Created by DENAZMI on 08/08/22.
//  Copyright © 2022 Koanba. All rights reserved.
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
        dateFormatter.timeZone = TimeZone(identifier: "Asia/Jakarta")
        dateFormatter.dateFormat = format
        let date = Date(timeIntervalSince1970: TimeInterval(self / 1000))
        let dateString = dateFormatter.string(from: date)
        return dateString
    }
    
    func toDate(with format: String = "dd-MM-yyyy") -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(identifier: "id_ID")
        dateFormatter.dateFormat = format
        let date = Date(timeIntervalSince1970: TimeInterval(self / 1000))
        return date
    }
}
