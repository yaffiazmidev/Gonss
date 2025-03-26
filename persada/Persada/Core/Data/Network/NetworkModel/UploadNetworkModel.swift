//
//  UploadNetworkModel.swift
//  Persada
//
//  Created by Muhammad Noor on 24/04/20.
//  Copyright © 2020 Muhammad Noor. All rights reserved.
//

import UIKit
import Alamofire
import AVFoundation
import Combine

class UploadNetworkModel: NetworkModel {
	
	func postSocial(_ request: UploadEndpoint,  _ source: PostSocialParameter, _ completion: @escaping (ResultData<DefaultResponse>) -> Void) {
		
		var urlRequest = URLRequest(url: request.baseUrl.appendingPathComponent(request.path))
		
		do {
			let jsonBody = try JSONEncoder().encode(source)
			urlRequest.httpBody = jsonBody
		}catch{
			print("some error")
		}
		
		urlRequest.httpMethod = request.method.rawValue
		urlRequest.addValue("Bearer \(getToken() ?? "")", forHTTPHeaderField: "Authorization")
		urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
		
		requestData(urlRequest, completion)
	}
	
	func postSocial(_ request: UploadEndpoint,  _ source: ParameterPostSocial, _ completion: @escaping (ResultData<DefaultResponse>) -> Void) {
		
		var urlRequest = URLRequest(url: request.baseUrl.appendingPathComponent(request.path))
		
		do {
			let jsonBody = try JSONEncoder().encode(source)
			urlRequest.httpBody = jsonBody
		}catch{
			print("some error")
		}
		
		urlRequest.httpMethod = request.method.rawValue
		urlRequest.addValue("Bearer \(getToken() ?? "")", forHTTPHeaderField: "Authorization")
		urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
		
		requestData(urlRequest, completion)
	}
    
    func postSocialNew(_ request: UploadEndpoint,  _ source: PostFeedParam, _ completion: @escaping (ResultData<DefaultResponse>) -> Void) {
        
        var urlRequest = URLRequest(url: request.baseUrl.appendingPathComponent(request.path))
        
        do {
            let jsonBody = try JSONEncoder().encode(source)
            print("Paramnya json \(try source.asDictionary())")
            urlRequest.httpBody = jsonBody
        }catch{
            print("some error")
        }
        
        urlRequest.httpMethod = request.method.rawValue
        urlRequest.addValue("Bearer \(getToken() ?? "")", forHTTPHeaderField: "Authorization")
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        requestData(urlRequest, completion)
    }
	
	func postProduct(_ request: UploadEndpoint, _ source: ParameterPostProduct, _ completion: @escaping (ResultData<DefaultResponse>) -> Void) {
		
		var urlRequest = URLRequest(url: request.baseUrl.appendingPathComponent(request.path))
		
		do {
			let jsonBody = try JSONEncoder().encode(source)
			urlRequest.httpBody = jsonBody
		}catch{
			print("some error")
		}
		
		urlRequest.httpMethod = request.method.rawValue
		urlRequest.addValue("Bearer \(getToken() ?? "")", forHTTPHeaderField: "Authorization")
		urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
		
		requestData(urlRequest, completion)
	}
	
	func createStory(_ request: UploadEndpoint, _ source: ParameterPostStory, _ completion: @escaping (ResultData<DefaultResponse>) -> Void) {
		
		var urlRequest = URLRequest(url: request.baseUrl.appendingPathComponent(request.path))
		
		do {
			let jsonBody = try JSONEncoder().encode(source)
			urlRequest.httpBody = jsonBody
		}catch{
			print("some error")
		}
		
		urlRequest.httpMethod = request.method.rawValue
		urlRequest.addValue("Bearer \(getToken() ?? "")", forHTTPHeaderField: "Authorization")
		urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
		
		requestData(urlRequest, completion)
	}
    
    func stopAll(){
        AF.session.getAllTasks { (tasks) in
            tasks.forEach {$0.cancel() }
        }
    }
}

extension Encodable {
	var dictionary: [String: Any]? {
		guard let data = try? JSONEncoder().encode(self) else { return nil }
		return (try? JSONSerialization.jsonObject(with: data, options: .allowFragments)).flatMap { $0 as? [String: Any] }
	}
}


// MARK: - CreateStoriesParameters
struct CreateStoriesParameters: Codable {
	var typePost: String?
	var postStory: [PostStoryParam]?
}

// MARK: - PostStoryParam
struct PostStoryParam: Codable {
	var media: [MediaParameter]?
	var postProduct: [PostProductIds]?
}

// MARK: - PostProductIds
struct PostProductIds: Codable {
	var id: String?
}
