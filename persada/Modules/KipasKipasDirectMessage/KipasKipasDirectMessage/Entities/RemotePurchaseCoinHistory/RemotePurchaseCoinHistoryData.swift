//
//  RemotePurchaseCoinHistoryData.swift
//
//  Created by DENAZMI on 25/08/23
//  Copyright (c) . All rights reserved.
//

import Foundation

public struct RemotePurchaseCoinHistoryData: Codable {
    
    enum CodingKeys: String, CodingKey {
        case first
        case number
        case last
        case content
        case empty
        case totalPages
        case totalElements
        case sort
        case size
        case numberOfElements
        case pageable
    }
    
    public var first: Bool?
    public var number: Int?
    public var last: Bool?
    public var content: [RemotePurchaseCoinHistoryContent]?
    public var empty: Bool?
    public var totalPages: Int?
    public var totalElements: Int?
    public var sort: RemotePurchaseCoinHistorySort?
    public var size: Int?
    public var numberOfElements: Int?
    public var pageable: RemotePurchaseCoinHistoryPageable?
    
    
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        first = try container.decodeIfPresent(Bool.self, forKey: .first)
        number = try container.decodeIfPresent(Int.self, forKey: .number)
        last = try container.decodeIfPresent(Bool.self, forKey: .last)
        content = try container.decodeIfPresent([RemotePurchaseCoinHistoryContent].self, forKey: .content)
        empty = try container.decodeIfPresent(Bool.self, forKey: .empty)
        totalPages = try container.decodeIfPresent(Int.self, forKey: .totalPages)
        totalElements = try container.decodeIfPresent(Int.self, forKey: .totalElements)
        sort = try container.decodeIfPresent(RemotePurchaseCoinHistorySort.self, forKey: .sort)
        size = try container.decodeIfPresent(Int.self, forKey: .size)
        numberOfElements = try container.decodeIfPresent(Int.self, forKey: .numberOfElements)
        pageable = try container.decodeIfPresent(RemotePurchaseCoinHistoryPageable.self, forKey: .pageable)
    }
    
}
