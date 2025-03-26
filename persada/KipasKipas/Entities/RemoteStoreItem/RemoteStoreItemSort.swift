//
//  RemoteStoreItemSort.swift
//
//  Created by DENAZMI on 05/01/24
//  Copyright (c) . All rights reserved.
//

import Foundation

struct RemoteStoreItemSort: Codable {

  enum CodingKeys: String, CodingKey {
    case sorted
    case unsorted
    case empty
  }

  var sorted: Bool?
  var unsorted: Bool?
  var empty: Bool?



  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    sorted = try container.decodeIfPresent(Bool.self, forKey: .sorted)
    unsorted = try container.decodeIfPresent(Bool.self, forKey: .unsorted)
    empty = try container.decodeIfPresent(Bool.self, forKey: .empty)
  }

}
