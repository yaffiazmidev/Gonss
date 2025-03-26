//
//  SaldoEndpoint.swift
//  KipasKipas
//
//  Created by Muhammad Noor on 23/02/21.
//  Copyright © 2021 Koanba. All rights reserved.
//

import Foundation

enum SaldoEndpoint {
	case getSaldo
}

extension SaldoEndpoint: EndpointType {
	
	var baseUrl: URL {
		return URL(string: APIConstants.baseURL)!
	}
	
	var path: String {
		switch self {
		case .getSaldo:
			return "/balance/info"
		}
	}
	
	var method: HTTPMethod {
		return .get
	}
	
	var header: [String : Any] {
		switch  self {
		case .getSaldo:
			return [
				"Authorization" : "Bearer \(getToken() ?? "")",
				"Content-Type": "application/json"
			]
		default:
			break
		}
	}
	
	var parameter: [String : Any] {
		return [:]
	}
}
