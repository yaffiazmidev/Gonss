//
//  RemoteFeedItemChannel.swift
//
//  Created by DENAZMI on 04/10/23
//  Copyright (c) . All rights reserved.
//

import Foundation

public struct RemoteFeedItemChannel: Codable {

  enum CodingKeys: String, CodingKey {
    case id
    case descriptionValue = "description"
    case name
    case createAt
    case photo
    case code
    case createBy
  }

    public var id: String?
    public var descriptionValue: String?
    public var name: String?
    public var createAt: Int?
    public var photo: String?
    public var code: String?
    public var createBy: String?



    public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    id = try container.decodeIfPresent(String.self, forKey: .id)
    descriptionValue = try container.decodeIfPresent(String.self, forKey: .descriptionValue)
    name = try container.decodeIfPresent(String.self, forKey: .name)
    createAt = try container.decodeIfPresent(Int.self, forKey: .createAt)
    photo = try container.decodeIfPresent(String.self, forKey: .photo)
    code = try container.decodeIfPresent(String.self, forKey: .code)
    createBy = try container.decodeIfPresent(String.self, forKey: .createBy)
  }

}
