//
//  TrackingShipmentResult.swift
//  KipasKipas
//
//  Created by movan on 18/08/20.
//  Copyright © 2020 Muhammad Noor. All rights reserved.
//

import Foundation

struct TrackingShipmentResult: Codable {
	
	let code, message: String?
	let data: [TrackingShipment]?
	
	enum CodingKeys: String, CodingKey {
		case code = "code"
		case data = "data"
		case message = "message"
	}
}

struct TrackingShipment: Codable {
	let awbNumber: String?
	let historyTracking: [HistoryTracking]?
	
	enum CodingKeys: String, CodingKey {
		case awbNumber
		case historyTracking = "history"
	}
}

struct HistoryTracking: Codable {
	let notes: String?
	let shipmentDate: Int?
}
