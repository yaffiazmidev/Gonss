//
//  RemoteFeedItemAccount.swift
//
//  Created by DENAZMI on 04/10/23
//  Copyright (c) . All rights reserved.
//

import Foundation

public struct RemoteFeedItemAccount: Codable {

  enum CodingKeys: String, CodingKey {
    case name
    case email
    case isDisabled
    case photo
    case username
    case mobile
    case isVerified
    case id
    case accountType
    case urlBadge
    case isShowBadge
    case isFollow
    case chatPrice
  }

    public var name: String?
    public var email: String?
    public var isDisabled: Bool?
    public var photo: String?
    public var username: String?
    public var mobile: String?
    public var isVerified: Bool?
    public var id: String?
    public var accountType: String?
    public var urlBadge: String?
    public var isShowBadge: Bool?
    public var isFollow: Bool?
    public var chatPrice: Int?


    public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    name = try container.decodeIfPresent(String.self, forKey: .name)
    email = try container.decodeIfPresent(String.self, forKey: .email)
    isDisabled = try container.decodeIfPresent(Bool.self, forKey: .isDisabled)
    photo = try container.decodeIfPresent(String.self, forKey: .photo)
    username = try container.decodeIfPresent(String.self, forKey: .username)
    mobile = try container.decodeIfPresent(String.self, forKey: .mobile)
    isVerified = try container.decodeIfPresent(Bool.self, forKey: .isVerified)
    id = try container.decodeIfPresent(String.self, forKey: .id)
    accountType = try container.decodeIfPresent(String.self, forKey: .accountType)
    urlBadge = try container.decodeIfPresent(String.self, forKey: .urlBadge)
    isShowBadge = try container.decodeIfPresent(Bool.self, forKey: .isShowBadge)
    isFollow = try container.decodeIfPresent(Bool.self, forKey: .isFollow)
    chatPrice = try container.decodeIfPresent(Int.self, forKey: .chatPrice)
  }

}
