//
//  TokenHelper.swift
//  KipasKipasNetworking
//
//  Created by PT.Koanba on 19/12/22.
//

import Foundation

public final class TokenHelper {
    public static func addSecondToCurrentDate(second: Int) -> Date {
        var dayComponent = DateComponents()
        dayComponent.second = second
        let datePlusTheSecond = Calendar.current.date(byAdding: dayComponent, to: Date())!
        return datePlusTheSecond
    }
    
    public static func convertStringToDate(dateString: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        return dateFormatter.date(from: dateString)
    }

    public static func convertDateToString(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        return dateFormatter.string(from: date)
    }
}
