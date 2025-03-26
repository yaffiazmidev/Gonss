//
//  RemoteStoreItemData.swift
//
//  Created by DENAZMI on 05/01/24
//  Copyright (c) . All rights reserved.
//

import Foundation

struct RemoteStoreItemData: Codable {

  enum CodingKeys: String, CodingKey {
    case sellerName
    case thumbnail
    case photo
    case accountId
    case city
  }

  var sellerName: String?
  var thumbnail: RemoteStoreItemThumbnail?
  var photo: String?
  var accountId: String?
  var city: String?



  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    sellerName = try container.decodeIfPresent(String.self, forKey: .sellerName)
    thumbnail = try container.decodeIfPresent(RemoteStoreItemThumbnail.self, forKey: .thumbnail)
    photo = try container.decodeIfPresent(String.self, forKey: .photo)
    accountId = try container.decodeIfPresent(String.self, forKey: .accountId)
    city = try container.decodeIfPresent(String.self, forKey: .city)
  }

}
