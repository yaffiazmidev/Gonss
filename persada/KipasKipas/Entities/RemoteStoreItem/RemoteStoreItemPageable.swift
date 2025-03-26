//
//  RemoteStoreItemPageable.swift
//
//  Created by DENAZMI on 05/01/24
//  Copyright (c) . All rights reserved.
//

import Foundation

struct RemoteStoreItemPageable: Codable {

  enum CodingKeys: String, CodingKey {
    case unpaged
    case offsetPage
    case pageSize
    case pageNumber
    case paged
    case nocache
    case sort
    case offset
    case startId
  }

  var unpaged: Bool?
  var offsetPage: Int?
  var pageSize: Int?
  var pageNumber: Int?
  var paged: Bool?
  var nocache: Bool?
  var sort: RemoteStoreItemSort?
  var offset: Int?
  var startId: String?



  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    unpaged = try container.decodeIfPresent(Bool.self, forKey: .unpaged)
    offsetPage = try container.decodeIfPresent(Int.self, forKey: .offsetPage)
    pageSize = try container.decodeIfPresent(Int.self, forKey: .pageSize)
    pageNumber = try container.decodeIfPresent(Int.self, forKey: .pageNumber)
    paged = try container.decodeIfPresent(Bool.self, forKey: .paged)
    nocache = try container.decodeIfPresent(Bool.self, forKey: .nocache)
    sort = try container.decodeIfPresent(RemoteStoreItemSort.self, forKey: .sort)
    offset = try container.decodeIfPresent(Int.self, forKey: .offset)
    startId = try container.decodeIfPresent(String.self, forKey: .startId)
  }

}
