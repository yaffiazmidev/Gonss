//
//  RemoteCurrencyInfoData.swift
//  KipasKipasDirectMessage
//
//  Created by DENAZMI on 24/08/23.
//

import Foundation

public struct RemoteCurrencyInfoData: Codable {
    
    enum CodingKeys: String, CodingKey {
        case id
        case coinAmount
        case diamondAmount
    }
    
    public var id: String?
    public var coinAmount: Int?
    public var diamondAmount: Int?
    
    
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(String.self, forKey: .id)
        coinAmount = try container.decodeIfPresent(Int.self, forKey: .coinAmount)
        diamondAmount = try container.decodeIfPresent(Int.self, forKey: .diamondAmount)
    }
    
}
