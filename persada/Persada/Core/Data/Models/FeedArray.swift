//
//  FeedArray.swift
//  Persada
//
//  Created by Muhammad Noor on 05/04/20.
//  Copyright © 2020 Muhammad Noor. All rights reserved.
//

import Foundation

// MARK: - SelebArray
struct FeedArray: Codable {
	let code, message: String?
	var data: FeedData?
	
	enum CodingKeys: String, CodingKey {
		case code = "code"
		case data = "data"
		case message = "message"
	}
}

// MARK: - FeedData
struct FeedData: Codable {
	var content: [Feed]?
	let pageable: Pageable?
	let totalPages, totalElements: Int?
	let last: Bool?
	let sort: Sort?
	let numberOfElements: Int?
	let first: Bool?
	let size, number: Int?
	let empty: Bool?
}

// MARK: - Feed
struct Feed: Codable, Hashable, Equatable {
    
	let id: String?
	let typePost: String?
    var post: Post?
	let createAt: Int?
	var likes, comments: Int?
	var account: Profile?
	var isRecomm, isReported, isLike, isFollow, isProductActiveExist: Bool?
	let stories: [Stories]?
	var feedPages: String?
    var hashValue: Int {
         return id.hashValue
     }
    let valueBased: String?
    let typeBased: String?
    let similarBy: String?
    let mediaCategory: String?
    var feedIndex: Int? = 0
    let totalView: Int?
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
	var statusLike: String {
		return isLike == false ? "unlike" : "like"
	}
    
    static func == (lhs: Feed, rhs: Feed) -> Bool {
        return lhs.id == rhs.id
    }
    
	func mapToProfileContent() -> ContentProfilePost {
        return ContentProfilePost(id: id, typePost: typePost, postStory: nil, createAt: createAt, likes: likes, comments: comments, account: account, isRecomm: isRecomm, isReported: isReported, isLike: isLike, isFollow: isFollow, isProductActiveExist: isProductActiveExist, post: post, postProduct: nil, totalView: totalView)
	}
}

// MARK: - PostProduct
struct PostStories: Codable {
	let id: String?
	let media: [Medias]?
	let postProduct: [PostProduct]?

	enum CodingKeys: String, CodingKey {
		case id
		case media = "medias"
		case postProduct = "postProducts"
	}

	init(from decoder: Decoder) throws {
		let values = try decoder.container(keyedBy: CodingKeys.self)
		id = try values.decodeIfPresent(String.self, forKey: .id)
		media = try values.decodeIfPresent([Medias].self, forKey: .media)
		postProduct = try values.decodeIfPresent([PostProduct].self, forKey: .postProduct)
	}
}


// MARK: - Post
struct Post: Codable {
	let type: String?
	var product: Product?
	let price: Int?
	let channel: Channel?
	let id, name, postDescription: String?
	let medias: [Medias]?
    let hashtags: [Hashtag]?
    let amountCollected: Double?
    let targetAmount: Double?
    var amountCollectedPercent: Float {
        return Float(Double(amountCollected ?? 0.0) / Double(targetAmount ?? 0.0))
    }
    let donationCategory: DonationCategory?
    let floatingLink, floatingLinkLabel, siteName, siteLogo: String?
    let levelPriority: Int?
    let title: String?
    let isDonationItem: Bool?

	enum CodingKeys: String, CodingKey {
		case medias
		case type
		case id
		case price
		case product
		case name
		case channel
		case postDescription = "description"
        case hashtags
        case amountCollected
        case targetAmount
        case donationCategory
        case floatingLink
        case floatingLinkLabel
        case siteName
        case siteLogo
        case title
        case levelPriority
        case isDonationItem
	}
    
    struct Hashtag: Codable {
        var value: String?
        var total: Int?
    }
}

public struct DonationCategory: Codable {
    public let id: String?
    public let icon: String?
    public let name: String?
}

public enum MediasType: String, Codable {
    case image
    case video
}

struct Medias: Codable {
    public var id: String?
    public var type: String?
    public var url: String?
    public var isHlsReady: Bool?
    public var hlsUrl: String?
    public var thumbnail: Thumbnail?
    public var metadata: Metadata?
    public var vodFileId: String?
    public var vodUrl: String?
}

struct Media: Codable {
    var id, type: String?
    var url, thumbnail: String?
    var metadata: Metadata?
}


