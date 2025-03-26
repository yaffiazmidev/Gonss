//
//  RemoteFeedMedias.swift
//
//  Created by DENAZMI on 24/09/23
//  Copyright (c) . All rights reserved.
//

import Foundation

struct RemoteFeedMedias: Codable {

  enum CodingKeys: String, CodingKey {
    case vodUrl
    case id
    case metadata
    case vodFileId
    case type
    case url
    case thumbnail
    case isMp4Ready
  }

  var vodUrl: String?
  var id: String?
  var metadata: RemoteFeedMetadata?
  var vodFileId: String?
  var type: String?
  var url: String?
  var thumbnail: RemoteFeedThumbnail?
  var isMp4Ready: Bool?

     var playURL: String {
        get {
            if let videoURL = vodUrl, !videoURL.isEmpty {
                return videoURL
            }
            if let videoURL = url, !videoURL.isEmpty {
                return videoURL
            }
            return ""
        }
    }


  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    vodUrl = try container.decodeIfPresent(String.self, forKey: .vodUrl)
    id = try container.decodeIfPresent(String.self, forKey: .id)
    metadata = try container.decodeIfPresent(RemoteFeedMetadata.self, forKey: .metadata)
    vodFileId = try container.decodeIfPresent(String.self, forKey: .vodFileId)
    type = try container.decodeIfPresent(String.self, forKey: .type)
    url = try container.decodeIfPresent(String.self, forKey: .url)
    thumbnail = try container.decodeIfPresent(RemoteFeedThumbnail.self, forKey: .thumbnail)
    isMp4Ready = try container.decodeIfPresent(Bool.self, forKey: .isMp4Ready)
  }

}
