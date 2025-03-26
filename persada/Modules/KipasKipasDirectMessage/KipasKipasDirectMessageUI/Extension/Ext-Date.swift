//
//  Ext-Date.swift
//  KipasKipasDirectMessageUI
//
//  Created by DENAZMI on 20/07/23.
//

import Foundation

extension Date {
    
    static func - (lhs: Date, rhs: Date) -> TimeInterval {
        return lhs.timeIntervalSinceReferenceDate - rhs.timeIntervalSinceReferenceDate
    }
    
    func timeAgoDisplay() -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short
        let removeAgo = formatter.localizedString(for: self, relativeTo: Date()).replacingOccurrences(of: " ago", with: "")
        
        guard !removeAgo.contains("min") else {
            return self.sbu_toString(format: .HHmm)
        }
        
        guard !removeAgo.contains(" hr") else {
            return removeAgo.replacingOccurrences(of: " hr", with: "h")
        }
        
        guard !removeAgo.contains(" days ago") else {
            return removeAgo.replacingOccurrences(of: " days ago", with: "d")
        }
        
        guard !removeAgo.contains(" wk") else {
            return removeAgo.replacingOccurrences(of: " wk", with: "w")
        }
        
        guard !removeAgo.contains(" mo") else {
            return removeAgo.replacingOccurrences(of: " mo", with: "mo")
        }
        
        return removeAgo
    }
    
    var millisecondsSince1970: Int64 {
        return Int64((self.timeIntervalSince1970 * 1000.0).rounded())
    }
    
    init(milliseconds:Int64) {
        self = Date(timeIntervalSince1970: TimeInterval(milliseconds) / 1000)
    }
    
    func toString(format: String = "dd/MM/yyyy") -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "id_ID")
        formatter.timeZone = TimeZone(identifier: "GMT")
        formatter.dateStyle = .short
        formatter.dateFormat = format
        return formatter.string(from: self)
    }
    
    var startOfDay: Date {
        return Calendar.current.startOfDay(for: self)
    }
    
    var endOfDay: Date {
        let cal = Calendar.current
        var components = DateComponents()
        components.day = 1
        return cal.date(byAdding: components, to: self.startOfDay)!.addingTimeInterval(-1)
    }
    
    func removeMonths(numberOfMonths: Int) -> Date {
        let endDate = Calendar.current.date(byAdding: .month, value: -numberOfMonths, to: self)
        return endDate ?? Date()
    }
}
