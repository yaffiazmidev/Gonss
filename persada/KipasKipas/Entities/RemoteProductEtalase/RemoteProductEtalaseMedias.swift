//
//  RemoteProductEtalaseMedias.swift
//
//  Created by DENAZMI on 05/01/24
//  Copyright (c) . All rights reserved.
//

import Foundation

struct RemoteProductEtalaseMedias: Codable {

  enum CodingKeys: String, CodingKey {
    case vodFileId
    case metadata
    case type
    case thumbnail
    case isHlsReady
    case isMp4Ready
    case vodUrl
    case id
    case hlsUrl
    case url
  }

  var vodFileId: String?
  var metadata: RemoteProductEtalaseMetadata?
  var type: String?
  var thumbnail: RemoteProductEtalaseThumbnail?
  var isHlsReady: Bool?
  var isMp4Ready: Bool?
  var vodUrl: String?
  var id: String?
  var hlsUrl: String?
  var url: String?



  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    vodFileId = try container.decodeIfPresent(String.self, forKey: .vodFileId)
    metadata = try container.decodeIfPresent(RemoteProductEtalaseMetadata.self, forKey: .metadata)
    type = try container.decodeIfPresent(String.self, forKey: .type)
    thumbnail = try container.decodeIfPresent(RemoteProductEtalaseThumbnail.self, forKey: .thumbnail)
    isHlsReady = try container.decodeIfPresent(Bool.self, forKey: .isHlsReady)
    isMp4Ready = try container.decodeIfPresent(Bool.self, forKey: .isMp4Ready)
    vodUrl = try container.decodeIfPresent(String.self, forKey: .vodUrl)
    id = try container.decodeIfPresent(String.self, forKey: .id)
    hlsUrl = try container.decodeIfPresent(String.self, forKey: .hlsUrl)
    url = try container.decodeIfPresent(String.self, forKey: .url)
  }

}
