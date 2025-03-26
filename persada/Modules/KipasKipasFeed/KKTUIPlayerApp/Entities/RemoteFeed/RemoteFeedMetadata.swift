//
//  RemoteFeedMetadata.swift
//
//  Created by DENAZMI on 24/09/23
//  Copyright (c) . All rights reserved.
//

import Foundation

struct RemoteFeedMetadata: Codable {

  enum CodingKeys: String, CodingKey {
    case width
    case height
    case size
    case duration
  }

  var width: String?
  var height: String?
  var size: String?
  var duration: Double?



  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    width = try container.decodeIfPresent(String.self, forKey: .width)
    height = try container.decodeIfPresent(String.self, forKey: .height)
    size = try container.decodeIfPresent(String.self, forKey: .size)
    duration = try container.decodeIfPresent(Double.self, forKey: .duration)
  }

}
