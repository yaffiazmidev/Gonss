//
//  RemoteExplore.swift
//
//  Created by DENAZMI on 07/03/22
//  Copyright (c) Koanba. All rights reserved.
//

import Foundation

struct RemoteChannelGeneralPost: Codable {
    
    enum CodingKeys: String, CodingKey {
        case data
        case message
        case code
    }
    
    var data: RemoteChannelGeneralPostData?
    var message: String?
    var code: String?
    
    
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        data = try container.decodeIfPresent(RemoteChannelGeneralPostData.self, forKey: .data)
        message = try container.decodeIfPresent(String.self, forKey: .message)
        code = try container.decodeIfPresent(String.self, forKey: .code)
    }
}

struct RemoteChannelGeneralPostData: Codable {
    
    enum CodingKeys: String, CodingKey {
        case sort
        case pageable
        case content
        case first
        case numberOfElements
        case totalElements
        case totalPages
        case last
        case number
        case empty
        case size
    }
    
    var sort: RemoteChannelGeneralPostSort?
    var pageable: RemoteChannelGeneralPostPageable?
    var content: [RemoteChannelGeneralPostContent]?
    var first: Bool?
    var numberOfElements: Int?
    var totalElements: Int?
    var totalPages: Int?
    var last: Bool?
    var number: Int?
    var empty: Bool?
    var size: Int?
    
    
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        sort = try container.decodeIfPresent(RemoteChannelGeneralPostSort.self, forKey: .sort)
        pageable = try container.decodeIfPresent(RemoteChannelGeneralPostPageable.self, forKey: .pageable)
        content = try container.decodeIfPresent([RemoteChannelGeneralPostContent].self, forKey: .content)
        first = try container.decodeIfPresent(Bool.self, forKey: .first)
        numberOfElements = try container.decodeIfPresent(Int.self, forKey: .numberOfElements)
        totalElements = try container.decodeIfPresent(Int.self, forKey: .totalElements)
        totalPages = try container.decodeIfPresent(Int.self, forKey: .totalPages)
        last = try container.decodeIfPresent(Bool.self, forKey: .last)
        number = try container.decodeIfPresent(Int.self, forKey: .number)
        empty = try container.decodeIfPresent(Bool.self, forKey: .empty)
        size = try container.decodeIfPresent(Int.self, forKey: .size)
    }
}

struct RemoteChannelGeneralPostContent: Codable {
    
    enum CodingKeys: String, CodingKey {
        case createAt
        case isReported
        case isFollow
        case likes
        case isLike
        case account
        case typePost
        case stories
        case id
        case post
        case comments
        case mediaCategory
        case totalView
    }
    
    var createAt: Int?
    var isReported: Bool?
    var isFollow: Bool?
    var likes: Int?
    var isLike: Bool?
    var account: RemoteChannelGeneralPostAccount?
    var typePost: String?
    var stories: [String]?
    var id: String?
    var post: RemoteChannelGeneralPostPost?
    var comments: Int?
    var mediaCategory: String?
    var totalView: Int?
    
    
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        createAt = try container.decodeIfPresent(Int.self, forKey: .createAt)
        isReported = try container.decodeIfPresent(Bool.self, forKey: .isReported)
        isFollow = try container.decodeIfPresent(Bool.self, forKey: .isFollow)
        likes = try container.decodeIfPresent(Int.self, forKey: .likes)
        isLike = try container.decodeIfPresent(Bool.self, forKey: .isLike)
        account = try container.decodeIfPresent(RemoteChannelGeneralPostAccount.self, forKey: .account)
        typePost = try container.decodeIfPresent(String.self, forKey: .typePost)
        stories = try container.decodeIfPresent([String].self, forKey: .stories)
        id = try container.decodeIfPresent(String.self, forKey: .id)
        post = try container.decodeIfPresent(RemoteChannelGeneralPostPost.self, forKey: .post)
        comments = try container.decodeIfPresent(Int.self, forKey: .comments)
        mediaCategory = try container.decodeIfPresent(String.self, forKey: .mediaCategory)
        totalView = try container.decodeIfPresent(Int.self, forKey: .totalView)
    }
}

struct RemoteChannelGeneralPostMetadata: Codable {
    
    enum CodingKeys: String, CodingKey {
        case height
        case size
        case width
    }
    
    var height: String?
    var size: String?
    var width: String?
    
    
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        height = try container.decodeIfPresent(String.self, forKey: .height)
        size = try container.decodeIfPresent(String.self, forKey: .size)
        width = try container.decodeIfPresent(String.self, forKey: .width)
    }
}

