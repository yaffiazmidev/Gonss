//
//  RemoteFollowingContent.swift
//
//  Created by DENAZMI on 02/08/23
//  Copyright (c) . All rights reserved.
//

import Foundation

public struct RemoteFollowingContent: Codable {

  enum CodingKeys: String, CodingKey {
    case isVerified
    case username
    case photo
    case name
    case isFollow
    case id
  }

    public var isVerified: Bool?
    public var username: String?
    public var photo: String?
    public var name: String?
    public var isFollow: Bool?
    public var id: String?


  public init(isVerified: Bool? = nil, username: String? = nil, photo: String? = nil, name: String? = nil, isFollow: Bool? = nil, id: String? = nil) {
        self.isVerified = isVerified
        self.username = username
        self.photo = photo
        self.name = name
        self.isFollow = isFollow
        self.id = id
    }

  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    isVerified = try container.decodeIfPresent(Bool.self, forKey: .isVerified)
    username = try container.decodeIfPresent(String.self, forKey: .username)
    photo = try container.decodeIfPresent(String.self, forKey: .photo)
    name = try container.decodeIfPresent(String.self, forKey: .name)
    isFollow = try container.decodeIfPresent(Bool.self, forKey: .isFollow)
    id = try container.decodeIfPresent(String.self, forKey: .id)
  }
}
