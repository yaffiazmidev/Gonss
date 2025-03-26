//
//  RemoteCoinPurchaseValidateStore.swift
//  KipasKipasDirectMessage
//
//  Created by Rahmat Trinanda Pramudya Amar on 13/10/23.
//

import Foundation

///This data fetched from KipasKipas Rest
public struct RemoteCoinPurchaseValidateStore: Codable {
    
    enum CodingKeys: String, CodingKey {
        case id
        case storeName
    }
    
    public var id: String?
    public var storeName: String?
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(String.self, forKey: .id)
        storeName = try container.decodeIfPresent(String.self, forKey: .storeName)
    }
}
