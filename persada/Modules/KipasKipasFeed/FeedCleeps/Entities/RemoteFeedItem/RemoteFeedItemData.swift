//
//  RemoteFeedItemData.swift
//
//  Created by DENAZMI on 04/10/23
//  Copyright (c) . All rights reserved.
//

import Foundation

public struct RemoteFeedItemData: Codable {

    public enum CodingKeys: String, CodingKey {
    case numberOfElements
    case last
    case sort
    case content
    case totalElements
    case first
    case totalPages
    case size
    case pageable
    case number
    case empty
  }

    public var numberOfElements: Int?
    public var last: Bool?
    public var sort: RemoteFeedItemSort?
    public var content: [RemoteFeedItemContent]?
    public var totalElements: Int?
    public var first: Bool?
    public var totalPages: Int?
    public var size: Int?
    public var pageable: RemoteFeedItemPageable?
    public var number: Int?
    public var empty: Bool?



    public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    numberOfElements = try container.decodeIfPresent(Int.self, forKey: .numberOfElements)
    last = try container.decodeIfPresent(Bool.self, forKey: .last)
    sort = try container.decodeIfPresent(RemoteFeedItemSort.self, forKey: .sort)
    content = try container.decodeIfPresent([RemoteFeedItemContent].self, forKey: .content)
    totalElements = try container.decodeIfPresent(Int.self, forKey: .totalElements)
    first = try container.decodeIfPresent(Bool.self, forKey: .first)
    totalPages = try container.decodeIfPresent(Int.self, forKey: .totalPages)
    size = try container.decodeIfPresent(Int.self, forKey: .size)
    pageable = try? container.decodeIfPresent(RemoteFeedItemPageable.self, forKey: .pageable)
    number = try container.decodeIfPresent(Int.self, forKey: .number)
    empty = try container.decodeIfPresent(Bool.self, forKey: .empty)
  }

}
