//
//  SubcommentResult.swift
//  Persada
//
//  Created by NOOR on 26/06/20.
//  Copyright © 2020 Muhammad Noor. All rights reserved.
//

import Foundation

// MARK: - SubcommentResult
struct SubcommentResult: Codable {
    var code: String?
    var message: String?
    var data: SubcommentData?

    enum CodingKeys: String, CodingKey {
        case code = "code"
        case message = "message"
        case data = "data"
    }
}

// MARK: - SubcommentData
struct SubcommentData: Codable {
    var id : String?
    var account: Profile?
    var createAt: Int?
    var commentSubs: [Subcomment]?
    var value: String?
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case commentSubs = "commentSubs"
        case createAt = "createAt"
        case value = "value"
        case account = "account"
    }
}

// MARK: - Subcomment
struct Subcomment: Codable {
    var id: String?
    var account: Profile?
    var value: String?
    var createAt: Int?
    var isLike: Bool?
    var like: Int?
    var isReported: Bool?

    var comment : Comment {
        Comment(id: id, createAt: createAt, value: value, commentSubs: nil, account: account, isReported: isReported, isLike: isLike, like: like, comments: nil)
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
