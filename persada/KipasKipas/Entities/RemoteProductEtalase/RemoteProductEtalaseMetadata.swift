//
//  RemoteProductEtalaseMetadata.swift
//
//  Created by DENAZMI on 05/01/24
//  Copyright (c) . All rights reserved.
//

import Foundation

struct RemoteProductEtalaseMetadata: Codable {

  enum CodingKeys: String, CodingKey {
    case size
    case height
    case width
    case duration
  }

  var size: String?
  var height: String?
  var width: String?
  var duration: Float?



  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    size = try container.decodeIfPresent(String.self, forKey: .size)
    height = try container.decodeIfPresent(String.self, forKey: .height)
    width = try container.decodeIfPresent(String.self, forKey: .width)
    duration = try container.decodeIfPresent(Float.self, forKey: .duration)
  }

}
