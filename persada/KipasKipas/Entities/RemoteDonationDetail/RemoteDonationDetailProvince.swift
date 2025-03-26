//
//  RemoteDonationDetailProvince.swift
//
//  Created by DENAZMI on 28/02/23
//  Copyright (c) . All rights reserved.
//

import Foundation

struct RemoteDonationDetailProvince: Codable {

  enum CodingKeys: String, CodingKey {
    case id
    case code
    case name
  }

  var id: String?
  var code: String?
  var name: String?



  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    id = try container.decodeIfPresent(String.self, forKey: .id)
    code = try container.decodeIfPresent(String.self, forKey: .code)
    name = try container.decodeIfPresent(String.self, forKey: .name)
  }

}
