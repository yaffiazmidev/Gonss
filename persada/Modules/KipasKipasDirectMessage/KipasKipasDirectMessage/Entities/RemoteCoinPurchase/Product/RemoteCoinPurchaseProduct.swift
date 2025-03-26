//
//  RemoteCoinPurchaseProduct.swift
//  KipasKipasDirectMessage
//
//  Created by Rahmat Trinanda Pramudya Amar on 11/09/23.
//

import Foundation

///This data fetched from KipasKipas Rest
public struct RemoteCoinPurchaseProduct: Codable {
    
    enum CodingKeys: String, CodingKey {
        case data
        case code
        case message
    }
    
    public var data: [RemoteCoinPurchaseProductData]?
    public var code: String?
    public var message: String?
    
    
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        data = try container.decodeIfPresent([RemoteCoinPurchaseProductData].self, forKey: .data)
        code = try container.decodeIfPresent(String.self, forKey: .code)
        message = try container.decodeIfPresent(String.self, forKey: .message)
    }
    
}
