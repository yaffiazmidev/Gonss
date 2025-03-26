//
//  RemoteDonationDetailThumbnail.swift
//
//  Created by DENAZMI on 28/02/23
//  Copyright (c) . All rights reserved.
//

import Foundation

struct RemoteDonationDetailThumbnail: Codable {

  enum CodingKeys: String, CodingKey {
    case large
    case medium
    case small
  }

  var large: String?
  var medium: String?
  var small: String?



  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    large = try container.decodeIfPresent(String.self, forKey: .large)
    medium = try container.decodeIfPresent(String.self, forKey: .medium)
    small = try container.decodeIfPresent(String.self, forKey: .small)
  }

}
