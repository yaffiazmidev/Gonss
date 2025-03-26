//
//  NewsCategoryResult.swift
//  KipasKipas
//
//  Created by movan on 24/11/20.
//  Copyright © 2020 Muhammad Noor. All rights reserved.
//

import Foundation

// MARK: - NewsCategoryResult
struct NewsCategoryResult: Codable, Hashable, Equatable {
	
	
	static func == (lhs: NewsCategoryResult, rhs: NewsCategoryResult) -> Bool {
		return lhs.identifier == rhs.identifier
	}
	
	func hash(into hasher: inout Hasher) {
		hasher.combine(identifier)
	}
	
	let identifier: UUID = UUID()
	let code, message : String?
	let data : [NewsCategoryData]?

	enum CodingKeys: String, CodingKey {
			case code = "code"
			case data = "data"
			case message = "message"
	}

}

// MARK: - NewsCategoryData
struct NewsCategoryData: Codable, Hashable, Equatable {
	
	static func == (lhs: NewsCategoryData, rhs: NewsCategoryData) -> Bool {
		return lhs.identifier == rhs.identifier
	}
	
	func hash(into hasher: inout Hasher) {
		hasher.combine(identifier)
	}
	
	let identifier: UUID = UUID()
	let id, name, slug : String?
	let totalNews : Int?
    var selected : Bool?

	enum CodingKeys: String, CodingKey {
			case id = "id"
			case name = "name"
			case slug = "slug"
			case totalNews = "totalNews"
            case selected = "selected"
	}
}
