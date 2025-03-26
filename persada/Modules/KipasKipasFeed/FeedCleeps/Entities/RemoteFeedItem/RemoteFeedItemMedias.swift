//
//  RemoteFeedItemMedias.swift
//
//  Created by DENAZMI on 04/10/23
//  Copyright (c) . All rights reserved.
//

import Foundation

public struct RemoteFeedItemMedias: Codable {

  enum CodingKeys: String, CodingKey {
    case id
    case metadata
    case type
    case isMp4Ready
    case hlsUrl
    case vodFileId
    case vodUrl
    case thumbnail
    case url
    case isHlsReady
  }

    public var id: String?
    public var metadata: RemoteFeedItemMetadata?
    public var type: String?
    public var isMp4Ready: Bool?
    public var hlsUrl: String?
    public var vodFileId: String?
    public var thumbnail: RemoteFeedItemThumbnail?
    public var isHlsReady: Bool?
    public var url: String?
    public var vodUrl: String?

    public var playURL: String {
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

    public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    id = try container.decodeIfPresent(String.self, forKey: .id)
    metadata = try container.decodeIfPresent(RemoteFeedItemMetadata.self, forKey: .metadata)
    type = try container.decodeIfPresent(String.self, forKey: .type)
    isMp4Ready = try container.decodeIfPresent(Bool.self, forKey: .isMp4Ready)
    hlsUrl = try container.decodeIfPresent(String.self, forKey: .hlsUrl)
    vodFileId = try container.decodeIfPresent(String.self, forKey: .vodFileId)
    vodUrl = try container.decodeIfPresent(String.self, forKey: .vodUrl)
    thumbnail = try container.decodeIfPresent(RemoteFeedItemThumbnail.self, forKey: .thumbnail)
    url = try container.decodeIfPresent(String.self, forKey: .url)
    isHlsReady = try container.decodeIfPresent(Bool.self, forKey: .isHlsReady)
  }
    
    public static func == (lhs: RemoteFeedItemMedias, rhs: RemoteFeedItemMedias) -> Bool {
        return lhs.id == rhs.id
    }
}
