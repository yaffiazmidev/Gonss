//
//  RemoteCurrencyInfo.swift
//  KipasKipasDirectMessage
//
//  Created by DENAZMI on 24/08/23.
//

import Foundation

public struct RemoteCurrencyInfo: Codable {
    
    enum CodingKeys: String, CodingKey {
        case data
        case code
        case message
    }
    
    public var data: RemoteCurrencyInfoData?
    public var code: String?
    public var message: String?
    
    
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        data = try container.decodeIfPresent(RemoteCurrencyInfoData.self, forKey: .data)
        code = try container.decodeIfPresent(String.self, forKey: .code)
        message = try container.decodeIfPresent(String.self, forKey: .message)
    }
    
}
