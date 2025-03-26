//
//  EncodableExt.swift
//  KipasKipas
//
//  Created by Azam Mukhtar on 12/03/21.
//  Copyright © 2021 Koanba. All rights reserved.
//

import Foundation


extension Encodable {
	func asDictionary() throws -> Dictionary<String, Any> {
		let data = try JSONEncoder().encode(self)
		guard let dictionary = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? Dictionary<String, Any> else {
			throw NSError()
		}
		return dictionary
	}
	func jsonData() throws -> Data {
		let encoder = JSONEncoder()
		encoder.outputFormatting = .prettyPrinted
		encoder.dateEncodingStrategy = .iso8601
		return try encoder.encode(self)
	}
}
