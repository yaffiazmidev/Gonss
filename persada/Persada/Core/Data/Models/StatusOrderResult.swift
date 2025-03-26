//
//  StatusOrderResult.swift
//  KipasKipas
//
//  Created by NOOR on 19/01/21.
//  Copyright © 2021 Koanba. All rights reserved.
//

import Foundation

struct StatusOrderResult : Codable {
	
	let code : String?
	let data : StatusOrderData?
	let message : String?
	
	enum CodingKeys: String, CodingKey {
		case code = "code"
		case data = "data"
		case message = "message"
	}
	
}

struct StatusOrderData : Codable {
	
	let content : [StatusOrder]?
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

struct StatusOrder : Codable {
	
	let amount : Int
	let cost : Int
	let courier : String
	let createAt : Int
	let expireTimePayment : Int
	let id : String
	let noInvoice : String
	let orderStatus : String
	let paymentStatus : String?
	let productId : String
	let productName : String
	let productPrice : Int
	let quantity : Int
	let sellerAccountId : String
	let sellerName : String
	let shipmentStatus : String?
	let urlPaymentPage : String
	let urlProductPhoto : String
	let virtualAccount : VirtualAccount?
    let isOrderComplaint: Bool
	var orderPages: String?
    var modifyAt: Int
    let reviewStatus: String?
    var productType: String?
    var productOriginalId: String?
    var resellerAccountId: String?
    var urlDonationPhoto: String?
    var productCategoryId: String?
    var productCategoryName: String?
    var commission, modal: Double?
    var donationTitle: String?
    var urlInitiatorPhoto: String?
    var receiverName: String?
    var sellerUserName: String?
}

struct VirtualAccount : Codable {
	
	let bank : String?
	let vaNumber : String?
	
	enum CodingKeys: String, CodingKey {
		case bank = "bank"
		case vaNumber = "va_number"
	}
	
}
