//
//  Ext-String.swift
//  KipasKipasDirectMessageUI
//
//  Created by DENAZMI on 15/07/23.
//

import Foundation

extension String {
    static func get(_ key: AssetEnum) -> String {
        return key.rawValue
    }
    
    static func get(_ key: StringEnum) -> String {
        return key.rawValue
    }
    
    func toDate(format: String = "dd/MM/yyyy HH:mm") -> String {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS"
        inputFormatter.locale = Locale(identifier: "id_ID")
        inputFormatter.timeZone = TimeZone(identifier: "GMT")
        
        guard let date = inputFormatter.date(from: self) else {
            return "-"
        }
        
        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = format
        inputFormatter.locale = Locale(identifier: "id_ID")
        inputFormatter.timeZone = TimeZone(identifier: "GMT")
        return outputFormatter.string(from: date)
    }
}
