//
//  RemoteChatRank.swift
//
//  Created by DENAZMI on 23/08/23
//  Copyright (c) . All rights reserved.
//

import Foundation

public struct RemoteChatRank: Codable {
    
    enum CodingKeys: String, CodingKey {
        case data
        case code
        case message
    }
    
    public var data: [RemoteChatRankData]?
    public var code: String?
    public var message: String?
    
    
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        data = try container.decodeIfPresent([RemoteChatRankData].self, forKey: .data)
        code = try container.decodeIfPresent(String.self, forKey: .code)
        message = try container.decodeIfPresent(String.self, forKey: .message)
    }
    
}
