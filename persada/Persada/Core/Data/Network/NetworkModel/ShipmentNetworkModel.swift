//
//  ShipmentNetworkModel.swift
//  Persada
//
//  Created by movan on 23/07/20.
//  Copyright © 2020 Muhammad Noor. All rights reserved.
//

import Foundation
import Combine

class ShipmentNetworkModel: NetworkModel {
	
	func requestCouriers(_ request: ShipmentEndpoint, _ source: ParameterCourier) -> AnyPublisher<CourierArray, Error> {
		
		var urlRequest = URLRequest(url: request.baseUrl.appendingPathComponent(request.path))
		
		do {
			let jsonBody = try JSONEncoder().encode(source)
			urlRequest.httpBody = jsonBody
		}catch{
			print("some error")
		}
		
		urlRequest.allHTTPHeaderFields = request.header as? [String: String]
		urlRequest.httpMethod = request.method.rawValue
		
		let encodeURLRequest = urlRequest.encode(with: request.parameter)
		
		return fetchURL(encodeURLRequest)
	}
	
	func requestTracking(_ request: ShipmentEndpoint) -> AnyPublisher<TrackingShipmentResult, Error>{
		
		var urlRequest = URLRequest(url: request.baseUrl.appendingPathComponent(request.path))
		urlRequest.allHTTPHeaderFields = request.header as? [String: String]
		urlRequest.httpMethod = request.method.rawValue
		
		let encodeURLRequest = urlRequest.encode(with: request.parameter)
		
		return fetchURL(encodeURLRequest)
	}
	
	func requestPickUp(_ request: ShipmentEndpoint) -> AnyPublisher<RequestPickUpResponse ,Error> {

		var urlRequest = URLRequest(url: request.baseUrl.appendingPathComponent(request.path))
		urlRequest.allHTTPHeaderFields = request.header as? [String: String]
		urlRequest.httpMethod = request.method.rawValue
		
		let encodeURLRequest = urlRequest.encode(with: request.parameter)
		
		return fetchURL(encodeURLRequest)

	}
}
