//
//  ChannelNetworkModel.swift
//  Persada
//
//  Created by Muhammad Noor on 08/04/20.
//  Copyright © 2020 Muhammad Noor. All rights reserved.
//

import Foundation
import Combine

class ChannelNetworkModel: NetworkModel {
	
	func fetchChannel(_ request: ChannelEndpoint, _ completion: @escaping (ResultData<ChannelsAccount>) -> Void)  {
		
		var urlRequest = URLRequest(url: request.baseUrl.appendingPathComponent(request.path))
		urlRequest.allHTTPHeaderFields = request.header
		urlRequest.httpMethod = request.method.rawValue
		
		let encoderUrlRequest = urlRequest.encode(with: request.parameter)
		
		requestData(encoderUrlRequest, completion)
	}
    
    func fetchChannelById(_ request: ChannelEndpoint) -> AnyPublisher<ChannelDetail, Error>{
        
        var urlRequest = URLRequest(url: request.baseUrl.appendingPathComponent(request.path))
        urlRequest.allHTTPHeaderFields = request.header
        urlRequest.httpMethod = request.method.rawValue
        
        let encoderUrlRequest = urlRequest.encode(with: request.parameter)
        
        return fetchURL(encoderUrlRequest)
    }
	
	func fetchChannels(_ request: ChannelEndpoint, _ completion: @escaping (ResultData<ChannelResult>) -> Void)  {
		
		var urlRequest = URLRequest(url: request.baseUrl.appendingPathComponent(request.path))
		urlRequest.allHTTPHeaderFields = request.header
		urlRequest.httpMethod = request.method.rawValue
		
		let encoderUrlRequest = urlRequest.encode(with: request.parameter)
		
		requestData(encoderUrlRequest, completion)
	}
	
	func fetchChannels(_ request: ChannelEndpoint) -> AnyPublisher<ChannelResult, Error>{
		
		var urlRequest = URLRequest(url: request.baseUrl.appendingPathComponent(request.path))
		urlRequest.allHTTPHeaderFields = request.header
		urlRequest.httpMethod = request.method.rawValue
		
		let encoderUrlRequest = urlRequest.encode(with: request.parameter)
		
		return fetchURL(encoderUrlRequest)
	}
	
	func fetchChannelDetail(_ request: ChannelEndpoint, _ completion: @escaping (ResultData<ChannelContentArray>) -> Void) {
		
		var urlRequest = URLRequest(url: request.baseUrl.appendingPathComponent(request.path))
		urlRequest.allHTTPHeaderFields = request.header
		urlRequest.httpMethod = request.method.rawValue
		
		let encoderUrlRequest = urlRequest.encode(with: request.parameter)
		
		requestData(encoderUrlRequest, completion)
	}
	
	func searchChannel(_ request: ChannelEndpoint, _ completion: @escaping (ResultData<FeedArray>) -> Void) {
		
		var urlRequest = URLRequest(url: request.baseUrl.appendingPathComponent(request.path))
		urlRequest.allHTTPHeaderFields = request.header
		urlRequest.httpMethod = request.method.rawValue
		
		let encoderUrlRequest = urlRequest.encode(with: request.parameter)
		
		requestData(encoderUrlRequest, completion)
	}
	
	
	func fetchYourChannel(_ request: ChannelEndpoint) -> AnyPublisher<ChannelResult, Error> {
		
		var urlRequest = URLRequest(url: request.baseUrl.appendingPathComponent(request.path))
		urlRequest.allHTTPHeaderFields = request.header
		urlRequest.httpMethod = request.method.rawValue
		
		let encodeURLRequest = urlRequest.encode(with: request.parameter)
		
		return fetchURL(encodeURLRequest)
	}
	
	func fetchAllYourChannel(_ request: ChannelEndpoint) -> AnyPublisher<ChannelResult, Error> {
		
		var urlRequest = URLRequest(url: request.baseUrl.appendingPathComponent(request.path))
		urlRequest.allHTTPHeaderFields = request.header
		urlRequest.httpMethod = request.method.rawValue
		
		let encodeURLRequest = urlRequest.encode(with: request.parameter)
		
		return fetchURL(encodeURLRequest)
	}
	
	func fetchSuggestionChannel(_ request: ChannelEndpoint) -> AnyPublisher<SuggestionChannelResult, Error> {
		
		var urlRequest = URLRequest(url: request.baseUrl.appendingPathComponent(request.path))
		urlRequest.allHTTPHeaderFields = request.header
		urlRequest.httpMethod = request.method.rawValue
		
		let encodeURLRequest = urlRequest.encode(with: request.parameter)
		
		return fetchURL(encodeURLRequest)
	}
	
	func fetchExploreChannel(_ request: ChannelEndpoint) -> AnyPublisher<FeedArray, Error> {
		
		var urlRequest = URLRequest(url: request.baseUrl.appendingPathComponent(request.path))
		urlRequest.allHTTPHeaderFields = request.header
		urlRequest.httpMethod = request.method.rawValue
		
		let encodeURLRequest = urlRequest.encode(with: request.parameter)
		
		return fetchURL(encodeURLRequest)
	}
	
	func fetchPublicExploreChannel(_ request: ChannelEndpoint) -> AnyPublisher<FeedArray, Error> {
		
		var urlRequest = URLRequest(url: request.baseUrl.appendingPathComponent(request.path))
		urlRequest.httpMethod = request.method.rawValue
		
		let encodeURLRequest = urlRequest.encode(with: request.parameter)
		
		return fetchURL(encodeURLRequest)
	}
	
