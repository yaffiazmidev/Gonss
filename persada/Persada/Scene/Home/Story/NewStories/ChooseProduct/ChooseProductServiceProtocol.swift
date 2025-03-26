//
//  ChooseProductServiceProtocol.swift
//  Persada
//
//  Created by movan on 20/07/20.
//  Copyright © 2020 Muhammad Noor. All rights reserved.
//

import Foundation
import Combine

enum ServiceError: Error {
	case url(URLError)
	case urlRequest
	case decode
}

protocol PlayersServiceProtocol {
	func get(_ request: ProductEndpoint) -> AnyPublisher<ProductResult, Error>
}

let apiKey: String = getToken() ?? ""

final class PlayersService: PlayersServiceProtocol {
	
	func get(_ request: ProductEndpoint) -> AnyPublisher<ProductResult, Error> {
		var dataTask: URLSessionDataTask?
		
		let onSubscription: (Subscription) -> Void = { _ in dataTask?.resume() }
		let onCancel: () -> Void = { dataTask?.cancel() }
		
		// promise type is Result<[Player], Error>
		return Future<ProductResult, Error> { [weak self] promise in
			guard let urlRequest = self?.getUrlRequest(request) else {
				promise(.failure(ServiceError.urlRequest))
				return
			}
			
			dataTask = URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
				guard let data = data else {
					if let error = error {
						promise(.failure(error))
					}
					return
				}

				do {
					let decodeData = try JSONDecoder().decode(ProductResult.self, from: data)
					promise(.success(decodeData))
				} catch {
					promise(.failure(ServiceError.decode))
				}
			}
		}
		.handleEvents(receiveSubscription: onSubscription, receiveCancel: onCancel)
		.receive(on: DispatchQueue.main)
		.eraseToAnyPublisher()
	}
	
	private func getUrlRequest(_ request: ProductEndpoint) -> URLRequest? {
		
		var urlRequest = URLRequest(url: request.baseUrl.appendingPathComponent(request.path))
		urlRequest.allHTTPHeaderFields = request.header as? [String: String]
		urlRequest.httpMethod = request.method.rawValue

		let encodeURLRequest = urlRequest.encode(with: request.parameter)

		return encodeURLRequest
	}
}
