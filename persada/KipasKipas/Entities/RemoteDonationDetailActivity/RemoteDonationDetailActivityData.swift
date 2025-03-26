//
//  RemoteDonationDetailActivityData.swift
//
//  Created by DENAZMI on 28/02/23
//  Copyright (c) . All rights reserved.
//

import Foundation

struct RemoteDonationDetailActivityData: Codable {

  enum CodingKeys: String, CodingKey {
    case totalPages
    case last
    case number
    case size
    case sort
    case content
    case pageable
    case first
    case numberOfElements
    case totalElements
    case empty
  }

  var totalPages: Int?
  var last: Bool?
  var number: Int?
  var size: Int?
  var sort: RemoteDonationDetailActivitySort?
  var content: [RemoteDonationDetailActivityContent]?
  var pageable: RemoteDonationDetailActivityPageable?
  var first: Bool?
  var numberOfElements: Int?
  var totalElements: Int?
  var empty: Bool?



  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    totalPages = try container.decodeIfPresent(Int.self, forKey: .totalPages)
    last = try container.decodeIfPresent(Bool.self, forKey: .last)
    number = try container.decodeIfPresent(Int.self, forKey: .number)
    size = try container.decodeIfPresent(Int.self, forKey: .size)
    sort = try container.decodeIfPresent(RemoteDonationDetailActivitySort.self, forKey: .sort)
    content = try container.decodeIfPresent([RemoteDonationDetailActivityContent].self, forKey: .content)
    pageable = try container.decodeIfPresent(RemoteDonationDetailActivityPageable.self, forKey: .pageable)
    first = try container.decodeIfPresent(Bool.self, forKey: .first)
    numberOfElements = try container.decodeIfPresent(Int.self, forKey: .numberOfElements)
    totalElements = try container.decodeIfPresent(Int.self, forKey: .totalElements)
    empty = try container.decodeIfPresent(Bool.self, forKey: .empty)
  }

}
