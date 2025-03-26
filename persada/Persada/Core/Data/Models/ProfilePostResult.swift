//
//  ProfilePostResult.swift
//  Persada
//
//  Created by Muhammad Noor on 05/05/20.
//  Copyright © 2020 Muhammad Noor. All rights reserved.
//

import Foundation

// MARK: - ProfilePostResult
struct ProfilePostResult: Codable {
    var code, message: String?
    var data: ProfilePostData?
    
    enum CodingKeys: String, CodingKey {
        case code = "code"
        case data = "data"
        case message = "message"
    }
}

// MARK: - ProfilePostData
struct ProfilePostData: Codable {
    var content: [ContentProfilePost]?
    var pageable: Pageable?
    var totalPages, totalElements: Int?
    var last: Bool?
    var sort: Sort?
    var numberOfElements: Int?
    var first: Bool?
    var size, number: Int?
    var empty: Bool?
    
    enum CodingKeys: String, CodingKey {
        case content = "content"
        case empty = "empty"
        case first = "first"
        case last = "last"
        case number = "number"
        case numberOfElements = "numberOfElements"
        case pageable = "pageable"
        case size = "size"
        case sort = "sort"
        case totalElements = "totalElements"
        case totalPages = "totalPages"
    }
}

// MARK: - ContentProfilePost
struct ContentProfilePost: Codable {
    var id: String?
    var typePost: String?
    var postStory: PostStories?
    var createAt, likes, comments: Int?
    var account: Profile?
	var isRecomm, isReported, isLike, isFollow, isProductActiveExist: Bool?
    var post: Post?
    var postProduct: PostProduct?
    var totalView: Int?
    
    enum CodingKeys: String, CodingKey {
        case account = "account"
        case comments = "comments"
        case createAt = "createAt"
        case id = "id"
		case isRecomm = "isRecomm"
		case isReported = "isReported"
        case isFollow = "isFollow"
        case isLike = "isLike"
        case isProductActiveExist = "isProductActiveExist"
        case likes = "likes"
        case post = "post"
        case postProduct = "postProduct"
        case postStory = "postStory"
        case typePost = "typePost"
        case totalView = "totalView"
    }
    
	func mapToFeed() -> Feed {
		return Feed(id: id, typePost: typePost, post: post, createAt: createAt, likes: likes, comments: comments, account: account, isRecomm: isRecomm, isReported: isReported, isLike: isLike, isFollow: isFollow, stories: nil, feedPages: nil, valueBased: nil, typeBased: nil, similarBy: nil, mediaCategory: nil, totalView: totalView)
	}
}

