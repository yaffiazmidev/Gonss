//
//  RemoteCurrencyHistoryDetail.swift
//
//  Created by DENAZMI on 11/09/23
//  Copyright (c) . All rights reserved.
//

import Foundation

public struct RemoteCurrencyHistoryDetail: Codable {
    
    enum CodingKeys: String, CodingKey {
        case data
        case message
        case code
    }
    
    public var data: RemoteCurrencyHistoryDetailData?
    public var message: String?
    public var code: String?
    
    
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        data = try container.decodeIfPresent(RemoteCurrencyHistoryDetailData.self, forKey: .data)
        message = try container.decodeIfPresent(String.self, forKey: .message)
        code = try container.decodeIfPresent(String.self, forKey: .code)
    }
    
}
