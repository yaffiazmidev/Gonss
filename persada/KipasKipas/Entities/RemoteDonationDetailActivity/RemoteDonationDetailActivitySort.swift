//
//  RemoteDonationDetailActivitySort.swift
//
//  Created by DENAZMI on 28/02/23
//  Copyright (c) . All rights reserved.
//

import Foundation

struct RemoteDonationDetailActivitySort: Codable {

  enum CodingKeys: String, CodingKey {
    case unsorted
    case empty
    case sorted
  }

  var unsorted: Bool?
  var empty: Bool?
  var sorted: Bool?



  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    unsorted = try container.decodeIfPresent(Bool.self, forKey: .unsorted)
    empty = try container.decodeIfPresent(Bool.self, forKey: .empty)
    sorted = try container.decodeIfPresent(Bool.self, forKey: .sorted)
  }

}
