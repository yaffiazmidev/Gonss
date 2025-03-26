//
//  RemoteCurrencyInfo.swift
//  FeedCleeps
//
//  Created by DENAZMI on 20/11/23.
//

import Foundation

struct RemoteCurrencyInfo: Codable {
    var data: RemoteCurrencyInfoData?
    var code: String?
    var message: String?
}

struct RemoteCurrencyInfoData: Codable {
    
    var id: String?
    var coinAmount: Int?
    var diamondAmount: Int?
}
