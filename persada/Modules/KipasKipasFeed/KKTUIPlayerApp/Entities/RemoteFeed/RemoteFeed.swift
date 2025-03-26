//
//  RemoteFeed.swift
//
//  Created by DENAZMI on 24/09/23
//  Copyright (c) . All rights reserved.
//

import Foundation

struct RemoteFeed: Codable {

  enum CodingKeys: String, CodingKey {
    case data
    case message
    case code
  }

  var data: RemoteFeedData?
  var message: String?
  var code: String?



  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    data = try container.decodeIfPresent(RemoteFeedData.self, forKey: .data)
    message = try container.decodeIfPresent(String.self, forKey: .message)
    code = try container.decodeIfPresent(String.self, forKey: .code)
  }

}
