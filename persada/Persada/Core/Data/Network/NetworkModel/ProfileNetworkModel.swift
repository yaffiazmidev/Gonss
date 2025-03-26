//
//  ProfileNetworkModel.swift
//  Persada
//
//  Created by Muhammad Noor on 04/05/20.
//  Copyright © 2020 Muhammad Noor. All rights reserved.
//

import Foundation
import Combine

final class ProfileNetworkModel: NetworkModel {
    
    func deleteMyAccount(_ request: ProfileEndpoint, _ completion: @escaping (ResultData<DefaultResponse>) -> Void) {
        var urlRequest = URLRequest(url: request.baseUrl.appendingPathComponent(request.path))
        
        do {
            let jsonBody = try JSONSerialization.data(withJSONObject: request.body)
            urlRequest.httpBody = jsonBody
        }catch{
            print("some error")
        }
        
        urlRequest.httpMethod = request.method.rawValue
        urlRequest.allHTTPHeaderFields = request.header
        let encodeRequestURL = urlRequest.encode(with: request.parameter)
        requestData(encodeRequestURL, completion)
    }
	
	func followAccount(_ request: ProfileEndpoint, _ completion: @escaping (ResultData<DefaultResponse>) -> Void) {
		
		var urlRequest = URLRequest(url: request.baseUrl.appendingPathComponent(request.path))
		urlRequest.allHTTPHeaderFields = request.header
		urlRequest.httpMethod = request.method.rawValue
		
		let encodeRequestURL = urlRequest.encode(with: request.parameter)
		
		requestData(encodeRequestURL, completion)
	}

	func updateAccount(_ request: ProfileEndpoint, _ source: EditProfile, _ completion: @escaping (ResultData<DefaultResponse>) -> Void) {
		
		var urlRequest = URLRequest(url: request.baseUrl.appendingPathComponent(request.path))
		
		do {
			let jsonBody = try JSONEncoder().encode(source)
			urlRequest.httpBody = jsonBody
		}catch{
			print("some error")
		}
		
		urlRequest.httpMethod = request.method.rawValue
		urlRequest.allHTTPHeaderFields = request.header
		
		let encodeRequestURL = urlRequest.encode(with: request.parameter)
		
		requestData(encodeRequestURL, completion)
	}
	
	func updateProfile(_ request: ProfileEndpoint, _ source: EditProfile, completion: @escaping (ResultData<DefaultResponse>) -> Void) {
		
//		urlRequest.httpBody = convertString.data(using: .utf16)
//		urlRequest.httpMethod = request.method.rawValue
//		urlRequest.allHTTPHeaderFields = request.header
//
//		let encodeRequestURL = urlRequest.encode(with: request.parameter)
//
//		requestData(encodeRequestURL, completion)
	}
	
	func followAccount(_ request: ProfileEndpoint) -> AnyPublisher<DefaultResponse, Error> {
		
		var urlRequest = URLRequest(url: request.baseUrl.appendingPathComponent(request.path))
		urlRequest.allHTTPHeaderFields = request.header
		urlRequest.httpMethod = request.method.rawValue
		
		let encodeRequestURL = urlRequest.encode(with: request.parameter)
		
		return fetchURL(encodeRequestURL)
	}
	
	func searchFollowers(_ request: ProfileEndpoint) -> AnyPublisher<FollowerResult, Error> {
		
		var urlRequest = URLRequest(url: request.baseUrl.appendingPathComponent(request.path))
		urlRequest.allHTTPHeaderFields = request.header
		urlRequest.httpMethod = request.method.rawValue
		
		let encodeRequestURL = urlRequest.encode(with: request.parameter)
		
		return fetchURL(encodeRequestURL)
	}
	
	func searchFollowing(_ request: ProfileEndpoint) -> AnyPublisher<FollowerResult, Error> {
		
		var urlRequest = URLRequest(url: request.baseUrl.appendingPathComponent(request.path))
		urlRequest.allHTTPHeaderFields = request.header
		urlRequest.httpMethod = request.method.rawValue
		
		let encodeRequestURL = urlRequest.encode(with: request.parameter)
		
		return fetchURL(encodeRequestURL)
	}
	
	func followChannel(_ request: ProfileEndpoint) -> AnyPublisher<DefaultResponse, Error> {
		
		var urlRequest = URLRequest(url: request.baseUrl.appendingPathComponent(request.path))
		urlRequest.allHTTPHeaderFields = request.header
		urlRequest.httpMethod = request.method.rawValue
		
		let encodeRequestURL = urlRequest.encode(with: request.parameter)
		
		return fetchURL(encodeRequestURL)
	}
	
	func unfollowChannel(_ request: ProfileEndpoint) -> AnyPublisher<DefaultResponse, Error> {
		
		var urlRequest = URLRequest(url: request.baseUrl.appendingPathComponent(request.path))
		urlRequest.allHTTPHeaderFields = request.header
		urlRequest.httpMethod = request.method.rawValue
		
		let encodeRequestURL = urlRequest.encode(with: request.parameter)
		
		return fetchURL(encodeRequestURL)
	}
	
