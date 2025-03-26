//
//  RemoteDonationDetailMedias.swift
//
//  Created by DENAZMI on 28/02/23
//  Copyright (c) . All rights reserved.
//

import Foundation

struct RemoteDonationDetailMedias: Codable {

  enum CodingKeys: String, CodingKey {
    case isHlsReady
    case id
    case type
    case thumbnail
    case metadata
    case hlsUrl
    case url
  }

  var isHlsReady: Bool?
  var id: String?
  var type: String?
  var thumbnail: RemoteDonationDetailThumbnail?
  var metadata: RemoteDonationDetailMetadata?
  var hlsUrl: String?
  var url: String?



  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    isHlsReady = try container.decodeIfPresent(Bool.self, forKey: .isHlsReady)
    id = try container.decodeIfPresent(String.self, forKey: .id)
    type = try container.decodeIfPresent(String.self, forKey: .type)
    thumbnail = try container.decodeIfPresent(RemoteDonationDetailThumbnail.self, forKey: .thumbnail)
    metadata = try container.decodeIfPresent(RemoteDonationDetailMetadata.self, forKey: .metadata)
    hlsUrl = try container.decodeIfPresent(String.self, forKey: .hlsUrl)
    url = try container.decodeIfPresent(String.self, forKey: .url)
  }

}
