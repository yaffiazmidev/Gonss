//
//  RemoteDonationCategory.swift
//
//  Created by DENAZMI on 28/02/23
//  Copyright (c) . All rights reserved.
//

import Foundation

struct RemoteDonationCategory: Codable {

  enum CodingKeys: String, CodingKey {
    case code
    case message
    case data
  }

  var code: String?
  var message: String?
  var data: [RemoteDonationCategoryData]?



  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    code = try container.decodeIfPresent(String.self, forKey: .code)
    message = try container.decodeIfPresent(String.self, forKey: .message)
    data = try container.decodeIfPresent([RemoteDonationCategoryData].self, forKey: .data)
  }

}
