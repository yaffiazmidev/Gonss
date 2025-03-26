//
//  RemoteDonationContinueOrder.swift
//  KipasKipas
//
//  Created by DENAZMI on 01/03/23.
//  Copyright © 2023 Koanba. All rights reserved.
//

import Foundation

struct RemoteDonationContinueOrder: Codable {

  enum CodingKeys: String, CodingKey {
    case message
    case data
    case code
  }

  var code: String?
  var message: String?
  var data: RemoteDonationContinueOrderData?



  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    message = try container.decodeIfPresent(String.self, forKey: .message)
    data = try container.decodeIfPresent(RemoteDonationContinueOrderData.self, forKey: .data)
    code = try container.decodeIfPresent(String.self, forKey: .code)
  }

}

struct RemoteDonationContinueOrderData: Codable {

  enum CodingKeys: String, CodingKey {
    case redirectUrl
    case token
    case orderId
  }

  var redirectUrl: String?
  var token: String?
  var orderId: String?



  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    redirectUrl = try container.decodeIfPresent(String.self, forKey: .redirectUrl)
    token = try container.decodeIfPresent(String.self, forKey: .token)
    orderId = try container.decodeIfPresent(String.self, forKey: .orderId)
  }

}
