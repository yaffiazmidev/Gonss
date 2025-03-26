//
//  RemoteDonationOrderExist.swift
//  KipasKipas
//
//  Created by DENAZMI on 01/03/23.
//  Copyright © 2023 Koanba. All rights reserved.
//

import Foundation

struct RemoteDonationOrderExist: Codable {

  enum CodingKeys: String, CodingKey {
    case code
    case message
    case data
  }

  var code: String?
  var message: String?
  var data: RemoteDonationOrderExistData?



  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    code = try container.decodeIfPresent(String.self, forKey: .code)
    message = try container.decodeIfPresent(String.self, forKey: .message)
    data = try container.decodeIfPresent(RemoteDonationOrderExistData.self, forKey: .data)
  }

}

struct RemoteDonationOrderExistData: Codable {

  enum CodingKeys: String, CodingKey {
    case isOrderExist = "orderExist"
    case orderId
  }

  var isOrderExist: Bool?
  var orderId: String?



  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    isOrderExist = try container.decodeIfPresent(Bool.self, forKey: .isOrderExist)
    orderId = try container.decodeIfPresent(String.self, forKey: .orderId)
  }

}
