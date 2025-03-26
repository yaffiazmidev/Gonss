//
//  RemoteProductEtalaseThumbnail.swift
//
//  Created by DENAZMI on 05/01/24
//  Copyright (c) . All rights reserved.
//

import Foundation

struct RemoteProductEtalaseThumbnail: Codable {

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
