//
//  RemoteFeedData.swift
//
//  Created by DENAZMI on 24/09/23
//  Copyright (c) . All rights reserved.
//

import Foundation

struct RemoteFeedData: Codable {

  enum CodingKeys: String, CodingKey {
    case number
    case sort
    case pageable
    case totalElements
    case numberOfElements
    case last
    case content
    case empty
    case first
    case size
    case totalPages
  }

  var number: Int?
  var sort: RemoteFeedSort?
  var pageable: RemoteFeedPageable?
  var totalElements: Int?
  var numberOfElements: Int?
  var last: Bool?
  var content: [RemoteFeedContent]?
  var empty: Bool?
  var first: Bool?
  var size: Int?
  var totalPages: Int?



  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    number = try container.decodeIfPresent(Int.self, forKey: .number)
    sort = try container.decodeIfPresent(RemoteFeedSort.self, forKey: .sort)
    pageable = try container.decodeIfPresent(RemoteFeedPageable.self, forKey: .pageable)
    totalElements = try container.decodeIfPresent(Int.self, forKey: .totalElements)
    numberOfElements = try container.decodeIfPresent(Int.self, forKey: .numberOfElements)
    last = try container.decodeIfPresent(Bool.self, forKey: .last)
    content = try container.decodeIfPresent([RemoteFeedContent].self, forKey: .content)
    empty = try container.decodeIfPresent(Bool.self, forKey: .empty)
    first = try container.decodeIfPresent(Bool.self, forKey: .first)
    size = try container.decodeIfPresent(Int.self, forKey: .size)
    totalPages = try container.decodeIfPresent(Int.self, forKey: .totalPages)
  }

}
