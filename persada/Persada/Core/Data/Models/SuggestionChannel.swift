//
//  SuggestionChannel.swift
//  KipasKipas
//
//  Created by movan on 29/07/20.
//  Copyright © 2020 Muhammad Noor. All rights reserved.
//

import Foundation

struct SuggestionChannelResult : Codable {
	
	let code : String?
	let data : SuggestionChannelData?
	let message : String?
	
	enum CodingKeys: String, CodingKey {
		case code = "code"
		case data = "data"
		case message = "message"
	}
	
}

struct SuggestionChannelData : Codable {
	
	let content : [SuggestionChannel]?
	let empty : Bool?
	let first : Bool?
	let last : Bool?
	let number : Int?
	let numberOfElements : Int?
	let pageable : Pageable?
	let size : Int?
	let sort : Sort?
	let totalElements : Int?
	let totalPages : Int?
	
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


struct SuggestionChannel : Codable {
	
	var descriptionField : String?
	var id : String?
	var isFollow : Bool?
	var name : String?
	var photo : String?
	var posts : [PostChannel]?
	
	enum CodingKeys: String, CodingKey {
		case descriptionField = "description"
		case id = "id"
		case isFollow = "isFollow"
		case name = "name"
		case photo = "photo"
		case posts = "posts"
	}
}

struct PostChannel : Codable {
	
	let channel : Channel?
	let comments : Int?
	let descriptionField : String?
	let hashtags : [HashtagChannel]?
	let id : String?
	let medias : [Medias]?
	
	enum CodingKeys: String, CodingKey {
		case channel = "channel"
		case comments = "comments"
		case descriptionField = "description"
		case hashtags = "hashtags"
		case id = "id"
		case medias = "medias"
	}
}

struct HashtagChannel : Codable {
	
	let value : String?
	
	enum CodingKeys: String, CodingKey {
		case value = "value"
	}

}

