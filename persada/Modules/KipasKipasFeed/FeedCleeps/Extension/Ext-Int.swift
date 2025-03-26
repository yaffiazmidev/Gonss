//
//  Ext-Int.swift
//  FeedCleeps
//
//  Created by DENAZMI on 19/09/22.
//

import Foundation

public extension Int {
    public func countFormat() -> String {
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
    
    func toDateString(with format: String = "dd-MMM-yyyy") -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(identifier: "Asia/Jakarta")
        dateFormatter.dateFormat = format
        let date = Date(timeIntervalSince1970: TimeInterval(self / 1000))
        let dateString = dateFormatter.string(from: date)
        return dateString
    }
    
    func soMuchTimeAgoMini() -> String? {

        let diff = Date().timeIntervalSince1970 - Double(self) / 1000
        var str: String = ""
        if  diff < 60 {
                str = "now"
        } else if diff < 3600 {
                let out = Int(round(diff/60))
                str = (out == 1 ? "1m ago" : "\(out)m ago")
        } else if diff < 3600 * 24 {
                let out = Int(round(diff/3600))
                str = (out == 1 ? "1h ago" : "\(out)h ago")
        } else if diff < 3600 * 24 * 2 {
                str = "1d"
        } else if diff < 3600 * 24 * 7 {
                let out = Int(round(diff/(3600*24)))
                str = (out == 1 ? "1d ago" : "\(out)d ago")
        } else if diff < 3600 * 24 * 7 * 4{
                let out = Int(round(diff/(3600*24*7)))
                str = (out == 1 ? "1w ago" : "\(out)w ago")
        } else if diff < 3600 * 24 * 7 * 4 * 12{
                let out = Int(round(diff/(3600*24*7*4)))
                str = (out == 1 ? "1Month" : "\(out)Month ago")
        } else {//if diff < 3600 * 24 * 7 * 4 * 12{
                let out = Int(round(diff/(3600*24*7*4*12)))
                str = (out == 1 ? "1y" : "\(out)y")
        }
        return str
    }
}
