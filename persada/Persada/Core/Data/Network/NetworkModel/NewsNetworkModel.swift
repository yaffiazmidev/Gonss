//
//  NewsNetworkModel.swift
//  KipasKipas
//
//  Created by movan on 24/11/20.
//  Copyright © 2020 Muhammad Noor. All rights reserved.
//

import Foundation
import Combine

class NewsNetworkModel: NetworkModel {

	func fetchCategory(request: NewsEndpoint) -> AnyPublisher<NewsCategoryResult, Error> {
		
		var urlRequest = URLRequest(url: request.baseUrl.appendingPathComponent(request.path))
        urlRequest.allHTTPHeaderFields = request.header as? [String : String]
		urlRequest.httpMethod = request.method.rawValue
		
		let encodeRequestURL = urlRequest.encode(with: request.parameter)
		
		return fetchURL(encodeRequestURL)
	}
	
	func requestSearchNews(request: NewsEndpoint) -> AnyPublisher<NewsArray, Error>{
		var urlRequest = URLRequest(url: request.baseUrl.appendingPathComponent(request.path))
		urlRequest.allHTTPHeaderFields = request.header as? [String : String]
		urlRequest.httpMethod = request.method.rawValue
		
		let encodeRequestURL = urlRequest.encode(with: request.parameter)
		
		return fetchURL(encodeRequestURL)
	}
	
	func fetchNews(request: NewsEndpoint) -> AnyPublisher<NewsArray, Error> {
		var urlRequest = URLRequest(url: request.baseUrl.appendingPathComponent(request.path))
        urlRequest.allHTTPHeaderFields = request.header as? [String : String]
		urlRequest.httpMethod = request.method.rawValue
		
		let encodeRequestURL = urlRequest.encode(with: request.parameter)
        print("---DEBUG: \(request.path), \(request.parameter)")
		return fetchURL(encodeRequestURL)
	}
}
