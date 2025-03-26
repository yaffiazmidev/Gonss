//
//  PaymentNetworkModel.swift
//  Persada
//
//  Created by movan on 27/07/20.
//  Copyright © 2020 Muhammad Noor. All rights reserved.
//

import Foundation
import Combine

class PaymentNetworkModel: NetworkModel {
	
	func donate(_ request: TransactionEndpoint, _ source: ParameterDonation) -> AnyPublisher<PaymentResponse, Error> {
		
		var urlRequest = URLRequest(url: request.baseUrl.appendingPathComponent(request.path))
		
		do {
			let jsonBody = try JSONEncoder().encode(source)
			urlRequest.httpBody = jsonBody
		} catch {
			print("some error")
		}
		
		urlRequest.allHTTPHeaderFields = request.parameter as? [String: String]
		urlRequest.httpMethod = request.method.rawValue
		
		let encodeURLRequest = urlRequest.encode(with: request.parameter)
		
		return fetchURL(encodeURLRequest)
	}
}
