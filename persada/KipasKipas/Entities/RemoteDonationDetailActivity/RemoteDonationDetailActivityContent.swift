//
//  RemoteDonationDetailActivityContent.swift
//
//  Created by DENAZMI on 28/02/23
//  Copyright (c) . All rights reserved.
//

import Foundation

struct RemoteDonationDetailActivityContent: Codable {

  enum CodingKeys: String, CodingKey {
    case id
    case withdrawByName
    case description
    case type
    case recipientName
    case createAt
    case amount
  }

  var id: String?
  var withdrawByName: String?
  var description: String?
  var type: String?
  var recipientName: String?
  var createAt: Int?
  var amount: Int?



  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    id = try container.decodeIfPresent(String.self, forKey: .id)
    withdrawByName = try container.decodeIfPresent(String.self, forKey: .withdrawByName)
    description = try container.decodeIfPresent(String.self, forKey: .description)
    type = try container.decodeIfPresent(String.self, forKey: .type)
    recipientName = try container.decodeIfPresent(String.self, forKey: .recipientName)
    createAt = try container.decodeIfPresent(Int.self, forKey: .createAt)
    amount = try container.decodeIfPresent(Int.self, forKey: .amount)
  }

}
