//
//  OrderNetworkModel.swift
//  KipasKipas
//
//  Created by NOOR on 21/01/21.
//  Copyright © 2021 Koanba. All rights reserved.
//

import Foundation
import Combine

class OrderNetworkModel: NetworkModel {
	
	func getOrderTransaction(_ request: TransactionEndpoint) -> AnyPublisher<StatusOrderResult, Error> {
		var urlRequest = URLRequest(url: request.baseUrl.appendingPathComponent(request.path))
		urlRequest.allHTTPHeaderFields = request.header as? [String: String]
		urlRequest.httpMethod = request.method.rawValue
		
		let encodeRequestURL = urlRequest.encode(with: request.parameter)
		
		return fetchURL(encodeRequestURL)
	}
	
	func processOrder(_ request: TransactionEndpoint) -> AnyPublisher<DefaultResponse, Error> {
		var urlRequest = URLRequest(url: request.baseUrl.appendingPathComponent(request.path))
		urlRequest.allHTTPHeaderFields = request.header as? [String: String]
		urlRequest.httpMethod = request.method.rawValue
		
		let encodeRequestURL = urlRequest.encode(with: request.parameter)
		
		return fetchURL(encodeRequestURL)
	}
	
	func postComplaint(_ request: TransactionEndpoint, _ source: ComplaintInput) -> AnyPublisher<DefaultResponse, Error> {
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
	
	func postCancelSalesOrder(_ request: TransactionEndpoint, _ source: CancelSalesOrderInput) -> AnyPublisher<DefaultResponse, Error> {
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
	
	func getReasonDeclineOrder(_ request: TransactionEndpoint) -> AnyPublisher<DeclineOrderResult, Error> {
		var urlRequest = URLRequest(url: request.baseUrl.appendingPathComponent(request.path))
		urlRequest.allHTTPHeaderFields = request.header as? [String: String]
		urlRequest.httpMethod = request.method.rawValue
		
		let encodeURLRequest = urlRequest.encode(with: request.parameter)
		
		return fetchURL(encodeURLRequest)
	}
	
	func requestOrderDetail(_ request: NotificationEndpoint) -> AnyPublisher<TransactionProductResult, Error> {
		
		var urlRequest = URLRequest(url: request.baseUrl.appendingPathComponent(request.path))
		urlRequest.allHTTPHeaderFields = request.header as? [String: String]
		urlRequest.httpMethod = request.method.rawValue
		
		let encodeRequestURL = urlRequest.encode(with: request.parameter)
		
		return fetchURL(encodeRequestURL)
	}

	func showBarcode(_ request: TransactionEndpoint) -> AnyPublisher<Data, Error> {
		
		var urlRequest = URLRequest(url: request.baseUrl.appendingPathComponent(request.path))
		urlRequest.allHTTPHeaderFields = request.header as? [String: String]
		urlRequest.httpMethod = request.method.rawValue
		
		let encodeRequestURL = urlRequest.encode(with: request.parameter)
		
		return fetchImage(encodeRequestURL)
	}
    
    func completeOrder(_ request: TransactionEndpoint) -> AnyPublisher<DefaultResponse, Error> {
        var urlRequest = URLRequest(url: request.baseUrl.appendingPathComponent(request.path))
        
        
        urlRequest.allHTTPHeaderFields = request.header as? [String: String]
        urlRequest.httpMethod = request.method.rawValue
        
        let encodeURLRequest = urlRequest.encode(with: request.parameter)
        
        return fetchURL(encodeURLRequest)
    }
}
