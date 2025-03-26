//
//  FeedNetworkModel.swift
//  Persada
//
//  Created by Muhammad Noor on 05/04/20.
//  Copyright © 2020 Muhammad Noor. All rights reserved.
//

import Foundation
import Combine

class FeedNetworkModel: NetworkModel {
	
	func fetchSelebs(_ request: FeedEndpoint, _ completion: @escaping (ResultData<FeedArray>) -> Void) {
		
		var urlRequest = URLRequest(url: request.baseUrl.appendingPathComponent(request.path))
		urlRequest.allHTTPHeaderFields = request.header
		urlRequest.httpMethod = request.method.rawValue
		
		let encoderURLRequest = urlRequest.encode(with: request.parameter)
		
		requestData(encoderURLRequest, completion)
	}
	
	func fetchNews(_ request: FeedEndpoint, _ completion: @escaping (ResultData<NewsArray>) -> Void) {
		
		var urlRequest = URLRequest(url: request.baseUrl.appendingPathComponent(request.path))
		urlRequest.allHTTPHeaderFields = request.header
		urlRequest.httpMethod = request.method.rawValue
		
		let encoderURLRequest = urlRequest.encode(with: request.parameter)
		
		requestData(encoderURLRequest, completion)
	}
	
	func fetchNews(_ request: FeedEndpoint) -> AnyPublisher<NewsArray, Error> {
		
		var urlRequest = URLRequest(url: request.baseUrl.appendingPathComponent(request.path))
		urlRequest.allHTTPHeaderFields = request.header
		urlRequest.httpMethod = request.method.rawValue
		
		let encoderURLRequest = urlRequest.encode(with: request.parameter)
		
		return fetchURL(encoderURLRequest)
	}
	
	func fetchDetailNews(_ request: FeedEndpoint ,_ completion: @escaping (ResultData<NewsDetailResult> ) -> Void) {
		
		var urlRequest = URLRequest(url: request.baseUrl.appendingPathComponent(request.path))
		urlRequest.allHTTPHeaderFields = request.header
		urlRequest.httpMethod = request.method.rawValue
		
		let encoderURLRequest = urlRequest.encode(with: request.parameter)
		
		requestData(encoderURLRequest, completion)
	}
	
	func fetchFollowing(_ request: FeedEndpoint, _ completion: @escaping (ResultData<FeedArray>) -> Void) {
		
		var urlRequest = URLRequest(url: request.baseUrl.appendingPathComponent(request.path))
		urlRequest.allHTTPHeaderFields = request.header
		urlRequest.httpMethod = request.method.rawValue
		
		let encoderURLRequest = urlRequest.encode(with: request.parameter)
		
		requestData(encoderURLRequest, completion)
	}
	
	func fetchFollowing(_ request: FeedEndpoint) -> AnyPublisher<FeedArray, Error> {
		
		var urlRequest = URLRequest(url: request.baseUrl.appendingPathComponent(request.path))
		urlRequest.allHTTPHeaderFields = request.header
		urlRequest.httpMethod = request.method.rawValue
		
		let encoderURLRequest = urlRequest.encode(with: request.parameter)
		
		return fetchURL(encoderURLRequest)
	}
	
	func fetchStory(_ request: FeedEndpoint, _ completion: @escaping (ResultData<StoryResult>) -> Void) {
		
		var urlRequest = URLRequest(url: request.baseUrl.appendingPathComponent(request.path))
		urlRequest.allHTTPHeaderFields = request.header
		urlRequest.httpMethod = request.method.rawValue
		
		let encoderURLRequest = urlRequest.encode(with: request.parameter)
		
		requestData(encoderURLRequest, completion)
	}
	
	func fetchStory(_ request: FeedEndpoint) -> AnyPublisher<StoryResult, Error> {
		
		var urlRequest = URLRequest(url: request.baseUrl.appendingPathComponent(request.path))
		urlRequest.allHTTPHeaderFields = request.header
		urlRequest.httpMethod = request.method.rawValue
		
		let encoderURLRequest = urlRequest.encode(with: request.parameter)
		
		return fetchURL(encoderURLRequest)
	}
    
    func fetchPublicStory(_ request: FeedEndpoint) -> AnyPublisher<PublicStoryResult, Error> {
        
        var urlRequest = URLRequest(url: request.baseUrl.appendingPathComponent(request.path))
        urlRequest.allHTTPHeaderFields = request.header
        urlRequest.httpMethod = request.method.rawValue
        
        let encoderURLRequest = urlRequest.encode(with: request.parameter)
        
        return fetchURL(encoderURLRequest)
    }
    
