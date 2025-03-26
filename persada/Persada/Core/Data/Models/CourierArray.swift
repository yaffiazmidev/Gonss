//
//  CourierArray.swift
//  Persada
//
//  Created by movan on 23/07/20.
//  Copyright © 2020 Muhammad Noor. All rights reserved.
//

import Foundation


struct CourierArray: Codable {
		let code, message: String?
		let data: CourierDataClass?
}

// MARK: - CourierDataClass
struct CourierDataClass: Codable {
	let origin, destination: String?
	let courier: [Courier]?
}

struct Courier : Codable {
	
	let name : String?
	let prices : [CourierPrice]?
	
	enum CodingKeys: String, CodingKey {
		case name = "name"
		case prices = "prices"
	}
}

struct CourierPrice : Codable {
	
	let duration : String?
	let price : Int?
	let service : String?
	
	enum CodingKeys: String, CodingKey {
		case duration = "duration"
		case price = "price"
		case service = "service"
	}
}

struct SelectCourierResult: Codable {
    let code: String?
    let message: String?
    let data: [CourierResult]?
}

struct CourierResult: Codable {
    let id: String?
    let logisticName: String?
    let logisticId: String?
    var status: Bool?
}
