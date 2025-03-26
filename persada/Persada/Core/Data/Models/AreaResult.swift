//
//  AreaResult.swift
//  KipasKipas
//
//  Created by movan on 12/08/20.
//  Copyright © 2020 Muhammad Noor. All rights reserved.
//

import Foundation

struct AreaResult : Codable {
	
	let code : String?
	let data : AreaData?
	let message : String?
	
	enum CodingKeys: String, CodingKey {
		case code = "code"
		case data = "data"
		case message = "message"
	}
	
}

struct AreaData: Codable {
	let content : [Area]?
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

struct Area : Codable {
	
	let code : String?
	let id : String?
	let name : String?
	let postalCode : String?
	
	enum CodingKeys: String, CodingKey {
		case code = "code"
		case id = "id"
		case name = "name"
		case postalCode = "value"
	}
}

