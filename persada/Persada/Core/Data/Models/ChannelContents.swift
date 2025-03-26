//
//  ChannelContents.swift
//  Persada
//
//  Created by Muhammad Noor on 08/04/20.
//  Copyright © 2020 Muhammad Noor. All rights reserved.
//

import Foundation

// MARK: - ChannelContent
struct ChannelContentArray: Codable {
	
	let code : String?
	let data : ChannelContents?
	let message : String?

	enum CodingKeys: String, CodingKey {
		case code = "code"
		case data = "data"
		case message = "message"
	}
}

// MARK: - ChannelContents
struct ChannelContents: Codable {

	let content : [Feed]?
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
