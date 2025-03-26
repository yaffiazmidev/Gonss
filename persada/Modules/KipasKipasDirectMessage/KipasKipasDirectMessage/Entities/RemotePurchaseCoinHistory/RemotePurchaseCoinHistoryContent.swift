//
//  RemotePurchaseCoinHistoryContent.swift
//
//  Created by DENAZMI on 25/08/23
//  Copyright (c) . All rights reserved.
//

import Foundation

public struct RemotePurchaseCoinHistoryContent: Codable {
    
    enum CodingKeys: String, CodingKey {
        case account
        case modifyAt
        case transactionId
        case historyType
        case createAt
        case nominal
        case status
        case id
        case currencyType
        case activityType
    }
    
    public var account: RemotePurchaseCoinHistoryAccount?
    public var modifyAt: String?
    public var transactionId: String?
    public var historyType: String?
    public var createAt: String?
    public var nominal: Int?
    public var status: String?
    public var id: String?
    public var currencyType: String?
    public var activityType: String?
    
    
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        account = try container.decodeIfPresent(RemotePurchaseCoinHistoryAccount.self, forKey: .account)
        modifyAt = try container.decodeIfPresent(String.self, forKey: .modifyAt)
        transactionId = try container.decodeIfPresent(String.self, forKey: .transactionId)
        historyType = try container.decodeIfPresent(String.self, forKey: .historyType)
        createAt = try container.decodeIfPresent(String.self, forKey: .createAt)
        nominal = try container.decodeIfPresent(Int.self, forKey: .nominal)
        status = try container.decodeIfPresent(String.self, forKey: .status)
        id = try container.decodeIfPresent(String.self, forKey: .id)
        currencyType = try container.decodeIfPresent(String.self, forKey: .currencyType)
        activityType = try container.decodeIfPresent(String.self, forKey: .activityType)
    }
    
}
