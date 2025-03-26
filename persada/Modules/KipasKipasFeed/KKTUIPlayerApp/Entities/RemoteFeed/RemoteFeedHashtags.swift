//
//  RemoteFeedHashtags.swift
//
//  Created by DENAZMI on 24/09/23
//  Copyright (c) . All rights reserved.
//

import Foundation

struct RemoteFeedHashtags: Codable {

  enum CodingKeys: String, CodingKey {
    case value
    case id
    case total
  }

  var value: String?
  var id: String?
  var total: Int?



  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    value = try container.decodeIfPresent(String.self, forKey: .value)
    id = try container.decodeIfPresent(String.self, forKey: .id)
    total = try container.decodeIfPresent(Int.self, forKey: .total)
  }

}