	func unfollowAccount(_ request: ProfileEndpoint, _ completion: @escaping (ResultData<DefaultResponse>) -> Void) {
		
		var urlRequest = URLRequest(url: request.baseUrl.appendingPathComponent(request.path))
		urlRequest.allHTTPHeaderFields = request.header
		urlRequest.httpMethod = request.method.rawValue
		
		let encodeRequestURL = urlRequest.encode(with: request.parameter)
		
		requestData(encodeRequestURL, completion)
	}
	
	func fetchAccount(_ request: ProfileEndpoint, _ completion: @escaping (ResultData<ProfileResult>) -> Void) {
		
		var urlRequest = URLRequest(url: request.baseUrl.appendingPathComponent(request.path))
		urlRequest.allHTTPHeaderFields = request.header
		urlRequest.httpMethod = request.method.rawValue
		
		let encodeRequestURL = urlRequest.encode(with: request.parameter)
		
		requestData(encodeRequestURL, completion)
	}
    
    func getAccount(_ request: ProfileEndpoint, _ completion: @escaping (ResultData<EditProfileResult>) -> Void) {
        
        var urlRequest = URLRequest(url: request.baseUrl.appendingPathComponent(request.path))
        urlRequest.allHTTPHeaderFields = request.header
        urlRequest.httpMethod = request.method.rawValue
        
        let encodeRequestURL = urlRequest.encode(with: request.parameter)
        
        requestData(encodeRequestURL, completion)
    }
	
	func fetchPostAccount(_ request: ProfileEndpoint, _ completion: @escaping (ResultData<ProfilePostResult>) -> Void) {
		
		var urlRequest = URLRequest(url: request.baseUrl.appendingPathComponent(request.path))
		urlRequest.allHTTPHeaderFields = request.header
		urlRequest.httpMethod = request.method.rawValue
		
		let encodeRequestURL = urlRequest.encode(with: request.parameter)
		
		requestData(encodeRequestURL, completion)
	}
	
	func requestPostAccount(_ request: ProfileEndpoint) -> AnyPublisher<ProfilePostResult, Error> {
		
		var urlRequest = URLRequest(url: request.baseUrl.appendingPathComponent(request.path))
		urlRequest.allHTTPHeaderFields = request.header
		urlRequest.httpMethod = request.method.rawValue
		
		let encodeRequestURL = urlRequest.encode(with: request.parameter)
		
		return fetchURL(encodeRequestURL)
	}
	
	func fetchFollowers(_ request: ProfileEndpoint, _ completion: @escaping (ResultData<TotalFollow>) -> Void) {
		
		var urlRequest = URLRequest(url: request.baseUrl.appendingPathComponent(request.path))
		urlRequest.allHTTPHeaderFields = request.header
		urlRequest.httpMethod = request.method.rawValue
		
		let encodeRequestURL = urlRequest.encode(with: request.parameter)
		
		requestData(encodeRequestURL, completion)
	}
	
	func fetchFollowers(_ request: ProfileEndpoint) -> AnyPublisher<FollowerResult, Error>{
		
		var urlRequest = URLRequest(url: request.baseUrl.appendingPathComponent(request.path))
		urlRequest.allHTTPHeaderFields = request.header
		urlRequest.httpMethod = request.method.rawValue
		
		let encodeRequestURL = urlRequest.encode(with: request.parameter)
		
		return fetchURL(encodeRequestURL)
	}
	
	func fetchFollowings(_ request: ProfileEndpoint) -> AnyPublisher<FollowerResult, Error>{
		
		var urlRequest = URLRequest(url: request.baseUrl.appendingPathComponent(request.path))
		urlRequest.allHTTPHeaderFields = request.header
		urlRequest.httpMethod = request.method.rawValue
		
		let encodeRequestURL = urlRequest.encode(with: request.parameter)
		
		return fetchURL(encodeRequestURL)
	}
	
	func fetchFollowings(_ request: ProfileEndpoint, _ completion: @escaping (ResultData<TotalFollow>) -> Void) {
		
		var urlRequest = URLRequest(url: request.baseUrl.appendingPathComponent(request.path))
		urlRequest.allHTTPHeaderFields = request.header
		urlRequest.httpMethod = request.method.rawValue
		
		let encodeRequestURL = urlRequest.encode(with: request.parameter)
		
		requestData(encodeRequestURL, completion)
	}
	
	func profileUsername(_ request: ProfileEndpoint) -> AnyPublisher<ProfileResult, Error> {
		var urlRequest = URLRequest(url: request.baseUrl.appendingPathComponent(request.path))
		urlRequest.allHTTPHeaderFields = request.header
		urlRequest.httpMethod = request.method.rawValue
		
		let encodeRequestURL = urlRequest.encode(with: request.parameter)
		
		return fetchURL(encodeRequestURL)
	}
    
    func fetchStory(_ request: ProfileEndpoint) -> AnyPublisher<StoryResult, Error> {
        var urlRequest = URLRequest(url: request.baseUrl.appendingPathComponent(request.path))
        urlRequest.allHTTPHeaderFields = request.header
        urlRequest.httpMethod = request.method.rawValue
        
        let encodeRequestURL = urlRequest.encode(with: request.parameter)
        
        return fetchURL(encodeRequestURL)
    }
}