	func fetchPublicSuggestionChannel(_ request: ChannelEndpoint) -> AnyPublisher<SuggestionChannelResult, Error> {
		
		var urlRequest = URLRequest(url: request.baseUrl.appendingPathComponent(request.path))
		urlRequest.httpMethod = request.method.rawValue
		
		let encodeURLRequest = urlRequest.encode(with: request.parameter)
		
		return fetchURL(encodeURLRequest)
	}
	
	func fetchPublicAllSuggestionChannel(_ request: ChannelEndpoint) -> AnyPublisher<FeedArray, Error> {
		
		var urlRequest = URLRequest(url: request.baseUrl.appendingPathComponent(request.path))
		urlRequest.httpMethod = request.method.rawValue
		
		let encodeURLRequest = urlRequest.encode(with: request.parameter)
		
		return fetchURL(encodeURLRequest)
	}
	
	func fetchAllSuggestionChannel(_ request: ChannelEndpoint) -> AnyPublisher<FeedArray, Error> {
		
		var urlRequest = URLRequest(url: request.baseUrl.appendingPathComponent(request.path))
		urlRequest.allHTTPHeaderFields = request.header
		urlRequest.httpMethod = request.method.rawValue
		
		let encodeURLRequest = urlRequest.encode(with: request.parameter)
		
		return fetchURL(encodeURLRequest)
	}
	
	func searchChannel(_ request: ChannelEndpoint) -> AnyPublisher<SearchArray, Error> {
		
		var urlRequest = URLRequest(url: request.baseUrl.appendingPathComponent(request.path))
		urlRequest.allHTTPHeaderFields = request.header
		urlRequest.httpMethod = request.method.rawValue

		let encodeURLRequest = urlRequest.encode(with: request.parameter)

		return fetchURL(encodeURLRequest)
	}
	
	func searchTopChannel(_ request: ChannelEndpoint) -> AnyPublisher<FeedArray, Error> {
		
		var urlRequest = URLRequest(url: request.baseUrl.appendingPathComponent(request.path))
		urlRequest.allHTTPHeaderFields = request.header
		urlRequest.httpMethod = request.method.rawValue

		let encodeURLRequest = urlRequest.encode(with: request.parameter)

		return fetchURL(encodeURLRequest)
	}
	
	func searchHashtagChannel(_ request: ChannelEndpoint) -> AnyPublisher<HashtagResult, Error> {
		
		var urlRequest = URLRequest(url: request.baseUrl.appendingPathComponent(request.path))
		urlRequest.allHTTPHeaderFields = request.header
		urlRequest.httpMethod = request.method.rawValue

		let encodeURLRequest = urlRequest.encode(with: request.parameter)

		return fetchURL(encodeURLRequest)
	}
	
	func searchContentChannel(_ request: ChannelEndpoint) -> AnyPublisher<ChannelsAccount, Error> {
		
		var urlRequest = URLRequest(url: request.baseUrl.appendingPathComponent(request.path))
		urlRequest.allHTTPHeaderFields = request.header
		urlRequest.httpMethod = request.method.rawValue

		let encodeURLRequest = urlRequest.encode(with: request.parameter)

		return fetchURL(encodeURLRequest)
	}
	
	func requestFollowChannel(_ request: ChannelEndpoint) -> AnyPublisher<DefaultResponse, Error> {
		
		var urlRequest = URLRequest(url: request.baseUrl.appendingPathComponent(request.path))
		urlRequest.allHTTPHeaderFields = request.header
		urlRequest.httpMethod = request.method.rawValue

		let encodeURLRequest = urlRequest.encode(with: request.parameter)

		return fetchURL(encodeURLRequest)
	}

	func requestChannelGeneralPost(_ request: ChannelEndpoint, _ completion: @escaping (ResultData<FeedArray>) -> Void) {
		var urlRequest = URLRequest(url: request.baseUrl.appendingPathComponent(request.path))
		urlRequest.allHTTPHeaderFields = request.header
		urlRequest.httpMethod = request.method.rawValue

		let encoderUrlRequest = urlRequest.encode(with: request.parameter)

		requestData(encoderUrlRequest, completion)
	}

	func requestChannelFeedById(_ request: ChannelEndpoint, _ completion: @escaping (ResultData<FeedArray>) -> Void) {
		var urlRequest = URLRequest(url: request.baseUrl.appendingPathComponent(request.path))
		urlRequest.allHTTPHeaderFields = request.header
		urlRequest.httpMethod = request.method.rawValue

		let encoderUrlRequest = urlRequest.encode(with: request.parameter)

		requestData(encoderUrlRequest, completion)
	}
	
	func followChannels(_ request: ChannelEndpoint) -> AnyPublisher<DefaultResponse, Error> {
		
		var urlRequest = URLRequest(url: request.baseUrl.appendingPathComponent(request.path))
		urlRequest.allHTTPHeaderFields = request.header
		urlRequest.httpMethod = request.method.rawValue
		
		let encodeRequestUrl = urlRequest.encode(with: request.parameter)
		
		return fetchURL(encodeRequestUrl)
	}
	
	func unfollowChannels(_ request: ChannelEndpoint) -> AnyPublisher<DefaultResponse, Error> {
		
		var urlRequest = URLRequest(url: request.baseUrl.appendingPathComponent(request.path))
		urlRequest.allHTTPHeaderFields = request.header
		urlRequest.httpMethod = request.method.rawValue
		
		let encodeRequestUrl = urlRequest.encode(with: request.parameter)
		
		return fetchURL(encodeRequestUrl)
	}
}
