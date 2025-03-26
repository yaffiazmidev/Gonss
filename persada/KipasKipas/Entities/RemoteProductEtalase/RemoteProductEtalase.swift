//
//  RemoteProductEtalase.swift
//
//  Created by DENAZMI on 05/01/24
//  Copyright (c) . All rights reserved.
//

import Foundation

struct RemoteProductEtalase: Codable {

  enum CodingKeys: String, CodingKey {
    case sort
    case number
    case first
    case empty
    case code
    case pageable
    case numberOfElements
    case message
    case last
    case totalElements
    case data
    case totalPages
    case size
  }

  var sort: RemoteProductEtalaseSort?
  var number: Int?
  var first: Bool?
  var empty: Bool?
  var code: String?
  var pageable: RemoteProductEtalasePageable?
  var numberOfElements: Int?
  var message: String?
  var last: Bool?
  var totalElements: Int?
  var data: [RemoteProductEtalaseData]?
  var totalPages: Int?
  var size: Int?



  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    sort = try container.decodeIfPresent(RemoteProductEtalaseSort.self, forKey: .sort)
    number = try container.decodeIfPresent(Int.self, forKey: .number)
    first = try container.decodeIfPresent(Bool.self, forKey: .first)
    empty = try container.decodeIfPresent(Bool.self, forKey: .empty)
    code = try container.decodeIfPresent(String.self, forKey: .code)
    pageable = try container.decodeIfPresent(RemoteProductEtalasePageable.self, forKey: .pageable)
    numberOfElements = try container.decodeIfPresent(Int.self, forKey: .numberOfElements)
    message = try container.decodeIfPresent(String.self, forKey: .message)
    last = try container.decodeIfPresent(Bool.self, forKey: .last)
    totalElements = try container.decodeIfPresent(Int.self, forKey: .totalElements)
    data = try container.decodeIfPresent([RemoteProductEtalaseData].self, forKey: .data)
    totalPages = try container.decodeIfPresent(Int.self, forKey: .totalPages)
    size = try container.decodeIfPresent(Int.self, forKey: .size)
  }

}
