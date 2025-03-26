//
//  RemoteCurrencyHistoryContent.swift
//
//  Created by DENAZMI on 28/08/23
//  Copyright (c) . All rights reserved.
//

import Foundation

public struct RemoteCurrencyHistoryContent: Codable {
    
    enum CodingKeys: String, CodingKey {
        case status
        case id
        case activityType
        case historyType
        case transactionId
        case account
        case currencyType
        case modifyAt
        case createAt
        case chatChannelSession
        case nominal
    }
    
    public var status: String?
    public var id: String?
    public var activityType: String?
    public var historyType: String?
    public var transactionId: String?
    public var account: RemoteCurrencyHistoryAccount?
    public var currencyType: String?
    public var modifyAt: String?
    public var createAt: String?
    public var chatChannelSession: Int?
    public var nominal: Int?
    
    
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        status = try container.decodeIfPresent(String.self, forKey: .status)
        id = try container.decodeIfPresent(String.self, forKey: .id)
        activityType = try container.decodeIfPresent(String.self, forKey: .activityType)
        historyType = try container.decodeIfPresent(String.self, forKey: .historyType)
        transactionId = try container.decodeIfPresent(String.self, forKey: .transactionId)
        account = try container.decodeIfPresent(RemoteCurrencyHistoryAccount.self, forKey: .account)
        currencyType = try container.decodeIfPresent(String.self, forKey: .currencyType)
        modifyAt = try container.decodeIfPresent(String.self, forKey: .modifyAt)
        createAt = try container.decodeIfPresent(String.self, forKey: .createAt)
        chatChannelSession = try container.decodeIfPresent(Int.self, forKey: .chatChannelSession)
        nominal = try container.decodeIfPresent(Int.self, forKey: .nominal)
    }
    
}