    func fetchPublicStory(_ request: FeedEndpoint, _ completion: @escaping (ResultData<PublicStoryResult>) -> Void) {
        
        var urlRequest = URLRequest(url: request.baseUrl.appendingPathComponent(request.path))
        urlRequest.allHTTPHeaderFields = request.header
        urlRequest.httpMethod = request.method.rawValue
        
        let encoderURLRequest = urlRequest.encode(with: request.parameter)
        
        requestData(encoderURLRequest, completion)
    }
    
    func fetchStaticStory(_ request: FeedEndpoint, _ completion: @escaping (ResultData<StoryResult>) -> Void) {
        
        var urlRequest = URLRequest(url: request.baseUrl.appendingPathComponent(request.path))
        urlRequest.allHTTPHeaderFields = request.header
        urlRequest.httpMethod = request.method.rawValue
        
        let encoderURLRequest = urlRequest.encode(with: request.parameter)
        
        requestData(encoderURLRequest, completion)
    }
    
    func fetchStaticStory(_ request: FeedEndpoint) -> AnyPublisher<StoryResult, Error> {
        
        var urlRequest = URLRequest(url: request.baseUrl.appendingPathComponent(request.path))
        urlRequest.allHTTPHeaderFields = request.header
        urlRequest.httpMethod = request.method.rawValue
        
        let encoderURLRequest = urlRequest.encode(with: request.parameter)
        
        return fetchURL(encoderURLRequest)
    }
    
	
	func fetchShop(_ request: FeedEndpoint, _ completion: @escaping (ResultData<ShopArray>) -> Void) {
		
		var urlRequest = URLRequest(url: request.baseUrl.appendingPathComponent(request.path))
		urlRequest.allHTTPHeaderFields = request.header
		urlRequest.httpMethod = request.method.rawValue
		
		let encoderURLRequest = urlRequest.encode(with: request.parameter)
		
		requestData(encoderURLRequest, completion)
	}
	
	func fetchDonation(_ request: FeedEndpoint) -> AnyPublisher<DonationResult, Error> {
		
		var urlRequest = URLRequest(url: request.baseUrl.appendingPathComponent(request.path))
		urlRequest.allHTTPHeaderFields = request.header
		urlRequest.httpMethod = request.method.rawValue
		
		let encoderURLRequest = urlRequest.encode(with: request.parameter)
		
		return fetchURL(encoderURLRequest)
	}
	
	func fetchDonationDetail(_ request: FeedEndpoint) -> AnyPublisher<DonationDetailResult, Error> {
		
		var urlRequest = URLRequest(url: request.baseUrl.appendingPathComponent(request.path))
		urlRequest.allHTTPHeaderFields = request.parameter as? [String: String]
		urlRequest.httpMethod = request.method.rawValue
		
		let encoderURLRequest = urlRequest.encode(with: request.parameter)
		
		return fetchURL(encoderURLRequest)
	}
	
	func requestLike(_ request: FeedEndpoint, _ completion: @escaping (ResultData<DefaultResponse>) -> Void) {
		
		var urlRequest = URLRequest(url: request.baseUrl.appendingPathComponent(request.path))
		urlRequest.allHTTPHeaderFields = request.header
		urlRequest.httpMethod = request.method.rawValue
		let jsonData = try? JSONSerialization.data(withJSONObject: request.parameter)
		urlRequest.httpBody = jsonData
		
		let encoderURLRequest = urlRequest.encode(with: request.parameter)
		
		requestData(encoderURLRequest, completion)
	}
	
	func requestLike(_ request: FeedEndpoint) -> AnyPublisher<DefaultResponse, Error>{
		
		var urlRequest = URLRequest(url: request.baseUrl.appendingPathComponent(request.path))
		urlRequest.allHTTPHeaderFields = request.parameter as? [String: String]
		urlRequest.httpMethod = request.method.rawValue
		
		let encoderURLRequest = urlRequest.encode(with: request.parameter)
		
		return fetchURL(encoderURLRequest)
	}
	
	func like(_ request: FeedEndpoint) -> AnyPublisher<DefaultResponse, Error>{
		
		var urlRequest = URLRequest(url: request.baseUrl.appendingPathComponent(request.path))
		urlRequest.allHTTPHeaderFields = request.header
		urlRequest.httpMethod = request.method.rawValue
		
		let encoderURLRequest = urlRequest.encode(with: request.parameter)
		
		return fetchURL(encoderURLRequest)
	}
	
	func PostDetail(_ request: FeedEndpoint) -> AnyPublisher<PostDetailResult, Error> {
		
		var urlRequest = URLRequest(url: request.baseUrl.appendingPathComponent(request.path))
		urlRequest.allHTTPHeaderFields = request.header as! [String: String]
		urlRequest.httpMethod = request.method.rawValue
		
		let encoderURLRequest = urlRequest.encode(with: request.parameter)
		
		return fetchURL(encoderURLRequest)
	}
	
