//
//  RemoteDonationDetailMetadata.swift
//
//  Created by DENAZMI on 28/02/23
//  Copyright (c) . All rights reserved.
//

import Foundation

struct RemoteDonationDetailMetadata: Codable {

  enum CodingKeys: String, CodingKey {
    case duration
    case width
    case height
    case size
  }

  var duration: Double?
  var width: String?
  var height: String?
  var size: String?



  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    duration = try container.decodeIfPresent(Double.self, forKey: .duration)
    width = try container.decodeIfPresent(String.self, forKey: .width)
    height = try container.decodeIfPresent(String.self, forKey: .height)
    size = try container.decodeIfPresent(String.self, forKey: .size)
  }

}
