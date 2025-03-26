//
//  ShopArray.swift
//  Persada
//
//  Created by Muhammad Noor on 30/04/20.
//  Copyright © 2020 Muhammad Noor. All rights reserved.
//

import Foundation

// MARK: - ShopArray
struct ShopArray: Codable {
    let code, message: String?
    let data: ShopData?
    
    enum CodingKeys: String, CodingKey {
        case code = "code"
        case data = "data"
        case message = "message"
    }
}

// MARK: - ShopData
struct ShopData: Codable {
    let shop: [Shop]?
    let pageable: Pageable?
    let totalPages, totalElements: Int?
    let last: Bool?
    let sort: Sort?
    let numberOfElements: Int?
    let first: Bool?
    let size, number: Int?
    let empty: Bool?
    
    enum CodingKeys: String, CodingKey {
        case shop = "content"
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

// MARK: - Shop
struct Shop: Codable {
    let id, typePost: String?
    let postProduct: PostProduct?
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
			case postProduct = "post"
			case typePost = "typePost"
	}
}

// MARK: - PostProduct
struct PostProduct: Codable {
    let id, name: String?
    let price: Int?
    let postProductDescription, color, size: String?
    let measurement: ProductMeasurement?
    let media: [Medias]?
    
    enum CodingKeys: String, CodingKey {
        case id, name, price
        case postProductDescription = "description"
        case color, size, measurement
		case media = "medias"
    }
}

// MARK: - Measurement
struct ProductMeasurement: Codable {
	var weight, length, height, width: Double?
}
