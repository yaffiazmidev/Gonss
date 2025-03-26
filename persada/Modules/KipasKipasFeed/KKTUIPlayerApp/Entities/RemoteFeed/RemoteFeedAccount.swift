//
//  RemoteFeedAccount.swift
//
//  Created by DENAZMI on 24/09/23
//  Copyright (c) . All rights reserved.
//

import Foundation

struct RemoteFeedAccount: Codable {

  enum CodingKeys: String, CodingKey {
    case id
    case isDisabled
    case photo
    case name
    case email
    case username
    case mobile
    case isVerified
  }

  var id: String?
  var isDisabled: Bool?
  var photo: String?
  var name: String?
  var email: String?
  var username: String?
  var mobile: String?
  var isVerified: Bool?



  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    id = try container.decodeIfPresent(String.self, forKey: .id)
    isDisabled = try container.decodeIfPresent(Bool.self, forKey: .isDisabled)
    photo = try container.decodeIfPresent(String.self, forKey: .photo)
    name = try container.decodeIfPresent(String.self, forKey: .name)
    email = try container.decodeIfPresent(String.self, forKey: .email)
    username = try container.decodeIfPresent(String.self, forKey: .username)
    mobile = try container.decodeIfPresent(String.self, forKey: .mobile)
    isVerified = try container.decodeIfPresent(Bool.self, forKey: .isVerified)
  }

}