struct RemoteChannelGeneralPostProduct: Codable {
    
    enum CodingKeys: String, CodingKey {
        case id
        case price
        case name
        case measurement
        case descriptionValue = "description"
        case isBanned
        case generalStatus
        case isDeleted
    }
    
    var id: String?
    var price: Int?
    var name: String?
    var measurement: RemoteChannelGeneralPostMeasurement?
    var descriptionValue: String?
    var isBanned: Bool?
    var generalStatus: String?
    var isDeleted: Bool?
    
    
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(String.self, forKey: .id)
        price = try container.decodeIfPresent(Int.self, forKey: .price)
        name = try container.decodeIfPresent(String.self, forKey: .name)
        measurement = try container.decodeIfPresent(RemoteChannelGeneralPostMeasurement.self, forKey: .measurement)
        descriptionValue = try container.decodeIfPresent(String.self, forKey: .descriptionValue)
        isBanned = try container.decodeIfPresent(Bool.self, forKey: .isBanned)
        generalStatus = try container.decodeIfPresent(String.self, forKey: .generalStatus)
        isDeleted = try container.decodeIfPresent(Bool.self, forKey: .isDeleted)
    }
}

struct RemoteChannelGeneralPostMeasurement: Codable {
    
    enum CodingKeys: String, CodingKey {
        case width
        case height
        case weight
        case length
    }
    
    var width: Double?
    var height: Double?
    var weight: Double?
    var length: Double?
    
    
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        width = try container.decodeIfPresent(Double.self, forKey: .width)
        height = try container.decodeIfPresent(Double.self, forKey: .height)
        weight = try container.decodeIfPresent(Double.self, forKey: .weight)
        length = try container.decodeIfPresent(Double.self, forKey: .length)
    }
}

struct RemoteChannelGeneralPostPageable: Codable {
    
    enum CodingKeys: String, CodingKey {
        case offset
        case sort
        case startId
        case pageNumber
        case nocache
        case unpaged
        case offsetPage
        case pageSize
        case paged
    }
    
    var offset: Int?
    var sort: RemoteChannelGeneralPostSort?
    var startId: String?
    var pageNumber: Int?
    var nocache: Bool?
    var unpaged: Bool?
    var offsetPage: Int?
    var pageSize: Int?
    var paged: Bool?
    
    
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        offset = try container.decodeIfPresent(Int.self, forKey: .offset)
        sort = try container.decodeIfPresent(RemoteChannelGeneralPostSort.self, forKey: .sort)
        startId = try container.decodeIfPresent(String.self, forKey: .startId)
        pageNumber = try container.decodeIfPresent(Int.self, forKey: .pageNumber)
        nocache = try container.decodeIfPresent(Bool.self, forKey: .nocache)
        unpaged = try container.decodeIfPresent(Bool.self, forKey: .unpaged)
        offsetPage = try container.decodeIfPresent(Int.self, forKey: .offsetPage)
        pageSize = try container.decodeIfPresent(Int.self, forKey: .pageSize)
        paged = try container.decodeIfPresent(Bool.self, forKey: .paged)
    }
}

struct RemoteChannelGeneralPostAccount: Codable {
    
    enum CodingKeys: String, CodingKey {
        case id
        case isDisabled
        case name
        case isSeleb
        case username
        case email
        case isVerified
        case isSeller
        case mobile
        case isFollow
        case photo
    }
    
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
    
    
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(String.self, forKey: .id)
        isDisabled = try container.decodeIfPresent(Bool.self, forKey: .isDisabled)
        name = try container.decodeIfPresent(String.self, forKey: .name)
        isSeleb = try container.decodeIfPresent(Bool.self, forKey: .isSeleb)
        username = try container.decodeIfPresent(String.self, forKey: .username)
        email = try container.decodeIfPresent(String.self, forKey: .email)
        isVerified = try container.decodeIfPresent(Bool.self, forKey: .isVerified)
        isSeller = try container.decodeIfPresent(Bool.self, forKey: .isSeller)
        mobile = try container.decodeIfPresent(String.self, forKey: .mobile)
        isFollow = try container.decodeIfPresent(Bool.self, forKey: .isFollow)
        photo = try container.decodeIfPresent(String.self, forKey: .photo)
    }
}

struct RemoteChannelGeneralPostPost: Codable {
    
