//
//  FollowerResult.swift
//  KipasKipas
//
//  Created by movan on 31/08/20.
//  Copyright © 2020 Muhammad Noor. All rights reserved.
//

import Foundation

struct FollowerResult : Codable {
	
	var code : String?
	var data : FollowerData?
	var message : String?
	
	enum CodingKeys: String, CodingKey {
		case code = "code"
		case data = "data"
		case message = "message"
	}
	
}

struct FollowerData : Codable {
	
	var content : [Follower]?
	var empty : Bool?
	var first : Bool?
	var last : Bool?
	var number : Int?
	var numberOfElements : Int?
	var pageable : Pageable?
	var size : Int?
	var sort : Sort?
	var totalElements : Int?
	var totalPages : Int?
	
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

struct Follower : Codable, Equatable {
	
	var bio : String?
	var birthDate : String?
	var email : String?
	var id : String?
	var isFollow : Bool?
	var isSeleb : Bool?
	var isVerified : Bool?
	var mobile : String?
	var name : String?
	var note : String?
	var photo : String?
	var username : String?
	var isSelected: Bool = false
	
	enum CodingKeys: String, CodingKey {
		
		case bio = "bio"
		case birthDate = "birthDate"
		case email = "email"
		case id = "id"
		case isFollow = "isFollow"
		case isSeleb = "isSeleb"
		case isVerified = "isVerified"
		case mobile = "mobile"
		case name = "name"
		case note = "note"
		case photo = "photo"
		case username = "username"
	}
	
    
    static func == (lhs: Follower, rhs: Follower) -> Bool {
        return lhs.id == rhs.id
    }
}
