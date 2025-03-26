//
//  RemoteFeedPageable.swift
//
//  Created by DENAZMI on 24/09/23
//  Copyright (c) . All rights reserved.
//

import Foundation

struct RemoteFeedPageable: Codable {

  enum CodingKeys: String, CodingKey {
    case offset
    case pageSize
    case pageNumber
    case startId
    case paged
    case offsetPage
    case nocache
    case sort
    case unpaged
  }

  var offset: Int?
  var pageSize: Int?
  var pageNumber: Int?
  var startId: String?
  var paged: Bool?
  var offsetPage: Int?
  var nocache: Bool?
  var sort: RemoteFeedSort?
  var unpaged: Bool?



  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    offset = try container.decodeIfPresent(Int.self, forKey: .offset)
    pageSize = try container.decodeIfPresent(Int.self, forKey: .pageSize)
    pageNumber = try container.decodeIfPresent(Int.self, forKey: .pageNumber)
    startId = try container.decodeIfPresent(String.self, forKey: .startId)
    paged = try container.decodeIfPresent(Bool.self, forKey: .paged)
    offsetPage = try container.decodeIfPresent(Int.self, forKey: .offsetPage)
    nocache = try container.decodeIfPresent(Bool.self, forKey: .nocache)
    sort = try container.decodeIfPresent(RemoteFeedSort.self, forKey: .sort)
    unpaged = try container.decodeIfPresent(Bool.self, forKey: .unpaged)
  }

}
