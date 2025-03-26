//
//  RemoteStoreItemThumbnail.swift
//
//  Created by DENAZMI on 05/01/24
//  Copyright (c) . All rights reserved.
//

import Foundation

struct RemoteStoreItemThumbnail: Codable {

  enum CodingKeys: String, CodingKey {
    case medium
    case large
    case small
  }

  var medium: String?
  var large: String?
  var small: String?



  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    medium = try container.decodeIfPresent(String.self, forKey: .medium)
    large = try container.decodeIfPresent(String.self, forKey: .large)
    small = try container.decodeIfPresent(String.self, forKey: .small)
  }

}
