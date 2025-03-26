//
//  HashtagResult.swift
//  KipasKipas
//
//  Created by movan on 04/08/20.
//  Copyright © 2020 Muhammad Noor. All rights reserved.
//

import Foundation

struct HashtagResult : Codable {
	
	let code : String?
	let data : [Hashtag]?
	let message : String?
    
    init(code: String, data: [Hashtag]?, message: String?) {
        self.code = code
        self.data = data
        self.message = message
    }
	
	enum CodingKeys: String, CodingKey {
		case code = "code"
		case data = "data"
		case message = "message"
	}
	
	init(from decoder: Decoder) throws {
		let values = try decoder.container(keyedBy: CodingKeys.self)
		code = try values.decodeIfPresent(String.self, forKey: .code)
		data = try values.decodeIfPresent([Hashtag].self, forKey: .data)
		message = try values.decodeIfPresent(String.self, forKey: .message)
	}
	
}


struct Hashtag : Codable {
	
	let name : String?
	let totalResult : Int?
	
	enum CodingKeys: String, CodingKey {
		case name = "name"
		case totalResult = "totalResult"
	}
	
	init(from decoder: Decoder) throws {
		let values = try decoder.container(keyedBy: CodingKeys.self)
		name = try values.decodeIfPresent(String.self, forKey: .name)
		totalResult = try values.decodeIfPresent(Int.self, forKey: .totalResult)
	}
	
}
