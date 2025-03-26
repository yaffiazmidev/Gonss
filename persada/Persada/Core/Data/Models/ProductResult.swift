//
//  ProductResult.swift
//  KipasKipas
//
//  Created by movan on 06/08/20.
//  Copyright © 2020 Muhammad Noor. All rights reserved.
//

import Foundation

struct ProductResult : Codable {
	
	let code : String?
	let data : ProductData?
	let message : String?
	
	enum CodingKeys: String, CodingKey {
		case code = "code"
		case data = "data"
		case message = "message"
	}
	
}

struct ProductDetailResult : Codable {
    
    let code : String?
    let data : Product?
    let message : String?
    
    enum CodingKeys: String, CodingKey {
        case code = "code"
        case data = "data"
        case message = "message"
    }
    
}

struct ProductResultById : Codable {

	let code : String?
	let data : [Product]?
	let message : String?

	enum CodingKeys: String, CodingKey {
		case code = "code"
		case data = "data"
		case message = "message"
	}

}

struct ProductData : Codable {
	
	let content : [Product]?
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

// MARK: - Product
struct Product: Codable {
	var accountId : String?
	var postProductDescription : String?
	var generalStatus : String?
	var id : String?
	var isDeleted : Bool?
	var measurement : ProductMeasurement?
	var medias : [Medias]?
	var name : String?
    var price : Double?
	var stock : Int?
	var sellerName : String?
	var sold : Bool?
	var productPages: String?
    var reasonBanned: String?
    var totalSales: Int?
    var city: String?
    var ratingAverage: Double?
    var ratingCount: Int?
    var categoryId: String?
    var categoryName: String?
    var modal: Double?
    var commission: Double?
    var isResellerAllowed: Bool?
    var isAlreadyReseller: Bool?
    var type: String?
    var isBanned: Bool?
    var originalAccountId: String?
	
	enum CodingKeys: String, CodingKey {
		case accountId = "accountId"
		case postProductDescription = "description"
		case generalStatus = "generalStatus"
		case id = "id"
		case isDeleted = "isDeleted"
		case measurement = "measurement"
		case medias = "medias"
		case name = "name"
        case price = "price"
		case stock = "stock"
		case sellerName = "sellerName"
		case sold = "sold"
        case reasonBanned = "reasonBanned"
        case totalSales = "totalSales"
        case city = "city"
        case ratingAverage = "ratingAverage"
        case ratingCount = "ratingCount"
        case categoryId = "productCategoryId"
        case categoryName = "productCategoryName"
        case modal = "modal"
        case commission = "commission"
        case isResellerAllowed = "isResellerAllowed"
        case isAlreadyReseller = "isAlreadyReseller"
        case type = "type"
        case isBanned = "isBanned"
        case originalAccountId = "originalAccountId"
	}
}


