//
//  RemoteCurrencyHistoryData.swift
//
//  Created by DENAZMI on 28/08/23
//  Copyright (c) . All rights reserved.
//

import Foundation

public struct RemoteCurrencyHistoryData: Codable {
    
    enum CodingKeys: String, CodingKey {
        case number
        case first
        case pageable
        case sort
        case size
        case content
        case totalPages
        case totalElements
        case numberOfElements
        case empty
        case last
    }
    
    public var number: Int?
    public var first: Bool?
    public var pageable: RemoteCurrencyHistoryPageable?
    public var sort: RemoteCurrencyHistorySort?
    public var size: Int?
    public var content: [RemoteCurrencyHistoryContent]?
    public var totalPages: Int?
    public var totalElements: Int?
    public var numberOfElements: Int?
    public var empty: Bool?
    public var last: Bool?
    
    
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        number = try container.decodeIfPresent(Int.self, forKey: .number)
        first = try container.decodeIfPresent(Bool.self, forKey: .first)
        pageable = try container.decodeIfPresent(RemoteCurrencyHistoryPageable.self, forKey: .pageable)
        sort = try container.decodeIfPresent(RemoteCurrencyHistorySort.self, forKey: .sort)
        size = try container.decodeIfPresent(Int.self, forKey: .size)
        content = try container.decodeIfPresent([RemoteCurrencyHistoryContent].self, forKey: .content)
        totalPages = try container.decodeIfPresent(Int.self, forKey: .totalPages)
        totalElements = try container.decodeIfPresent(Int.self, forKey: .totalElements)
        numberOfElements = try container.decodeIfPresent(Int.self, forKey: .numberOfElements)
        empty = try container.decodeIfPresent(Bool.self, forKey: .empty)
        last = try container.decodeIfPresent(Bool.self, forKey: .last)
    }
    
}
