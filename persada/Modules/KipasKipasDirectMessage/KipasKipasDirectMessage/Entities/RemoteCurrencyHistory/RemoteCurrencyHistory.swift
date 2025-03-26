//
//  RemoteCurrencyHistory.swift
//
//  Created by DENAZMI on 28/08/23
//  Copyright (c) . All rights reserved.
//

import Foundation

public struct RemoteCurrencyHistory: Codable {
    
    enum CodingKeys: String, CodingKey {
        case data
        case message
        case code
    }
    
    public var data: RemoteCurrencyHistoryData?
    public var message: String?
    public var code: String?
    
    
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        data = try container.decodeIfPresent(RemoteCurrencyHistoryData.self, forKey: .data)
        message = try container.decodeIfPresent(String.self, forKey: .message)
        code = try container.decodeIfPresent(String.self, forKey: .code)
    }
    
}
