//
//  RemoteFeedThumbnail.swift
//
//  Created by DENAZMI on 24/09/23
//  Copyright (c) . All rights reserved.
//

import Foundation

struct RemoteFeedThumbnail: Codable {

  enum CodingKeys: String, CodingKey {
    case small
    case large
    case medium
  }

  var small: String?
  var large: String?
  var medium: String?



  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    small = try container.decodeIfPresent(String.self, forKey: .small)
    large = try container.decodeIfPresent(String.self, forKey: .large)
    medium = try container.decodeIfPresent(String.self, forKey: .medium)
  }

}
