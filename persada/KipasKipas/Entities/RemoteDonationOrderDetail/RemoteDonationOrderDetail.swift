//
//  RemoteDonationOrderDetail.swift
//
//  Created by DENAZMI on 01/03/23
//  Copyright (c) . All rights reserved.
//

import Foundation

struct RemoteDonationOrderDetail: Codable {

  enum CodingKeys: String, CodingKey {
    case data
    case code
    case message
  }

  var data: RemoteDonationOrderDetailData?
  var code: String?
  var message: String?



  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    data = try container.decodeIfPresent(RemoteDonationOrderDetailData.self, forKey: .data)
    code = try container.decodeIfPresent(String.self, forKey: .code)
    message = try container.decodeIfPresent(String.self, forKey: .message)
  }

}
