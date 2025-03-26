//
//  RemoteExploreEntity.swift
//  KipasKipas
//
//  Created by DENAZMI on 07/03/22.
//  Copyright © 2022 Koanba. All rights reserved.
//

import Foundation

struct ChannelGeneralPostEntity {
    
    var content: [ChannelGeneralPostEntityContent]?
    var first: Bool?
    var numberOfElements: Int?
    var totalElements: Int?
    var totalPages: Int?
    var last: Bool?
    var number: Int?
    var empty: Bool?
    var size: Int?
}

struct ChannelGeneralPostEntityContent {
    
    var createAt: Int?
    var isReported: Bool?
    var isFollow: Bool?
    var likes: Int?
    var isLike: Bool?
    var account: ChannelGeneralPostEntityAccount?
    var typePost: String?
    var stories: Any?
    var id: String?
    var post: ChannelGeneralPostEntityPost?
    var comments: Int?
    var mediaCategory: String?
    var totalView: Int?
}

struct ChannelGeneralPostEntityAccount {
    
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
}

struct ChannelGeneralPostEntityPost {
    
    var id: String?
    var channel: ChannelGeneralPostEntityChannel?
    var hashtags: [ChannelGeneralPostEntityHashtags]?
    var type: String?
    var description: String?
    var medias: [ChannelGeneralPostEntityMedias]?
    var product: ChannelGeneralPostEntityProduct?
}

struct ChannelGeneralPostEntityHashtags {

  var value: String?
  var total: Int?
}

struct ChannelGeneralPostEntityChannel {
    
    var name: String?
    var description: String?
    var photo: String?
    var createAt: Int?
    var id: String?
    var code: String?
}

struct ChannelGeneralPostEntityMedias {
    
    var isHlsReady: Bool?
    var url: String?
    var hlsUrl: String?
    var type: String?
    var thumbnail: ChannelGeneralPostEntityThumbnail?
    var id: String?
    var metadata: ChannelGeneralPostEntityMetadata?
}

struct ChannelGeneralPostEntityThumbnail {
    
    var large: String?
    var medium: String?
    var small: String?
}

struct ChannelGeneralPostEntityMetadata {
    
    var height: String?
    var size: String?
    var width: String?
}

struct ChannelGeneralPostEntityProduct {
    
    var id: String?
    var price: Int?
    var name: String?
    var measurement: ChannelGeneralPostEntityMeasurement?
    var description: String?
    var isBanned: Bool?
    var generalStatus: String?
    var isDeleted: Bool?
}

struct ChannelGeneralPostEntityMeasurement {

  var width: Double?
  var height: Double?
  var weight: Double?
  var length: Double?
}
