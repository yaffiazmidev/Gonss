//
//  RemoteProductEtalasePageable.swift
//
//  Created by DENAZMI on 05/01/24
//  Copyright (c) . All rights reserved.
//

import Foundation

struct RemoteProductEtalasePageable: Codable {

  enum CodingKeys: String, CodingKey {
    case unpaged
    case pageSize
    case startId
    case offset
    case paged
    case pageNumber
    case offsetPage
    case sort
    case nocache
  }

  var unpaged: Bool?
  var pageSize: Int?
  var startId: String?
  var offset: Int?
  var paged: Bool?
  var pageNumber: Int?
  var offsetPage: Int?
  var sort: RemoteProductEtalaseSort?
  var nocache: Bool?



  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    unpaged = try container.decodeIfPresent(Bool.self, forKey: .unpaged)
    pageSize = try container.decodeIfPresent(Int.self, forKey: .pageSize)
    startId = try container.decodeIfPresent(String.self, forKey: .startId)
    offset = try container.decodeIfPresent(Int.self, forKey: .offset)
    paged = try container.decodeIfPresent(Bool.self, forKey: .paged)
    pageNumber = try container.decodeIfPresent(Int.self, forKey: .pageNumber)
    offsetPage = try container.decodeIfPresent(Int.self, forKey: .offsetPage)
    sort = try container.decodeIfPresent(RemoteProductEtalaseSort.self, forKey: .sort)
    nocache = try container.decodeIfPresent(Bool.self, forKey: .nocache)
  }

}
