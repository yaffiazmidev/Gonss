//
//  NewsDetailResult.swift
//  Persada
//
//  Created by Muhammad Noor on 06/05/20.
//  Copyright © 2020 Muhammad Noor. All rights reserved.
//

import Foundation


struct NewsDetailResult : Codable {
	
	let code : String?
	let data : NewsDetail?
	let message : String?
	
	enum CodingKeys: String, CodingKey {
		case code = "code"
		case data = "data"
		case message = "message"
	}
	
}

struct NewsDetail : Codable {
	
	let account : Profile?
	let createAt : Int?
	let id : String?
	let postNews : NewsDetailPostNews?
	let typePost : String?
	var comments : Int?
	var isLike : Bool?
	var likes : Int?
	
	var statusLike: String {
		return isLike == false ? "unlike" : "like"
	}
	
	enum CodingKeys: String, CodingKey {
		case account = "account"
		case createAt = "createAt"
		case id = "id"
		case postNews = "post"
		case typePost = "typePost"
		case comments = "comments"
		case isLike = "isLike"
		case likes = "likes"
	}
}

struct NewsDetailPostNews : Codable {
	
	let content : String?
	let descriptionField : String?
	let editor : String?
	let headline : String?
	let id : String?
	let isDraft : String?
	let linkReference : String?
	let medias : [Medias]?
	let newsCategory : NewsCategory?
	let publisher : String?
	let siteReference : String?
	let title : String?
	let type : String?
    let author: String?
    let fullUrl: String?
    let thumbnailUrl: String?
	
	enum CodingKeys: String, CodingKey {
		case content = "content"
		case descriptionField = "description"
		case editor = "editor"
		case headline = "headline"
		case id = "id"
		case isDraft = "isDraft"
		case linkReference = "linkReference"
		case medias = "medias"
		case newsCategory = "newsCategory"
		case publisher = "publisher"
		case siteReference = "siteReference"
		case title = "title"
		case type = "type"
        case author = "author"
        case fullUrl = "fullUrl"
        case thumbnailUrl = "thumbnailUrl"
	}
	
}

struct NewsCategory : Codable {
	
	let id : String?
	let name : String?
	
	enum CodingKeys: String, CodingKey {
		case id = "id"
		case name = "name"
	}
}
