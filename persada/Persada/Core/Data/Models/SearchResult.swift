//
//  SearchResult.swift
//  KipasKipas
//
//  Created by movan on 03/08/20.
//  Copyright © 2020 Muhammad Noor. All rights reserved.
//

import Foundation

struct SearchArray: Codable {
	
	let code, message: String?
	let data: [SearchAccount]?
	
	enum CodingKeys: String, CodingKey {
		case code = "code"
		case data = "data"
		case message = "message"
	}
}

struct SearchAccount: Codable {
	
	let email : String?
	let id : String?
	let isSeleb : Bool?
	let isVerified : Bool?
	let mobile : String?
	let name : String?
	let photo : String?
	let username : String?
	
	enum CodingKeys: String, CodingKey {
		case email = "email"
		case id = "id"
		case isSeleb = "isSeleb"
		case isVerified = "isVerified"
		case mobile = "mobile"
		case name = "name"
		case photo = "photo"
		case username = "username"
	}
}

extension SearchAccount {
    func convertFollower() -> Follower {
        return Follower(
            bio: nil, 
            birthDate: nil,
            email: self.email,
            id: self.id,
            isFollow: nil,
            isSeleb: self.isSeleb,
            isVerified: self.isVerified,
            mobile: self.mobile,
            name: self.name,
            note: nil,
            photo: self.photo,
            username: self.username,
            isSelected: false
        )
    }
}

