//
//  RemoteDonationCategoryData.swift
//
//  Created by DENAZMI on 28/02/23
//  Copyright (c) . All rights reserved.
//

import Foundation

struct RemoteDonationCategoryData: Codable {

  enum CodingKeys: String, CodingKey {
    case id
    case icon
    case name
  }

  var id: String?
  var icon: String?
  var name: String?



//  init(from decoder: Decoder) throws {
//    let container = try decoder.container(keyedBy: CodingKeys.self)
//    id = try container.decodeIfPresent(String.self, forKey: .id)
//    icon = try container.decodeIfPresent(String.self, forKey: .icon)
//    name = try container.decodeIfPresent(String.self, forKey: .name)
//  }

}
