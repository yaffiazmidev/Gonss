//
//  RemoteCommentEntity.swift
//  KipasKipas
//
//  Created by DENAZMI on 09/08/22.
//  Copyright © 2022 Koanba. All rights reserved.
//

import Foundation

struct RemoteCommentEntity: Codable {
    var code: String?
    var message: String?
    var data: RemoteCommentData?
    
    enum CodingKeys: String, CodingKey {
        case code = "code"
        case message = "message"
        case data = "data"
    }
}

struct RemoteCommentData: Codable {
    var content: [RemoteCommentContent]?
    var pageable: RemoteCommentPageable?
    var totalPages: Int?
    var totalElements: Int?
    var last: Bool?
    var first: Bool?
    var sort: RemoteCommentSort?
    var numberOfElements: Int?
    var size: Int?
    var number: Int?
    var empty: Bool?
    
    enum CodingKeys: String, CodingKey {
        case content = "content"
        case pageable = "pageable"
        case totalPages = "totalPages"
        case totalElements = "totalElements"
        case last = "last"
        case first = "first"
        case sort = "sort"
        case numberOfElements = "numberOfElements"
        case size = "size"
        case number = "number"
        case empty = "empty"
    }
}

struct RemoteCommentContent: Codable, Equatable {
    var id: String?
    var createAt: Int?
    var value: String?
    var commentSubs: [RemoteCommentSubcomment]?
    var account: RemoteCommentProfile?
    var isReported, isLike: Bool?
    var like: Int?
    var comments: Int? = 0
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case createAt = "createAt"
        case value = "value"
        case commentSubs = "commentSubs"
        case account = "account"
        case isLike = "isLike"
        case isReported = "isReported"
        case like = "like"
    }
    
    static func == (lhs: RemoteCommentContent, rhs: RemoteCommentContent) -> Bool {
        return lhs.id == rhs.id
    }
}

struct RemoteCommentPageable: Codable {
    let sort: RemoteCommentSort?
    let pageNumber, pageSize, offset: Int?
    let paged, unpaged: Bool?
}

struct RemoteCommentSort: Codable {
    let sorted, unsorted, empty: Bool?
    
    enum CodingKeys: String, CodingKey {
        case empty = "empty"
        case sorted = "sorted"
        case unsorted = "unsorted"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        empty = try values.decodeIfPresent(Bool.self, forKey: .empty)
        sorted = try values.decodeIfPresent(Bool.self, forKey: .sorted)
        unsorted = try values.decodeIfPresent(Bool.self, forKey: .unsorted)
    }
}

struct RemoteCommentSubcomment: Codable {
    var id: String?
    var account: RemoteCommentProfile?
    var value: String?
    var createAt: Int?
    var isLike: Bool?
    var like: Int?
    var isReported: Bool?

    var comment : RemoteCommentContent {
        RemoteCommentContent(id: id, createAt: createAt, value: value, commentSubs: nil, account: account, isReported: isReported, isLike: isLike, like: like, comments: nil)
    }
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case account = "account"
        case value = "value"
        case createAt = "createAt"
        case isLike = "isLike"
        case like = "like"
        case isReported = "isReported"
    }
}

struct RemoteCommentProfile : Codable {
    let accountType : String?
    let bio : String?
    let email : String?
    let id : String?
    let isFollow : Bool?
    let birthDate: String?
    let note: String?
    let isDisabled: Bool?
    let isSeleb: Bool?
    let isVerified : Bool?
    let mobile : String?
    let name : String?
    let photo : String?
    let username : String?
    let isSeller: Bool?
    let socialMedias: [RemoteCommentSocialMedia]?
    let urlBadge: String?
    let isShowBadge: Bool?
    
    enum CodingKeys: String, CodingKey {
        case accountType = "accountType"
        case bio = "bio"
        case email = "email"
        case id = "id"
        case isFollow = "isFollow"
        case birthDate = "birthDate"
        case note = "note"
        case isDisabled = "isDisabled"
        case isSeleb = "isSeleb"
        case isVerified = "isVerified"
        case mobile = "mobile"
        case name = "name"
        case photo = "photo"
        case username = "username"
        case isSeller = "isSeller"
        case socialMedias = "socialMedias"
        case urlBadge, isShowBadge
    }
}

struct RemoteCommentSocialMedia : Codable {
    let socialMediaType : String?
    let urlSocialMedia : String?
    
    enum CodingKeys: String, CodingKey {
        case socialMediaType = "socialMediaType"
        case urlSocialMedia = "urlSocialMedia"
    }
}
