//
//  RemoteStoreItem.swift
//
//  Created by DENAZMI on 05/01/24
//  Copyright (c) . All rights reserved.
//

import Foundation

struct RemoteStoreItem: Codable {

  enum CodingKeys: String, CodingKey {
    case code
    case first
    case pageable
    case empty
    case data
    case size
    case last
    case numberOfElements
    case totalPages
    case message
    case number
    case totalElements
    case sort
  }

  var code: String?
  var first: Bool?
  var pageable: RemoteStoreItemPageable?
  var empty: Bool?
  var data: [RemoteStoreItemData]?
  var size: Int?
  var last: Bool?
  var numberOfElements: Int?
  var totalPages: Int?
  var message: String?
  var number: Int?
  var totalElements: Int?
  var sort: RemoteStoreItemSort?



  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    code = try container.decodeIfPresent(String.self, forKey: .code)
    first = try container.decodeIfPresent(Bool.self, forKey: .first)
    pageable = try container.decodeIfPresent(RemoteStoreItemPageable.self, forKey: .pageable)
    empty = try container.decodeIfPresent(Bool.self, forKey: .empty)
    data = try container.decodeIfPresent([RemoteStoreItemData].self, forKey: .data)
    size = try container.decodeIfPresent(Int.self, forKey: .size)
    last = try container.decodeIfPresent(Bool.self, forKey: .last)
    numberOfElements = try container.decodeIfPresent(Int.self, forKey: .numberOfElements)
    totalPages = try container.decodeIfPresent(Int.self, forKey: .totalPages)
    message = try container.decodeIfPresent(String.self, forKey: .message)
    number = try container.decodeIfPresent(Int.self, forKey: .number)
    totalElements = try container.decodeIfPresent(Int.self, forKey: .totalElements)
    sort = try container.decodeIfPresent(RemoteStoreItemSort.self, forKey: .sort)
  }

}
