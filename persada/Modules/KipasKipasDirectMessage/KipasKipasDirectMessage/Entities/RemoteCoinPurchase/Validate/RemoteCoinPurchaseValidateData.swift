//
//  RemoteCoinPurchaseValidateData.swift
//  KipasKipasDirectMessage
//
//  Created by Rahmat Trinanda Pramudya Amar on 13/10/23.
//

import Foundation

///This data fetched from KipasKipas Rest
public struct RemoteCoinPurchaseValidateData: Codable {
    
    enum CodingKeys: String, CodingKey {
        case orderCoin
        case notificationId
    }
    
    public var orderCoin: RemoteCoinPurchaseValidateOrder?
    public var notificationId: String?
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        orderCoin = try container.decodeIfPresent(RemoteCoinPurchaseValidateOrder.self, forKey: .orderCoin)
        notificationId = try container.decodeIfPresent(String.self, forKey: .notificationId)
    }
}
