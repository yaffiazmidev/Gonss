//
//  RemoteProductEtalaseSort.swift
//
//  Created by DENAZMI on 05/01/24
//  Copyright (c) . All rights reserved.
//

import Foundation

struct RemoteProductEtalaseSort: Codable {

  enum CodingKeys: String, CodingKey {
    case unsorted
    case sorted
    case empty
  }

  var unsorted: Bool?
  var sorted: Bool?
  var empty: Bool?



  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    unsorted = try container.decodeIfPresent(Bool.self, forKey: .unsorted)
    sorted = try container.decodeIfPresent(Bool.self, forKey: .sorted)
    empty = try container.decodeIfPresent(Bool.self, forKey: .empty)
  }

}
