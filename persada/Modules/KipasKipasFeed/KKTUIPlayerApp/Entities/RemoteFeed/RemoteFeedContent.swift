//
//  RemoteFeedContent.swift
//
//  Created by DENAZMI on 24/09/23
//  Copyright (c) . All rights reserved.
//

import Foundation

struct RemoteFeedContent: Codable {

  enum CodingKeys: String, CodingKey {
    case isReported
    case typePost
    case createAt
    case isFollow
    case id
    case origin
    case isVodAvailable
    case likes
    case mediaCategory
    case totalView
    case post
    case account
    case comments
    case isLike
  }

  var isReported: Bool?
  var typePost: String?
  var createAt: Int?
  var isFollow: Bool?
  var id: String?
  var origin: String?
  var isVodAvailable: Bool?
  var likes: Int?
  var mediaCategory: String?
  var totalView: Int?
  var post: RemoteFeedPost?
  var account: RemoteFeedAccount?
  var comments: Int?
  var isLike: Bool?



  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    isReported = try container.decodeIfPresent(Bool.self, forKey: .isReported)
    typePost = try container.decodeIfPresent(String.self, forKey: .typePost)
    createAt = try container.decodeIfPresent(Int.self, forKey: .createAt)
    isFollow = try container.decodeIfPresent(Bool.self, forKey: .isFollow)
    id = try container.decodeIfPresent(String.self, forKey: .id)
    origin = try container.decodeIfPresent(String.self, forKey: .origin)
    isVodAvailable = try container.decodeIfPresent(Bool.self, forKey: .isVodAvailable)
    likes = try container.decodeIfPresent(Int.self, forKey: .likes)
    mediaCategory = try container.decodeIfPresent(String.self, forKey: .mediaCategory)
    totalView = try container.decodeIfPresent(Int.self, forKey: .totalView)
    post = try container.decodeIfPresent(RemoteFeedPost.self, forKey: .post)
    account = try container.decodeIfPresent(RemoteFeedAccount.self, forKey: .account)
    comments = try container.decodeIfPresent(Int.self, forKey: .comments)
    isLike = try container.decodeIfPresent(Bool.self, forKey: .isLike)
  }

}
