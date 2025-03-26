//
//  PostDetailResult.swift
//  KipasKipas
//
//  Created by movan on 08/09/20.
//  Copyright © 2020 Muhammad Noor. All rights reserved.
//

import Foundation

struct PostDetailResult : Codable {
	
	let code : String?
	let data : Feed?
	let message : String?
	
	enum CodingKeys: String, CodingKey {
		case code = "code"
		case data = "data"
		case message = "message"
	}
	
}
