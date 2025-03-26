//
//  DeclineOrderResult.swift
//  KipasKipas
//
//  Created by Muhammad Noor on 03/02/21.
//  Copyright © 2021 Koanba. All rights reserved.
//

import Foundation

struct DeclineOrderResult: Codable {
	let code: String
	let message: String
	let data: [DeclineOrder]?
}

struct DeclineOrder: Codable {
	let id, type: String
	var value: String
}
