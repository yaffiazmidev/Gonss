//
//  DefaultResponse.swift
//  Persada
//
//  Created by Muhammad Noor on 24/04/20.
//  Copyright © 2020 Muhammad Noor. All rights reserved.
//

import Foundation

// MARK: - DefaultResponse
struct DefaultResponse: Codable {
	let code, data, message: String?
}

struct DeleteResponse: Codable {
	let code, message: String?
	let data: Bool?
}

struct RequestPickUpResponse: Codable, Equatable {
		let code, message: String
		let data: RequestPickUpData?
}

// MARK: - RequestPickUpData
struct RequestPickUpData: Codable, Equatable {
		let status, info: String?
		let content: RequestPickUpContent?
}

struct DelayCheckoutResult: Codable, Equatable {
    var code, message: String?
    var data: DelayCheckout?
}

struct DelayCheckout: Codable, Equatable {
    var orderId: String?
    var orderExist: Bool?
}

// MARK: - RequestPickUpContent
struct RequestPickUpContent: Codable, Equatable {
		let expectStart, expectFinish: String?

		enum CodingKeys: String, CodingKey {
				case expectStart = "expect_start"
				case expectFinish = "expect_finish"
		}
}

// MARK: - TotalFollow
struct TotalFollow : Codable {
	
	let code : String?
	let data : Int?
	var id: String?
	let message : String?
	
	enum CodingKeys: String, CodingKey {
		case code = "code"
		case data = "data"
		case message = "message"
		case id = "id"
	}
	
}

struct RemoveResponse: Codable {
	let code, message: String?
	let data: Bool?
}

struct DefaultBool: Codable {
	let code, message: String?
	let data: Bool?
}

struct DefaultError: Codable {
	let code: String?
	let message: String?
}
