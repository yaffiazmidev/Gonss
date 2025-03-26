//
//  ProductNetworkModel.swift
//  KipasKipas
//
//  Created by movan on 06/08/20.
//  Copyright © 2020 Muhammad Noor. All rights reserved.
//

import Combine
import Foundation

class ProductNetworkModel: NetworkModel {
	
	func fetchProduct(_ request: ProductEndpoint) -> AnyPublisher<ProductResult, Error> {
		
		var urlRequest = URLRequest(url: request.baseUrl.appendingPathComponent(request.path))
		urlRequest.allHTTPHeaderFields = request.header as? [String: String]
		urlRequest.httpMethod = request.method.rawValue
		
		let encodeURLRequest = urlRequest.encode(with: request.parameter)
		
		return fetchURL(encodeURLRequest)
	}

	func fetchDeliveryAddress(_ request: ProductEndpoint) -> AnyPublisher<DeliveryAddress, Error> {

		var urlRequest = URLRequest(url: request.baseUrl.appendingPathComponent(request.path))
		urlRequest.allHTTPHeaderFields = request.header as? [String: String]
		urlRequest.httpMethod = request.method.rawValue

		let encodeURLRequest = urlRequest.encode(with: request.parameter)

		return fetchURL(encodeURLRequest)
	}

	func searchMyProducts(_ request: ProductEndpoint) -> AnyPublisher<ProductResult, Error> {
		var urlRequest = URLRequest(url: request.baseUrl.appendingPathComponent(request.path))
		urlRequest.allHTTPHeaderFields = request.header as? [String: String]
		urlRequest.httpMethod = request.method.rawValue

		let encodeURLRequest = urlRequest.encode(with: request.parameter)

		return fetchURL(encodeURLRequest)
	}
    
    func getProductByID(_ request: ProductEndpoint) -> AnyPublisher<ProductDetailResult, Error> {
           var urlRequest = URLRequest(url: request.baseUrl.appendingPathComponent(request.path))
           urlRequest.allHTTPHeaderFields = request.header as? [String: String]
           urlRequest.httpMethod = request.method.rawValue
           
           let encodeURLRequest = urlRequest.encode(with: request.parameter)
           
           return fetchURL(encodeURLRequest)
       }
}
