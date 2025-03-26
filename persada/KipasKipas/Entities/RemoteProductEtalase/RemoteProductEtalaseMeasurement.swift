//
//  RemoteProductEtalaseMeasurement.swift
//
//  Created by DENAZMI on 05/01/24
//  Copyright (c) . All rights reserved.
//

import Foundation

struct RemoteProductEtalaseMeasurement: Codable {

  enum CodingKeys: String, CodingKey {
    case length
    case width
    case height
    case weight
  }

  var length: Int?
  var width: Int?
  var height: Int?
  var weight: Int?



  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    length = try container.decodeIfPresent(Int.self, forKey: .length)
    width = try container.decodeIfPresent(Int.self, forKey: .width)
    height = try container.decodeIfPresent(Int.self, forKey: .height)
    weight = try container.decodeIfPresent(Int.self, forKey: .weight)
  }

}
