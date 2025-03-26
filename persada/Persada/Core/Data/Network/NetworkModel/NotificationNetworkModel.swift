//
//  NotificationNetworkModel.swift
//  KipasKipas
//
//  Created by movan on 13/08/20.
//  Copyright © 2020 Muhammad Noor. All rights reserved.
//

import Foundation
import Combine

class NotificationNetworkModel: NetworkModel {
	
	func fetchNotificationSocial(_ request: NotificationEndpoint) -> AnyPublisher<NotificationSocialResult, Error> {

		var urlRequest = URLRequest(url: request.baseUrl.appendingPathComponent(request.path))
		urlRequest.allHTTPHeaderFields = request.header as? [String: String]
		urlRequest.httpMethod = request.method.rawValue
		
		let encodeRequestURL = urlRequest.encode(with: request.parameter)
		
		return fetchURL(encodeRequestURL)
	}
	
	func fetchNotificationTransaction(_ request: NotificationEndpoint) -> AnyPublisher<NotificationTransactionResult, Error> {

		var urlRequest = URLRequest(url: request.baseUrl.appendingPathComponent(request.path))
		urlRequest.allHTTPHeaderFields = request.header as? [String: String]
		urlRequest.httpMethod = request.method.rawValue
		
		let encodeRequestURL = urlRequest.encode(with: request.parameter)
		
		return fetchURL(encodeRequestURL)
	}
	
	func detailNotificationTransaction(_ request: NotificationEndpoint) -> AnyPublisher<TransactionProductResult, Error> {

		var urlRequest = URLRequest(url: request.baseUrl.appendingPathComponent(request.path))
		urlRequest.allHTTPHeaderFields = request.header as? [String: String]
		urlRequest.httpMethod = request.method.rawValue
		
		let encodeRequestURL = urlRequest.encode(with: request.parameter)
		
		return fetchURL(encodeRequestURL)
	}
	
	func detailTransactionDonation(_ request: NotificationEndpoint) -> AnyPublisher<TransactionDonationResult, Error> {

		var urlRequest = URLRequest(url: request.baseUrl.appendingPathComponent(request.path))
		urlRequest.allHTTPHeaderFields = request.header as? [String: String]
		urlRequest.httpMethod = request.method.rawValue
		
		let encodeRequestURL = urlRequest.encode(with: request.parameter)
		
		return fetchURL(encodeRequestURL)
	}
}
