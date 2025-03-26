//
//  RemoteFeedItemHashtags.swift
//
//  Created by DENAZMI on 04/10/23
//  Copyright (c) . All rights reserved.
//

import Foundation

public struct RemoteFeedItemHashtag: Codable {
    
    enum CodingKeys: String, CodingKey {
        case total
        case value
        case id
    }
    
    public var total: Int?
    public var value: String?
    public var id: String?
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        total = try container.decodeIfPresent(Int.self, forKey: .total)
        value = try container.decodeIfPresent(String.self, forKey: .value)
        id = try container.decodeIfPresent(String.self, forKey: .id)
    }
    
}
