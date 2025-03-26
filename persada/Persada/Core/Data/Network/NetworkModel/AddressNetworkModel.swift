//
//  AddressNetworkModel.swift
//  KipasKipas
//
//  Created by movan on 11/08/20.
//  Copyright © 2020 Muhammad Noor. All rights reserved.
//

import Foundation
import Combine

class AddressNetworkModel: NetworkModel {
	
	func fetchAddress(_ request: AddressEndpoint) -> AnyPublisher<AddressResult, Error> {

		var urlRequest = URLRequest(url: request.baseUrl.appendingPathComponent(request.path))
		urlRequest.allHTTPHeaderFields = request.parameter as? [String: String]
		urlRequest.httpMethod = request.method.rawValue
        urlRequest.allHTTPHeaderFields = request.header
		
		let encodeRequestURL = urlRequest.encode(with: request.parameter)
		
		return fetchURL(encodeRequestURL)
	}

	func fetchAddressSingle(_ request: AddressEndpoint) -> AnyPublisher<SingleAddressResult, Error> {

		var urlRequest = URLRequest(url: request.baseUrl.appendingPathComponent(request.path))
		urlRequest.allHTTPHeaderFields = request.parameter as? [String: String]
		urlRequest.httpMethod = request.method.rawValue

		let encodeRequestURL = urlRequest.encode(with: request.parameter)

		return fetchURL(encodeRequestURL)
	}
	
	func fetchProvince(_ request: AddressEndpoint) -> AnyPublisher<AreaResult, Error> {

		var urlRequest = URLRequest(url: request.baseUrl.appendingPathComponent(request.path))
		urlRequest.allHTTPHeaderFields = request.parameter as? [String: String]
		urlRequest.httpMethod = request.method.rawValue
		
		let encodeRequestURL = urlRequest.encode(with: request.parameter)
		
		return fetchURL(encodeRequestURL)
	}
	
	func fetchCity(_ request: AddressEndpoint) -> AnyPublisher<AreaResult, Error> {

		var urlRequest = URLRequest(url: request.baseUrl.appendingPathComponent(request.path))
		urlRequest.allHTTPHeaderFields = request.parameter as? [String: String]
		urlRequest.httpMethod = request.method.rawValue
		
		let encodeRequestURL = urlRequest.encode(with: request.parameter)
		
		return fetchURL(encodeRequestURL)
	}
	
	func fetchSubdistrict(_ request: AddressEndpoint) -> AnyPublisher<AreaResult, Error> {

		var urlRequest = URLRequest(url: request.baseUrl.appendingPathComponent(request.path))
		urlRequest.allHTTPHeaderFields = request.parameter as? [String: String]
		urlRequest.httpMethod = request.method.rawValue
		
		let encodeRequestURL = urlRequest.encode(with: request.parameter)
		
		return fetchURL(encodeRequestURL)
	}
	
	func removeAddress(_ request: AddressEndpoint) -> AnyPublisher<RemoveResponse, Error> {

		var urlRequest = URLRequest(url: request.baseUrl.appendingPathComponent(request.path))
		urlRequest.allHTTPHeaderFields = request.parameter as? [String: String]
		urlRequest.httpMethod = request.method.rawValue
		
		let encodeRequestURL = urlRequest.encode(with: request.parameter)
		
		return fetchURL(encodeRequestURL)
	}
	
	func addAddress(_ request: AddressEndpoint, _ source: Address) -> AnyPublisher<DefaultResponse, Error> {

		var urlRequest = URLRequest(url: request.baseUrl.appendingPathComponent(request.path))
		
		do {
			let jsonBody = try JSONEncoder().encode(source)
			urlRequest.httpBody = jsonBody
		}catch{
			print("some error")
		}
		
		urlRequest.allHTTPHeaderFields = request.parameter as? [String: String]
		urlRequest.httpMethod = request.method.rawValue
		
		let encodeRequestURL = urlRequest.encode(with: request.parameter)
		
		return fetchURL(encodeRequestURL)
	}
	
	func editAddress(_ request: AddressEndpoint, _ source: Address) -> AnyPublisher<DefaultResponse, Error> {

		var urlRequest = URLRequest(url: request.baseUrl.appendingPathComponent(request.path))
		
		do {
			let jsonBody = try JSONEncoder().encode(source)
			urlRequest.httpBody = jsonBody
		}catch{
			print("some error")
		}
		
		urlRequest.allHTTPHeaderFields = request.parameter as? [String: String]
		urlRequest.httpMethod = request.method.rawValue
		
		let encodeRequestURL = urlRequest.encode(with: request.parameter)
		
		return fetchURL(encodeRequestURL)
	}
}
