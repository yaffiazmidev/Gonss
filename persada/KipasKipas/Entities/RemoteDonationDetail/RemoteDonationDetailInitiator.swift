//
//  RemoteDonationDetailInitiator.swift
//
//  Created by DENAZMI on 28/02/23
//  Copyright (c) . All rights reserved.
//

import Foundation

struct RemoteDonationDetailInitiator: Codable {

  enum CodingKeys: String, CodingKey {
    case isVerified
    case isFollow
    case mobile
    case isSeleb
    case gender
    case photo
    case username
    case name
    case isDisabled
    case email
    case isSeller
    case bio
    case id
    case accountType
  }

  var isVerified: Bool?
  var isFollow: Bool?
  var mobile: String?
  var isSeleb: Bool?
  var gender: String?
  var photo: String?
  var username: String?
  var name: String?
  var isDisabled: Bool?
  var email: String?
  var isSeller: Bool?
  var bio: String?
  var id: String?
  var accountType: String?



  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    isVerified = try container.decodeIfPresent(Bool.self, forKey: .isVerified)
    isFollow = try container.decodeIfPresent(Bool.self, forKey: .isFollow)
    mobile = try container.decodeIfPresent(String.self, forKey: .mobile)
    isSeleb = try container.decodeIfPresent(Bool.self, forKey: .isSeleb)
    gender = try container.decodeIfPresent(String.self, forKey: .gender)
    photo = try container.decodeIfPresent(String.self, forKey: .photo)
    username = try container.decodeIfPresent(String.self, forKey: .username)
    name = try container.decodeIfPresent(String.self, forKey: .name)
    isDisabled = try container.decodeIfPresent(Bool.self, forKey: .isDisabled)
    email = try container.decodeIfPresent(String.self, forKey: .email)
    isSeller = try container.decodeIfPresent(Bool.self, forKey: .isSeller)
    bio = try container.decodeIfPresent(String.self, forKey: .bio)
    id = try container.decodeIfPresent(String.self, forKey: .id)
    accountType = try container.decodeIfPresent(String.self, forKey: .accountType)
  }

}
