//
//  Date+Extension.swift
//  KipasKipasShared
//
//  Created by Rahmat Trinanda Pramudya Amar on 03/11/23.
//

import Foundation

public extension Date {
    var millisecondsSince1970:Int64 {
        Int64((self.timeIntervalSince1970 * 1000.0).rounded())
    }
    
    init(milliseconds:Int64) {
        self = Date(timeIntervalSince1970: TimeInterval(milliseconds) / 1000)
    }
}
