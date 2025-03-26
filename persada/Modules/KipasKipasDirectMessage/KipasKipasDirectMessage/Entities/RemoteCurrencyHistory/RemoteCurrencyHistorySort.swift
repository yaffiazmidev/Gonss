//
//  RemoteCurrencyHistorySort.swift
//
//  Created by DENAZMI on 28/08/23
//  Copyright (c) . All rights reserved.
//

import Foundation

public struct RemoteCurrencyHistorySort: Codable {
    
    enum CodingKeys: String, CodingKey {
        case empty
        case unsorted
        case sorted
    }
    
    public var empty: Bool?
    public var unsorted: Bool?
    public var sorted: Bool?
    
    
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        empty = try container.decodeIfPresent(Bool.self, forKey: .empty)
        unsorted = try container.decodeIfPresent(Bool.self, forKey: .unsorted)
        sorted = try container.decodeIfPresent(Bool.self, forKey: .sorted)
    }
    
}
