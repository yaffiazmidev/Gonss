//
//  RemotePurchaseCoinHistoryPageable.swift
//
//  Created by DENAZMI on 25/08/23
//  Copyright (c) . All rights reserved.
//

import Foundation

public struct RemotePurchaseCoinHistoryPageable: Codable {
    
    enum CodingKeys: String, CodingKey {
        case sort
        case pageNumber
        case paged
        case pageSize
        case unpaged
        case offset
    }
    
    public var sort: RemotePurchaseCoinHistorySort?
    public var pageNumber: Int?
    public var paged: Bool?
    public var pageSize: Int?
    public var unpaged: Bool?
    public var offset: Int?
    
    
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        sort = try container.decodeIfPresent(RemotePurchaseCoinHistorySort.self, forKey: .sort)
        pageNumber = try container.decodeIfPresent(Int.self, forKey: .pageNumber)
        paged = try container.decodeIfPresent(Bool.self, forKey: .paged)
        pageSize = try container.decodeIfPresent(Int.self, forKey: .pageSize)
        unpaged = try container.decodeIfPresent(Bool.self, forKey: .unpaged)
        offset = try container.decodeIfPresent(Int.self, forKey: .offset)
    }
    
}
