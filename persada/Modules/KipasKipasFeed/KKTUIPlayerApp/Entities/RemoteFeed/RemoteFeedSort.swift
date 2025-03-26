//
//  RemoteFeedSort.swift
//
//  Created by DENAZMI on 24/09/23
//  Copyright (c) . All rights reserved.
//

import Foundation

struct RemoteFeedSort: Codable {

  enum CodingKeys: String, CodingKey {
    case sorted
    case empty
    case unsorted
  }

  var sorted: Bool?
  var empty: Bool?
  var unsorted: Bool?



  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    sorted = try container.decodeIfPresent(Bool.self, forKey: .sorted)
    empty = try container.decodeIfPresent(Bool.self, forKey: .empty)
    unsorted = try container.decodeIfPresent(Bool.self, forKey: .unsorted)
  }

}
