//
//  BalanceResult.swift
//  KipasKipas
//
//  Created by Muhammad Noor on 01/03/21.
//  Copyright © 2021 Koanba. All rights reserved.
//

import Foundation

struct BalanceResult : Codable {
	
	let code : String?
	let data : BalanceData?
	let message : String?
	
	enum CodingKeys: String, CodingKey {
		case code = "code"
		case data = "data"
		case message = "message"
	}
}

struct BalanceData : Codable {
	
	let history : [Balance]?
	let totalCredit : Int?
	let totalDebit : Int?
	
	enum CodingKeys: String, CodingKey {
		case history = "history"
		case totalCredit = "totalCredit"
		case totalDebit = "totalDebit"
	}
}

struct Balance : Codable {
	
	let accountDto : Profile?
	let activityType : String?
	let balanceAfter : Int?
	let balanceBefore : Int?
	let bankAccountName : String?
	let bankAccountNumber : String?
	let bankFee : Int?
	let bankId : String?
	let bankName : String?
	let createAt : Int?
	let historyType : String?
	let id : String?
	let noInvoice : String?
	let nominal : Int?
	let orderId : String?
	let status : String?
	let transactionId : String?
	
	enum CodingKeys: String, CodingKey {
		case accountDto = "accountDto"
		case activityType = "activityType"
		case balanceAfter = "balanceAfter"
		case balanceBefore = "balanceBefore"
		case bankAccountName = "bankAccountName"
		case bankAccountNumber = "bankAccountNumber"
		case bankFee = "bankFee"
		case bankId = "bankId"
		case bankName = "bankName"
		case createAt = "createAt"
		case historyType = "historyType"
		case id = "id"
		case noInvoice = "noInvoice"
		case nominal = "nominal"
		case orderId = "orderId"
		case status = "status"
		case transactionId = "transactionId"
	}
}
