//
//  RemoteFeedPost.swift
//
//  Created by DENAZMI on 24/09/23
//  Copyright (c) . All rights reserved.
//

import Foundation

struct RemoteFeedPost: Codable {

  enum CodingKeys: String, CodingKey {
    case id
    case type
    case descriptionValue = "description"
    case medias
    case hashtags
    case channel
    case floatingLinkLabel
    case isScheduled
    case floatingLink
    case status
  }

  var id: String?
  var type: String?
  var descriptionValue: String?
  var medias: [RemoteFeedMedias]?
  var hashtags: [RemoteFeedHashtags]?
  var channel: RemoteFeedChannel?
  var floatingLinkLabel: String?
  var isScheduled: Bool?
  var floatingLink: String?
  var status: String?



  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    id = try container.decodeIfPresent(String.self, forKey: .id)
    type = try container.decodeIfPresent(String.self, forKey: .type)
    descriptionValue = try container.decodeIfPresent(String.self, forKey: .descriptionValue)
    medias = try container.decodeIfPresent([RemoteFeedMedias].self, forKey: .medias)
    hashtags = try container.decodeIfPresent([RemoteFeedHashtags].self, forKey: .hashtags)
    channel = try container.decodeIfPresent(RemoteFeedChannel.self, forKey: .channel)
    floatingLinkLabel = try container.decodeIfPresent(String.self, forKey: .floatingLinkLabel)
    isScheduled = try container.decodeIfPresent(Bool.self, forKey: .isScheduled)
    floatingLink = try container.decodeIfPresent(String.self, forKey: .floatingLink)
    status = try container.decodeIfPresent(String.self, forKey: .status)
  }

}
