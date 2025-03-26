//
//  RemoteCoinPurchaseValidate.swift
//  KipasKipasDirectMessage
//
//  Created by Rahmat Trinanda Pramudya Amar on 13/10/23.
//

import Foundation

///This data fetched from KipasKipas Rest
public struct RemoteCoinPurchaseValidate: Codable {
    
    enum CodingKeys: String, CodingKey {
        case data
        case code
        case message
    }
    
    public var data: RemoteCoinPurchaseValidateData?
    public var code: String?
    public var message: String?
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        data = try container.decodeIfPresent(RemoteCoinPurchaseValidateData.self, forKey: .data)
        code = try container.decodeIfPresent(String.self, forKey: .code)
        message = try container.decodeIfPresent(String.self, forKey: .message)
    }
    
}
