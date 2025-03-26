//
//  DonationResult.swift
//  Persada
//
//  Created by Muhammad Noor on 30/04/20.
//  Copyright © 2020 Muhammad Noor. All rights reserved.
//

import Foundation


// MARK: - DonationArray
struct DonationResult: Codable {
	let code, message: String?
	let data: DonationData?
	
	enum CodingKeys: String, CodingKey {
		case code = "code"
		case data = "data"
		case message = "message"
	}
}

struct DonationDetailResult: Codable {
	let code, message: String?
	let data: Donation?
	
	enum CodingKeys: String, CodingKey {
		case code = "code"
		case data = "data"
		case message = "message"
	}
}

// MARK: - DonationData
struct DonationData: Codable {
	let content: [Donation]?
	let pageable: Pageable?
	let totalPages, totalElements: Int?
	let last: Bool?
	let sort: Sort?
	let numberOfElements: Int?
	let first: Bool?
	let size, number: Int?
	let empty: Bool?
	
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

// MARK: - Donation

struct Donation: Codable {
	
	let account : Profile?
	let comments : Int?
	let createAt : Int?
	let id : String?
	let isFollow : Bool?
	let isLike : Bool?
	let likes : Int?
	let post : PostDonation?
	let typePost : String?
	
	enum CodingKeys: String, CodingKey {
		case account = "account"
		case comments = "comments"
		case createAt = "createAt"
		case id = "id"
		case isFollow = "isFollow"
		case isLike = "isLike"
		case likes = "likes"
		case post = "post"
		case typePost = "typePost"
	}
	
}

// MARK: - PostDonation

struct PostDonation : Codable {
	
	let amountCollected : Int?
	let createAt : Int?
	let descriptionField : String?
	let expiredAt : Int?
	let id : String?
	let medias : [Medias]?
	let organizer : Organizer?
	let recipientName : String?
	let status : String?
	let targetAmount : Int?
	let title : String?
	let type : String?
	let verifier : VerifierPerson?
	
	enum CodingKeys: String, CodingKey {
		case amountCollected = "amountCollected"
		case createAt = "createAt"
		case descriptionField = "description"
		case expiredAt = "expiredAt"
		case id = "id"
		case medias = "medias"
		case organizer = "organizer"
		case recipientName = "recipientName"
		case status = "status"
		case targetAmount = "targetAmount"
		case title = "title"
		case type = "type"
		case verifier = "verifier"
	}
	
}

struct VerifierPerson : Codable {
	
	let accountType : String?
	let bio : String?
	let email : String?
	let gender : String?
	let id : String?
	let isVerified : Bool?
	let mobile : String?
	let name : String?
	let photo : String?
	let username : String?
	
	enum CodingKeys: String, CodingKey {
		case accountType = "accountType"
		case bio = "bio"
		case email = "email"
		case gender = "gender"
		case id = "id"
		case isVerified = "isVerified"
		case mobile = "mobile"
		case name = "name"
		case photo = "photo"
		case username = "username"
	}
	
}

struct Organizer : Codable {
	
	let accountType : String?
	let bio : String?
	let email : String?
	let gender : String?
	let id : String?
	let isVerified : Bool?
	let mobile : String?
	let name : String?
	let photo : String?
	let username : String?
	
	enum CodingKeys: String, CodingKey {
		case accountType = "accountType"
		case bio = "bio"
		case email = "email"
		case gender = "gender"
		case id = "id"
		case isVerified = "isVerified"
		case mobile = "mobile"
		case name = "name"
		case photo = "photo"
		case username = "username"
	}
	
}
