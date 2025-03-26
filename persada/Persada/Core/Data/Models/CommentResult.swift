//
//  CommentResult.swift
//  Persada
//
//  Created by Muhammad Noor on 20/05/20.
//  Copyright © 2020 Muhammad Noor. All rights reserved.
//

import Foundation

// MARK: - CommentResult
struct CommentResult: Codable {
    var code: String?
    var message: String?
    var data: CommentData?
    
    enum CodingKeys: String, CodingKey {
        case code = "code"
        case message = "message"
        case data = "data"
    }
}

struct CommentData: Codable {
    var content: [Comment]?
    var pageable: Pageable?
    var totalPages: Int?
    var totalElements: Int?
    var last: Bool?
    var first: Bool?
    var sort: Sort?
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


// MARK: - Content
struct Comment: Codable, Equatable {
    var id: String?
    var createAt: Int?
    var value: String?
    var commentSubs: [Subcomment]?
    var account: Profile?
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
    
    static func == (lhs: Comment, rhs: Comment) -> Bool {
        return lhs.id == rhs.id
    }
}

// MARK: - Post
struct PostComment: Codable {
    var id, postDescription: String?
    var comment: [Comment]?
    
    enum CodingKeys: String, CodingKey {
        case id
        case postDescription = "description"
        case comment
    }
}

