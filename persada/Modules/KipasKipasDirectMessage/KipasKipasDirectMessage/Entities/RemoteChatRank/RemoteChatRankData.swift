//
//  RemoteChatRankData.swift
//
//  Created by DENAZMI on 23/08/23
//  Copyright (c) . All rights reserved.
//

import Foundation

public struct RemoteChatRankData: Codable {
    
    enum CodingKeys: String, CodingKey {
        case accountId
        case photo
        case name
        case chatReplyCount
        case isDisabled
        case accountType
        case isVerified
        case totalFollowers
    }
    
    public var accountId: String?
    public var photo: String?
    public var name: String?
    public var chatReplyCount: Int?
    public var isDisabled: Bool?
    public var accountType: String?
    public var isVerified: Bool?
    public var totalFollowers: Int?
    
    
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        accountId = try container.decodeIfPresent(String.self, forKey: .accountId)
        photo = try container.decodeIfPresent(String.self, forKey: .photo)
        name = try container.decodeIfPresent(String.self, forKey: .name)
        chatReplyCount = try container.decodeIfPresent(Int.self, forKey: .chatReplyCount)
        isDisabled = try container.decodeIfPresent(Bool.self, forKey: .isDisabled)
        accountType = try container.decodeIfPresent(String.self, forKey: .accountType)
        isVerified = try container.decodeIfPresent(Bool.self, forKey: .isVerified)
        totalFollowers = try container.decodeIfPresent(Int.self, forKey: .totalFollowers)
    }
    
}
