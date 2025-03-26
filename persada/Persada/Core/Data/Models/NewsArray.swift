//
//  News.swift
//  Persada
//
//  Created by Muhammad Noor on 05/04/20.
//  Copyright © 2020 Muhammad Noor. All rights reserved.
//

import Foundation

// MARK: - NewsArray
struct NewsArray: Codable {
	let code, message: String?
	let data: NewsData?
}

// MARK: - Seleb
struct NewsData: Codable {
	let content: [NewsDetail]?
	let pageable: Pageable?
	let totalPages, totalElements: Int?
	let last: Bool?
	let sort: Sort?
	let numberOfElements: Int?
	let first: Bool?
	let size, number: Int?
	let empty: Bool?
}

// MARK: - News
struct News: Codable {
	let id: String?
	let typePost: String?
	let postNews: PostNews?
	let createAt, likes, comments: Int?
	let account: Profile?
	let isLike, isFollow: Bool?
	
	enum CodingKeys: String, CodingKey {
		case account = "account"
		case comments = "comments"
		case createAt = "createAt"
		case id = "id"
		case isFollow = "isFollow"
		case isLike = "isLike"
		case likes = "likes"
		case postNews = "post"
		case typePost = "typePost"
	}
}

// MARK: - PostNews
struct PostNews: Codable {
	let id, siteReference, title: String?
	let media: [Medias]?
	let thumbnailUrl : String?
	
	enum CodingKeys: String, CodingKey {
		case id
		case title
		case siteReference
		case media = "medias"
		case thumbnailUrl
	}
}
