//
//  RemoteSearchUserData.swift
//
//  Created by DENAZMI on 02/08/23
//  Copyright (c) . All rights reserved.
//

import Foundation

public struct RemoteSearchUserData: Codable {

  enum CodingKeys: String, CodingKey {
    case name
    case id
    case photo
    case email
    case username
    case accountType
    case isSeleb
    case gender
    case isVerified
    case mobile
    case isFollow
  }

  public var name: String?
  public var id: String?
  public var photo: String?
  public var email: String?
  public var username: String?
  public var accountType: String?
  public var isSeleb: Bool?
  public var gender: String?
  public var isVerified: Bool?
  public var mobile: String?
  public var isFollow: Bool?



  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    name = try container.decodeIfPresent(String.self, forKey: .name)
    id = try container.decodeIfPresent(String.self, forKey: .id)
    photo = try container.decodeIfPresent(String.self, forKey: .photo)
    email = try container.decodeIfPresent(String.self, forKey: .email)
    username = try container.decodeIfPresent(String.self, forKey: .username)
    accountType = try container.decodeIfPresent(String.self, forKey: .accountType)
    isSeleb = try container.decodeIfPresent(Bool.self, forKey: .isSeleb)
    gender = try container.decodeIfPresent(String.self, forKey: .gender)
    isVerified = try container.decodeIfPresent(Bool.self, forKey: .isVerified)
    mobile = try container.decodeIfPresent(String.self, forKey: .mobile)
    isFollow = try container.decodeIfPresent(Bool.self, forKey: .isFollow)
  }

}
