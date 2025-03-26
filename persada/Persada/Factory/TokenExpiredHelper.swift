//
//  TokenExpired.swift
//  KipasKipas
//
//  Created by PT.Koanba on 29/12/22.
//  Copyright © 2022 Koanba. All rights reserved.
//

import Foundation

class TokenExpiredHelper {
    static func getMinusSecond(file: String = #file, function: String = #function, line: Int = #line) -> Int {
        var second = 60
        #if Release || ProdDebug
        let twelveHoursInSecond = 43200
        second = twelveHoursInSecond
        #endif

        return second
    }
}
