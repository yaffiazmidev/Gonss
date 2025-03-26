//
//  RemoteCoinPurchaseProductData.swift
//  KipasKipasDirectMessage
//
//  Created by Rahmat Trinanda Pramudya Amar on 11/09/23.
//

import Foundation

///This data fetched from KipasKipas Rest
public struct RemoteCoinPurchaseProductData: Codable {
    
    enum CodingKeys: String, CodingKey {
        case id
        case storeProductId
        case qtyPerPackage
        case description
        case price
        case coinStore
    }
    
    public var id: String?
    public var storeProductId: String?
    public var qtyPerPackage: Int?
    public var description: String?
    public var price: Double?
    public var coinStore: RemoteCoinPurchaseProductStore?
    
    
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(String.self, forKey: .id)
        storeProductId = try container.decodeIfPresent(String.self, forKey: .storeProductId)
        qtyPerPackage = try container.decodeIfPresent(Int.self, forKey: .qtyPerPackage)
        description = try container.decodeIfPresent(String.self, forKey: .description)
        price = try container.decodeIfPresent(Double.self, forKey: .price)
        coinStore = try container.decodeIfPresent(RemoteCoinPurchaseProductStore.self, forKey: .coinStore)
    }
}
