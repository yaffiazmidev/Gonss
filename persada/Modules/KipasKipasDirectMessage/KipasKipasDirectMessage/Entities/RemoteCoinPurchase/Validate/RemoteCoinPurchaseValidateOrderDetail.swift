//
//  RemoteCoinPurchaseValidateOrderDetail.swift
//  KipasKipasDirectMessage
//
//  Created by Rahmat Trinanda Pramudya Amar on 13/10/23.
//

import Foundation

///This data fetched from KipasKipas Rest
public struct RemoteCoinPurchaseValidateOrderDetail: Codable {
    
    enum CodingKeys: String, CodingKey {
        case id
        case coinId
        case coinName
        case coinPrice
        case coinAmount
        case storeProductId
        case qty
        case storeEventTime
        case totalAmount
    }
    
    public var id: String?
    public var coinId: String?
    public var coinName: String?
    public var coinPrice: Double?
    public var coinAmount: Int?
    public var storeProductId: String?
    public var qty: Int?
    public var storeEventTime: String?
    public var totalAmount: Double?
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(String.self, forKey: .id)
        coinId = try container.decodeIfPresent(String.self, forKey: .coinId)
        coinName = try container.decodeIfPresent(String.self, forKey: .coinName)
        coinPrice = try container.decodeIfPresent(Double.self, forKey: .coinPrice)
        coinAmount = try container.decodeIfPresent(Int.self, forKey: .coinAmount)
        storeProductId = try container.decodeIfPresent(String.self, forKey: .storeProductId)
        qty = try container.decodeIfPresent(Int.self, forKey: .qty)
        storeEventTime = try container.decodeIfPresent(String.self, forKey: .storeEventTime)
        totalAmount = try container.decodeIfPresent(Double.self, forKey: .totalAmount)
    }
}