	func fetchComment(_ request: FeedEndpoint) -> AnyPublisher<CommentResult, Error> {

		var urlRequest = URLRequest(url: request.baseUrl.appendingPathComponent(request.path))
		urlRequest.allHTTPHeaderFields = request.header
		urlRequest.httpMethod = request.method.rawValue

		let encoderURLRequest = urlRequest.encode(with: request.parameter)

		return fetchURL(encoderURLRequest)
	}
	
	func fetchSubcomment(_ request: FeedEndpoint) -> AnyPublisher<SubcommentResult, Error> {
		
		var urlRequest = URLRequest(url: request.baseUrl.appendingPathComponent(request.path))
		urlRequest.allHTTPHeaderFields = request.header
		urlRequest.httpMethod = request.method.rawValue
		
		let encoderURLRequest = urlRequest.encode(with: request.parameter)
		
		return fetchURL(encoderURLRequest)
	}
	
	func addComment(_ request: FeedEndpoint, _ completion: @escaping (ResultData<DefaultResponse>) -> Void) {
		
		let dataBody = try! JSONSerialization.data(withJSONObject: request.body)
		var urlRequest = URLRequest(url: request.baseUrl.appendingPathComponent(request.path))
		urlRequest.httpBody = dataBody
		
		urlRequest.httpMethod = request.method.rawValue
		urlRequest.allHTTPHeaderFields = request.header
		
		let encodeRequestUrl = urlRequest.encode(with: request.parameter)
		
		requestData(encodeRequestUrl, completion)
	}
	
	func addSubcomment(_ request: FeedEndpoint, _ completion: @escaping (ResultData<DefaultResponse>) -> Void) {
		
		let dataBody = try! JSONSerialization.data(withJSONObject: request.body)
		let convertString = String(data: dataBody, encoding: .utf8) ?? ""
		var urlRequest = URLRequest(url: request.baseUrl.appendingPathComponent(request.path))
		urlRequest.httpBody = convertString.data(using: .utf16)
		
		urlRequest.httpMethod = request.method.rawValue
		urlRequest.allHTTPHeaderFields = request.header
		
		let encodeRequestUrl = urlRequest.encode(with: request.parameter)
		
		requestData(encodeRequestUrl, completion)
	}

	func deleteComment(_ request: FeedEndpoint, _ completion: @escaping (ResultData<DefaultResponse>) -> Void) {

		let dataBody = try! JSONSerialization.data(withJSONObject: request.body)
		let convertString = String(data: dataBody, encoding: .utf8) ?? ""
		var urlRequest = URLRequest(url: request.baseUrl.appendingPathComponent(request.path))
		urlRequest.httpBody = convertString.data(using: .utf16)

		urlRequest.httpMethod = request.method.rawValue
		urlRequest.allHTTPHeaderFields = request.header

		let encodeRequestUrl = urlRequest.encode(with: request.parameter)

		requestData(encodeRequestUrl, completion)
	}

	func deleteSubComment(_ request: FeedEndpoint, _ completion: @escaping (ResultData<DefaultResponse>) -> Void) {

		var urlRequest = URLRequest(url: request.baseUrl.appendingPathComponent(request.path))

		urlRequest.httpMethod = request.method.rawValue
		urlRequest.allHTTPHeaderFields = request.header

		let encodeRequestUrl = urlRequest.encode(with: request.parameter)

		requestData(encodeRequestUrl, completion)
	}
	
	func fetchAddress(_ request: FeedEndpoint, _ completion: @escaping (ResultData<AddressResult>) -> Void) {
		
		var urlRequest = URLRequest(url: request.baseUrl.appendingPathComponent(request.path))
		urlRequest.allHTTPHeaderFields = request.header
		urlRequest.httpMethod = request.method.rawValue
		
		let encoderURLRequest = urlRequest.encode(with: request.parameter)
		
		requestData(encoderURLRequest, completion)
	}
	
	func fetchListSeleb(_ request: FeedEndpoint) -> AnyPublisher<FeedArray, Error> {
		
		var urlRequest = URLRequest(url: request.baseUrl.appendingPathComponent(request.path))
		urlRequest.allHTTPHeaderFields = request.header as [String: String]
		urlRequest.httpMethod = request.method.rawValue
		
		let encoderURLRequest = urlRequest.encode(with: request.parameter)
		
		return fetchURL(encoderURLRequest)
	}
	
	func deletePost(_ request: FeedEndpoint) -> AnyPublisher<DeleteResponse, Error> {

		var urlRequest = URLRequest(url: request.baseUrl.appendingPathComponent(request.path))
		urlRequest.allHTTPHeaderFields = request.header as [String: String]
		urlRequest.httpMethod = request.method.rawValue
		
		let encoderURLRequest = urlRequest.encode(with: request.parameter)
		
		return fetchURL(encoderURLRequest)
	}

}
