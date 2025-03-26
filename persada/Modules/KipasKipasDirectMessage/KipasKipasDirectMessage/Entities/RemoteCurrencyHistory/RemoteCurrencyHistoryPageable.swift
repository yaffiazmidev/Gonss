//
//  RemoteCurrencyHistoryPageable.swift
//
//  Created by DENAZMI on 28/08/23
//  Copyright (c) . All rights reserved.
//

import Foundation

public struct RemoteCurrencyHistoryPageable: Codable {
    
    enum CodingKeys: String, CodingKey {
        case paged
        case pageNumber
        case sort
        case unpaged
        case offset
        case pageSize
    }
    
    public var paged: Bool?
    public var pageNumber: Int?
    public var sort: RemoteCurrencyHistorySort?
    public var unpaged: Bool?
    public var offset: Int?
    public var pageSize: Int?
    
    
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        paged = try container.decodeIfPresent(Bool.self, forKey: .paged)
        pageNumber = try container.decodeIfPresent(Int.self, forKey: .pageNumber)
        sort = try container.decodeIfPresent(RemoteCurrencyHistorySort.self, forKey: .sort)
        unpaged = try container.decodeIfPresent(Bool.self, forKey: .unpaged)
        offset = try container.decodeIfPresent(Int.self, forKey: .offset)
        pageSize = try container.decodeIfPresent(Int.self, forKey: .pageSize)
    }
    
}
