//
//  RemoteDonationDetailActivityPageable.swift
//
//  Created by DENAZMI on 28/02/23
//  Copyright (c) . All rights reserved.
//

import Foundation

struct RemoteDonationDetailActivityPageable: Codable {

  enum CodingKeys: String, CodingKey {
    case paged
    case offset
    case unpaged
    case sort
    case pageSize
    case pageNumber
  }

  var paged: Bool?
  var offset: Int?
  var unpaged: Bool?
  var sort: RemoteDonationDetailActivitySort?
  var pageSize: Int?
  var pageNumber: Int?



  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    paged = try container.decodeIfPresent(Bool.self, forKey: .paged)
    offset = try container.decodeIfPresent(Int.self, forKey: .offset)
    unpaged = try container.decodeIfPresent(Bool.self, forKey: .unpaged)
    sort = try container.decodeIfPresent(RemoteDonationDetailActivitySort.self, forKey: .sort)
    pageSize = try container.decodeIfPresent(Int.self, forKey: .pageSize)
    pageNumber = try container.decodeIfPresent(Int.self, forKey: .pageNumber)
  }

}
