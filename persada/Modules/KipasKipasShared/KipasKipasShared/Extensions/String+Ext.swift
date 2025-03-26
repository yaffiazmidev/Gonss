//
//  String+Ext.swift
//  KipasKipasShared
//
//  Created by Rahmat Trinanda Pramudya Amar on 13/11/23.
//

import Foundation

extension String {
    static func get(_ key: AssetEnum) -> String {
        return key.rawValue
    }
    
    static func get(_ key: StringEnum) -> String {
        return key.rawValue.localized()
    }
    
    static func get(_ key: StringEnum, _ arguments: CVarArg...) -> String {
        return withVaList(arguments, { (params) -> String in
            return NSString(format: key.rawValue.localized(), arguments: params) as String
        })
    }
    
    func localized(withComment comment: String? = nil) -> String {
        return NSLocalizedString(self, comment: comment ?? "")
    }
}
