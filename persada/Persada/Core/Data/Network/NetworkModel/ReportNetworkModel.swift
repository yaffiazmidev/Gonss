//
//  ReportNetworkModel.swift
//  Persada
//
//  Created by Muhammad Noor on 19/05/20.
//  Copyright © 2020 Muhammad Noor. All rights reserved.
//

import Foundation

class ReportNetworkModel: NetworkModel {
    
    func submitReport(_ request: ReportEndpoint, _ completion: @escaping (ResultData<DefaultResponse>) -> Void) {
        
        let dataBody = try! JSONSerialization.data(withJSONObject: request.body)
        let convertString = String(data: dataBody, encoding: .utf8) ?? ""
        var urlRequest = URLRequest(url: request.baseUrl.appendingPathComponent(request.path))
        urlRequest.httpBody = convertString.data(using: .utf16)
        
        urlRequest.httpMethod = request.method.rawValue
        urlRequest.addValue("Bearer \(getToken() ?? "")", forHTTPHeaderField: "Authorization")
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        requestData(urlRequest, completion)
    }
    
    func fetchReason(_ request: ReportEndpoint, _ completion: @escaping (ResultData<ReasonResult>) -> Void) {
        
        var urlRequest = URLRequest(url: request.baseUrl.appendingPathComponent(request.path))
        urlRequest.allHTTPHeaderFields = request.parameter as? [String: String]
        urlRequest.httpMethod = request.method.rawValue
        
        let encoderUrlRequest = urlRequest.encode(with: request.parameter)
        
        requestData(encoderUrlRequest, completion)
    }

	func checkIsReportExist(_ request: ReportEndpoint, _ completion: @escaping (ResultData<DefaultBool>) -> Void) {

		var urlRequest = URLRequest(url: request.baseUrl.appendingPathComponent(request.path))
		urlRequest.allHTTPHeaderFields = request.header as? [String: String]
		urlRequest.httpMethod = request.method.rawValue

		let encoderUrlRequest = urlRequest.encode(with: request.parameter)

		requestData(encoderUrlRequest, completion)
	}
}
