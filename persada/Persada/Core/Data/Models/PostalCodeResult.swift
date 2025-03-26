//
//  PostalCodeResult.swift
//  KipasKipas
//
//  Created by Azam Mukhtar on 14/04/21.
//  Copyright © 2021 Koanba. All rights reserved.
//

import Foundation

// MARK: - HashtagResponse
struct PostalCodeResult: Codable {
		let code, message: String?
		let data: PostalCodeData?
}

// MARK: - DataClass
struct PostalCodeData: Codable {
		let content: [PostalCodeContent]?
		let pageable: Pageable?
		let totalElements, totalPages: Int?
		let last: Bool?
		let sort: Sort?
		let numberOfElements, size, number: Int?
		let first, empty: Bool?
}

// MARK: - Content
struct PostalCodeContent: Codable {
		let area: [PostalCodeArea]?
		let postalCode: [Area]?
}

// MARK: - Area
struct PostalCodeArea: Codable {
		let id, name: String?
}

//// MARK: - PostalCode
//struct PostalCode: Codable {
//		let value: String?
//}
