//
//  CourierEndpoint.swift
//  KipasKipas
//
//  Created by Azam Mukhtar on 18/06/21.
//  Copyright © 2021 Koanba. All rights reserved.
//

import Foundation

enum CourierEndpoint {
	case getCourier
	case editCourier(id: String, isActive: Bool)
}

extension CourierEndpoint : EndpointType {
	var baseUrl: URL {
			return URL(string: APIConstants.baseURL)!
	}
	
	var path: String {
			switch self {
			case .getCourier:
					return "/shop/logistic/list"
			case .editCourier(let id, _):
					return "/shop/\(id)"
			}
	}
	
	var method: HTTPMethod {
			switch self {
			case .editCourier(_, _):
					return .put
			default:
					return .get
			}
	}
	
	var header: [String : String] {
			return [
					"Authorization" : "Bearer \(getToken() ?? "")",
					"Content-Type" : "application/json",
			]
	}
	
	
	var parameter: [String : Any] {
			switch self {
			case .editCourier(let id, let isActive):
					return [
						"id":id,
						"isActive": isActive
					]
			case .getCourier:
					return [:]
			}
	}
}
