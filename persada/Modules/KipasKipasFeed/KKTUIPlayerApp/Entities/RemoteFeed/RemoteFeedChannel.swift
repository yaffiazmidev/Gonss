//
//  RemoteFeedChannel.swift
//
//  Created by DENAZMI on 24/09/23
//  Copyright (c) . All rights reserved.
//

import Foundation

struct RemoteFeedChannel: Codable {

  enum CodingKeys: String, CodingKey {
    case createAt
    case createBy
    case id
    case descriptionValue = "description"
    case photo
    case name
    case code
  }

  var createAt: Int?
  var createBy: String?
  var id: String?
  var descriptionValue: String?
  var photo: String?
  var name: String?
  var code: String?



  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    createAt = try container.decodeIfPresent(Int.self, forKey: .createAt)
    createBy = try container.decodeIfPresent(String.self, forKey: .createBy)
    id = try container.decodeIfPresent(String.self, forKey: .id)
    descriptionValue = try container.decodeIfPresent(String.self, forKey: .descriptionValue)
    photo = try container.decodeIfPresent(String.self, forKey: .photo)
    name = try container.decodeIfPresent(String.self, forKey: .name)
    code = try container.decodeIfPresent(String.self, forKey: .code)
  }

}
