//
//  RemoteDonationDetail.swift
//
//  Created by DENAZMI on 28/02/23
//  Copyright (c) . All rights reserved.
//

import Foundation

struct RemoteDonationDetail: Codable {

  enum CodingKeys: String, CodingKey {
    case message
    case data
    case code
  }

  var message: String?
  var data: RemoteDonationDetailData?
  var code: String?



  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    message = try container.decodeIfPresent(String.self, forKey: .message)
    data = try container.decodeIfPresent(RemoteDonationDetailData.self, forKey: .data)
    code = try container.decodeIfPresent(String.self, forKey: .code)
  }

}
