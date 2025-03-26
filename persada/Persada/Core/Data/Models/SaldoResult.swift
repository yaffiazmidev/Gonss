//
//  SaldoResult.swift
//  KipasKipas
//
//  Created by Muhammad Noor on 23/02/21.
//  Copyright © 2021 Koanba. All rights reserved.
//

import Foundation

struct SaldoResult: Codable {
	let code : String?
	let data : SaldoResponse?
	let message : String?
	
	enum CodingKeys: String, CodingKey {
		case code = "code"
		case data = "data"
		case message = "message"
	}
}

struct SaldoResponse : Codable {

		let accountId : String?
		let bankAccountDto : String?
		let gopayBalance : Int?
		let id : String?
		let isGopayActive : Bool?
		let refundBalance : Int?
		let totalBalance : Int?
		let transactionBalance : Int?
		let withdrawFee : Int?

		enum CodingKeys: String, CodingKey {
				case accountId = "accountId"
				case bankAccountDto = "bankAccountDto"
				case gopayBalance = "gopayBalance"
				case id = "id"
				case isGopayActive = "isGopayActive"
				case refundBalance = "refundBalance"
				case totalBalance = "totalBalance"
				case transactionBalance = "transactionBalance"
				case withdrawFee = "withdrawFee"
		}
}
