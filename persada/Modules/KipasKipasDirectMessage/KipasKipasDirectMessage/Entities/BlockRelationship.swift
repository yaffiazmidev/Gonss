//
//  BlockRelationship.swift
//  KipasKipasDirectMessage
//
//  Created by MissYasiky on 2024/5/9.
//

import Foundation

public struct BlockRelationship: Codable {
    public enum CodingKeys: String, CodingKey {
        case data
        case code
        case message
    }

    public var data: BlockRelationshipData?
    public var code: String?
    public var message: String?

    public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    data = try container.decodeIfPresent(BlockRelationshipData.self, forKey: .data)
    code = try container.decodeIfPresent(String.self, forKey: .code)
    message = try container.decodeIfPresent(String.self, forKey: .message)
  }
}

public struct BlockRelationshipData: Codable {
    
    public enum CodingKeys: String, CodingKey {
        case isBlocked
        case isBlockedBy
    }

    public var isBlocked: Bool?
    public var isBlockedBy: Bool?



    public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    isBlocked = try container.decodeIfPresent(Bool.self, forKey: .isBlocked)
    isBlockedBy = try container.decodeIfPresent(Bool.self, forKey: .isBlockedBy)
  }
}
