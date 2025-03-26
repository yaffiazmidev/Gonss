//
//  ChannelsGeneralPostsItem.swift
//  KipasKipas
//
//  Created by DENAZMI on 17/12/22.
//  Copyright © 2022 Koanba. All rights reserved.
//

import Foundation

struct ChannelsGeneralPostsItem {
    let contents: [ChannelsGeneralPostsContent]
    let totalPage: Int
}

struct ChannelsGeneralPostsContent {
    var createAt: Int
    var isReported: Bool
    var isFollow: Bool
    var likes: Int
    var isLike: Bool
    var account: ChannelsGeneralPostsContentAccount?
    var typePost: String
    var stories: [String]?
    var id: String
    var post: ChannelsGeneralPostsContentPost?
    var comments: Int
    var mediaCategory: String
    var totalView: Int?
}

struct ChannelsGeneralPostsContentMetadata {
    var height: String
    var size: String
    var width: String
}

struct ChannelsGeneralPostsContentProduct {
    var id: String
    var price: Int
    var name: String
    var measurement: ChannelsGeneralPostsContentMeasurement?
    var description: String
    var isBanned: Bool
    var generalStatus: String
    var isDeleted: Bool
    var medias: [ChannelsGeneralPostsContentMedias]?
}

struct ChannelsGeneralPostsContentMeasurement {
    var width: Double
    var height: Double
    var weight: Double
    var length: Double
}

struct ChannelsGeneralPostsContentPageable {
    var offset: Int
    var sort: ChannelsGeneralPostsContentSort?
    var startId: String
    var pageNumber: Int
    var nocache: Bool
    var unpaged: Bool
    var offsetPage: Int
    var pageSize: Int
    var paged: Bool
}

struct ChannelsGeneralPostsContentAccount {
    var id: String
    var isDisabled: Bool
    var name: String
    var isSeleb: Bool
    var username: String
    var email: String
    var isVerified: Bool
    var isSeller: Bool
    var mobile: String
    var isFollow: Bool
    var photo: String
    var chatPrice: Int
}

struct ChannelsGeneralPostsContentPost {
    var id: String
    var channel: ChannelsGeneralPostsContentChannel?
    var hashtags: [ChannelsGeneralPostsContentHashtags]?
    var type: String
    var description: String
    var medias: [ChannelsGeneralPostsContentMedias]?
    var product: ChannelsGeneralPostsContentProduct?
    let floatingLink, floatingLinkLabel, siteName, siteLogo: String?
    let levelPriority: Int?
    let isDonationItem: Bool?
}

struct ChannelsGeneralPostsContentHashtags {
    var value: String
    var total: Int
}

struct ChannelsGeneralPostsContentMedias {
    var isHlsReady: Bool
    var url: String
    var hlsUrl: String
    var type: String
    var thumbnail: ChannelsGeneralPostsContentThumbnail?
    var id: String
    var metadata: ChannelsGeneralPostsContentMetadata?
}

struct ChannelsGeneralPostsContentThumbnail {
    var large: String
    var medium: String
    var small: String
}

struct ChannelsGeneralPostsContentSort {
    var unsorted: Bool
    var empty: Bool
    var sorted: Bool
}

struct ChannelsGeneralPostsContentChannel {
    var name: String
    var description: String
    var photo: String
    var createAt: Int
    var id: String
    var code: String
}
