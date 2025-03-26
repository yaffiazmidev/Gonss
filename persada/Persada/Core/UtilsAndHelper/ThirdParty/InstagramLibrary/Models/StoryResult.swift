//
//  StoryResult.swift
//  Persada
//
//  Created by Muhammad Noor on 29/05/20.
//  Copyright © 2020 Muhammad Noor. All rights reserved.
//

import Foundation


// MARK: - StoryResult
struct StoryResult: Codable {
	var code, message: String?
	var data: StoriesData?
	
	func copy() throws -> StoryResult {
			let data = try JSONEncoder().encode(self)
			let copy = try JSONDecoder().decode(StoryResult.self, from: data)
			return copy
	}
}

struct PublicStoryResult: Codable {
    var code, message: String?
    var data: StoryContentData?
}

struct StoriesData: Codable {
    var myFeedStory : StoriesItem?
    var feedStoryAnotherAccounts : StoryContentData?
    
    enum CodingKeys: String, CodingKey {
        case myFeedStory
        case feedStoryAnotherAccounts
    }
}

// MARK: - StoryData
struct StoryContentData: Codable {
	var content: [StoriesItem]?
	var totalElements: Int
	
	func copy() throws -> StoryContentData {
			let data = try JSONEncoder().encode(self)
			let copy = try JSONDecoder().decode(StoryContentData.self, from: data)
			return copy
	}
	
	enum CodingKeys: String, CodingKey {
		case content = "content"
		case totalElements = "totalElements"
	}
}

// MARK: - Story
struct StoriesItem: Codable, Equatable {
	var id, typePost: String?
	var stories: [StoryItem]?
	var createAt: Int?
	var account: Profile?
	var lastPlayedSnapIndex = 0
	var isCompletelyVisible = false
	var isCancelledAbruptly = false
    var isBadgeActive: Bool?
	
	var storiesCount: Int? {
		return stories?.count ?? 0
	}
	
	static func == (lhs: StoriesItem, rhs: StoriesItem) -> Bool {
		return lhs.id == rhs.id
	}
	
	enum CodingKeys: String, CodingKey {
		case account = "account"
		case createAt = "createAt"
		case id = "id"
		case stories = "stories"
		case typePost = "typePost"
        case isBadgeActive = "isBadgeActive"
	}
}

// MARK: - Stories
struct StoryItem: Codable {
	let id: String
	let medias: [MediasStory]?
	let products: [Product]?
	let createAt: Int?
	
	enum CodingKeys: String, CodingKey {
		case id
		case medias = "medias"
		case products = "products"
		case createAt
	}
}

struct MediasStory: Codable, Equatable {
	static func == (lhs: MediasStory, rhs: MediasStory) -> Bool {
		return lhs.id == rhs.id
	}	
	
	let id ,url, type: String
	let thumbnail: Thumbnail?
	let metadata: Metadata?
    let hlsUrl: String?
    let isHlsReady: Bool?
	
	public var kind: MimeType {
			switch type {
			case MimeType.image.rawValue:
					return MimeType.image
			case MimeType.video.rawValue:
					return MimeType.video
			default:
					return MimeType.unknown
			}
	}
}

public enum MimeType: String {
		case image
		case video
		case unknown
}
