//
//  StoryArray.swift
//  Persada
//
//  Created by Muhammad Noor on 29/05/20.
//  Copyright © 2020 Muhammad Noor. All rights reserved.
//

import Foundation


// MARK: - StoryResult
struct StoryArray: Codable {
	var code, message: String?
	var data: StoryData?
}

// MARK: - StoryData
struct StoryData: Codable {
	var content: [Story]?
	var pageable: Pageable?
	var totalPages, totalElements: Int?
	var last, first: Bool?
	var sort: Sort?
	var numberOfElements, size, number: Int?
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

// MARK: - Story
struct Story: Codable {
	var id, typePost: String?
	var stories: [Stories]?
	var createAt: Int?
	var account: Profile?
	
	enum CodingKeys: String, CodingKey {
		case account = "account"
		case createAt = "createAt"
		case id = "id"
		case stories = "stories"
		case typePost = "typePost"
	}
}

// MARK: - Stories
struct Stories: Codable {
	let id: String?
	let media: [Medias]?
	let postProducts: [Product]?
	let createAt: Int?
	
	enum CodingKeys: String, CodingKey {
		case id
		case media = "medias"
		case postProducts = "products"
		case createAt
	}
}

