//
//  RemoteFeedItemContent.swift
//
//  Created by DENAZMI on 04/10/23
//  Copyright (c) . All rights reserved.
//

import Foundation

public struct RemoteFeedItemContent: Codable {

  enum CodingKeys: String, CodingKey {
    case isVodAvailable
    case createAt
    case isLike
    case totalView
    case isReported
    case origin
    case post
    case likes
    case typePost
    case id
    case comments
    case trendingAt
    case account
    case mediaCategory
    case isFollow
  }

    public var isVodAvailable: Bool?
    public var createAt: Int?
    public var isLike: Bool?
    public var totalView: Int?
    public var isReported: Bool?
    public var origin: String?
    public var post: RemoteFeedItemPost?
    public var likes: Int?
    public var typePost: String?
    public var id: String?
    public var comments: Int?
    public var trendingAt: Int?
    public var account: RemoteFeedItemAccount?
    public var mediaCategory: String?
    public var isFollow: Bool?



    public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    isVodAvailable = try container.decodeIfPresent(Bool.self, forKey: .isVodAvailable)
    createAt = try container.decodeIfPresent(Int.self, forKey: .createAt)
    isLike = try container.decodeIfPresent(Bool.self, forKey: .isLike)
    totalView = try container.decodeIfPresent(Int.self, forKey: .totalView)
    isReported = try container.decodeIfPresent(Bool.self, forKey: .isReported)
    origin = try container.decodeIfPresent(String.self, forKey: .origin)
    post = try container.decodeIfPresent(RemoteFeedItemPost.self, forKey: .post)
    likes = try container.decodeIfPresent(Int.self, forKey: .likes)
    typePost = try container.decodeIfPresent(String.self, forKey: .typePost)
    id = try container.decodeIfPresent(String.self, forKey: .id)
    comments = try container.decodeIfPresent(Int.self, forKey: .comments)
    trendingAt = try container.decodeIfPresent(Int.self, forKey: .trendingAt)
    account = try container.decodeIfPresent(RemoteFeedItemAccount.self, forKey: .account)
    mediaCategory = try container.decodeIfPresent(String.self, forKey: .mediaCategory)
    isFollow = try container.decodeIfPresent(Bool.self, forKey: .isFollow)
  }

}
