//
//  RemotePurchaseCoinHistory.swift
//
//  Created by DENAZMI on 25/08/23
//  Copyright (c) . All rights reserved.
//

import Foundation

public struct RemotePurchaseCoinHistory: Codable {
    
    enum CodingKeys: String, CodingKey {
        case message
        case code
        case data
    }
    
    public var message: String?
    public var code: String?
    public var data: RemotePurchaseCoinHistoryData?
    
    
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        message = try container.decodeIfPresent(String.self, forKey: .message)
        code = try container.decodeIfPresent(String.self, forKey: .code)
        data = try container.decodeIfPresent(RemotePurchaseCoinHistoryData.self, forKey: .data)
    }
    
}
