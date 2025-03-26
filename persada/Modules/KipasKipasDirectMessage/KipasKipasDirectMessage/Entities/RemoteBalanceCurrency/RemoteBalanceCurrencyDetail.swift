//
//  RemoteCurrencyHistoryData.swift
//
//  Created by DENAZMI on 28/08/23
//  Copyright (c) . All rights reserved.
//

import Foundation

public struct RemoteBalanceCurrencyDetail: Codable {
    
    enum CodingKeys: String, CodingKey {
        case id
        case coinAmount
        case diamondAmount
        case idrDmAmount
        case idrLiveAmount
        case liveDiamondAmount
        case verifIdentityStatus

    }
    
    public var id: String?
    public var coinAmount: Int?
    public var diamondAmount: Int?
    public var idrDmAmount:Int?
    public var idrLiveAmount:Int?
    public var liveDiamondAmount: Int?
    public var verifIdentityStatus: String
 
}