    enum CodingKeys: String, CodingKey {
        case id
        case channel
        case hashtags
        case type
        case descriptionValue = "description"
        case medias
        case product
    }
    
    var id: String?
    var channel: RemoteChannelGeneralPostChannel?
    var hashtags: [RemoteChannelGeneralPostHashtags]?
    var type: String?
    var descriptionValue: String?
    var medias: [RemoteChannelGeneralPostMedias]?
    var product: RemoteChannelGeneralPostProduct?
    
    
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(String.self, forKey: .id)
        channel = try container.decodeIfPresent(RemoteChannelGeneralPostChannel.self, forKey: .channel)
        hashtags = try container.decodeIfPresent([RemoteChannelGeneralPostHashtags].self, forKey: .hashtags)
        type = try container.decodeIfPresent(String.self, forKey: .type)
        descriptionValue = try container.decodeIfPresent(String.self, forKey: .descriptionValue)
        medias = try container.decodeIfPresent([RemoteChannelGeneralPostMedias].self, forKey: .medias)
        product = try container.decodeIfPresent(RemoteChannelGeneralPostProduct.self, forKey: .product)
    }
}

struct RemoteChannelGeneralPostHashtags: Codable {
    
    enum CodingKeys: String, CodingKey {
        case value
        case total
    }
    
    var value: String?
    var total: Int?
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        value = try container.decodeIfPresent(String.self, forKey: .value)
        total = try container.decodeIfPresent(Int.self, forKey: .total)
    }
}

struct RemoteChannelGeneralPostMedias: Codable {
    
    enum CodingKeys: String, CodingKey {
        case isHlsReady
        case url
        case hlsUrl
        case type
        case thumbnail
        case id
        case metadata
    }
    
    var isHlsReady: Bool?
    var url: String?
    var hlsUrl: String?
    var type: String?
    var thumbnail: RemoteChannelGeneralPostThumbnail?
    var id: String?
    var metadata: RemoteChannelGeneralPostMetadata?
    
    
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        isHlsReady = try container.decodeIfPresent(Bool.self, forKey: .isHlsReady)
        url = try container.decodeIfPresent(String.self, forKey: .url)
        hlsUrl = try container.decodeIfPresent(String.self, forKey: .hlsUrl)
        type = try container.decodeIfPresent(String.self, forKey: .type)
        thumbnail = try container.decodeIfPresent(RemoteChannelGeneralPostThumbnail.self, forKey: .thumbnail)
        id = try container.decodeIfPresent(String.self, forKey: .id)
        metadata = try container.decodeIfPresent(RemoteChannelGeneralPostMetadata.self, forKey: .metadata)
    }
}

struct RemoteChannelGeneralPostThumbnail: Codable {
    
    enum CodingKeys: String, CodingKey {
        case large
        case medium
        case small
    }
    
    var large: String?
    var medium: String?
    var small: String?
    
    
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        large = try container.decodeIfPresent(String.self, forKey: .large)
        medium = try container.decodeIfPresent(String.self, forKey: .medium)
        small = try container.decodeIfPresent(String.self, forKey: .small)
    }
}

struct RemoteChannelGeneralPostSort: Codable {
    
    enum CodingKeys: String, CodingKey {
        case unsorted
        case empty
        case sorted
    }
    
    var unsorted: Bool?
    var empty: Bool?
    var sorted: Bool?
    
    
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        unsorted = try container.decodeIfPresent(Bool.self, forKey: .unsorted)
        empty = try container.decodeIfPresent(Bool.self, forKey: .empty)
        sorted = try container.decodeIfPresent(Bool.self, forKey: .sorted)
    }
}

struct RemoteChannelGeneralPostChannel: Codable {
    
    enum CodingKeys: String, CodingKey {
        case name
        case descriptionValue = "description"
        case photo
        case createAt
        case id
        case code
    }
    
    var name: String?
    var descriptionValue: String?
    var photo: String?
    var createAt: Int?
    var id: String?
    var code: String?
    
    
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decodeIfPresent(String.self, forKey: .name)
        descriptionValue = try container.decodeIfPresent(String.self, forKey: .descriptionValue)
        photo = try container.decodeIfPresent(String.self, forKey: .photo)
        createAt = try container.decodeIfPresent(Int.self, forKey: .createAt)
        id = try container.decodeIfPresent(String.self, forKey: .id)
        code = try container.decodeIfPresent(String.self, forKey: .code)
    }
}
