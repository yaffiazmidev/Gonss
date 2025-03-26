//
//  ShipmentEndpoint.swift
//  Persada
//
//  Created by movan on 23/07/20.
//  Copyright © 2020 Muhammad Noor. All rights reserved.
//

import Foundation

enum ShipmentEndpoint {
	case jne
	case tracking(id: String)
	case shipmentCouriers
	case requestPickUp(serviceName: String, id: String)
}

extension ShipmentEndpoint: EndpointType {
	
	var baseUrl: URL {
		return URL(string: APIConstants.baseURL)!
	}
	
	var path: String {
		switch self {
		case .jne:
			return "/shipments/checkcostjne"
		case .tracking(_):
			return "/shipments/logistic/track/search"
		case .shipmentCouriers:
			return "/shipments/price"
		case let .requestPickUp(serviceName, id):
			return "/shipments/logistic/\(serviceName)/requestpickup/\(id)"
		}
	}
	
	var method: HTTPMethod {
		switch self {
		case .jne, .shipmentCouriers, .requestPickUp(_,_):
			return .post
		case .tracking(_):
			return .get
		}
	}
	
	var body: [String: Any] {
		return [:]
	}
	
	var header: [String : Any] {
		return [
			"Authorization" : "Bearer \(getToken() ?? "")",
			"Content-Type" : "application/json",
		]
	}
	
	var parameter: [String : Any] {
		switch self {
		case .tracking(let id):
			return [
				"orderId" : id
			]
		default:
			return [:]
		}
	}
	
}
