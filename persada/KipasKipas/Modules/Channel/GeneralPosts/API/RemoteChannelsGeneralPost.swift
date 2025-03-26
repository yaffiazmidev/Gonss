//
//  RemoteChannelsGeneralPost.swift
//  KipasKipas
//
//  Created by DENAZMI on 17/12/22.
//  Copyright © 2022 Koanba. All rights reserved.
//

import Foundation

struct RemoteChannelsGeneralPost: Codable {
    var sort: RemoteChannelsGeneralPostSort?
    var pageable: RemoteChannelsGeneralPostPageable?
    var content: [RemoteChannelsGeneralPostContent]?
    var first: Bool?
    var numberOfElements: Int?
    var totalElements: Int?
    var totalPages: Int?
    var last: Bool?
    var number: Int?
    var empty: Bool?
    var size: Int?
}

struct RemoteChannelsGeneralPostContent: Codable {
    var createAt: Int?
    var isReported: Bool?
    var isFollow: Bool?
    var likes: Int?
    var isLike: Bool?
    var account: RemoteChannelsGeneralPostAccount?
    var typePost: String?
    var stories: [String]?
    var id: String?
    var post: RemoteChannelsGeneralPostPost?
    var comments: Int?
    var mediaCategory: String?
}

struct RemoteChannelsGeneralPostMetadata: Codable {
    var height: String?
    var size: String?
    var width: String?
}

struct RemoteChannelsGeneralPostProduct: Codable {
    var id: String?
    var price: Int?
    var name: String?
    var measurement: RemoteChannelsGeneralPostMeasurement?
    var description: String?
    var isBanned: Bool?
    var generalStatus: String?
    var isDeleted: Bool?
    var medias: [RemoteChannelsGeneralPostMedias]?
}

struct RemoteChannelsGeneralPostMeasurement: Codable {
    var width: Double?
    var height: Double?
    var weight: Double?
    var length: Double?
}

struct RemoteChannelsGeneralPostPageable: Codable {
    var offset: Int?
    var sort: RemoteChannelsGeneralPostSort?
    var startId: String?
    var pageNumber: Int?
    var nocache: Bool?
    var unpaged: Bool?
    var offsetPage: Int?
    var pageSize: Int?
    var paged: Bool?
}

struct RemoteChannelsGeneralPostAccount: Codable {
    var id: String?
    var isDisabled: Bool?
    var name: String?
    var isSeleb: Bool?
    var username: String?
    var email: String?
    var isVerified: Bool?
    var isSeller: Bool?
    var mobile: String?
    var isFollow: Bool?
    var photo: String?
    var chatPrice: Int?
}

struct RemoteChannelsGeneralPostPost: Codable {
    var id: String?
    var channel: RemoteChannelsGeneralPostChannel?
    var hashtags: [RemoteChannelsGeneralPostHashtags]?
    var type: String?
    var description: String?
    var medias: [RemoteChannelsGeneralPostMedias]?
    var product: RemoteChannelsGeneralPostProduct?
    let floatingLink, floatingLinkLabel, siteName, siteLogo: String?
    let levelPriority: Int?
    let isDonationItem: Bool?
}

struct RemoteChannelsGeneralPostHashtags: Codable {
    var value: String?
    var total: Int?
}

struct RemoteChannelsGeneralPostMedias: Codable {
    var isHlsReady: Bool?
    var url: String?
    var hlsUrl: String?
    var type: String?
    var thumbnail: RemoteChannelsGeneralPostThumbnail?
    var id: String?
    var metadata: RemoteChannelsGeneralPostMetadata?
}

struct RemoteChannelsGeneralPostThumbnail: Codable {
    var large: String?
    var medium: String?
    var small: String?
}

struct RemoteChannelsGeneralPostSort: Codable {
    var unsorted: Bool?
    var empty: Bool?
    var sorted: Bool?
}

struct RemoteChannelsGeneralPostChannel: Codable {
    var name: String?
    var description: String?
    var photo: String?
    var createAt: Int?
    var id: String?
    var code: String?
}
