//
//  ResellerConfirmProductEndpoint.swift
//  KipasKipas
//
//  Created by Muhammad Noor on 06/03/23.
//  Copyright © 2023 Koanba. All rights reserved.
//

import Foundation

enum ResellerConfirmProductEndpoint {
    case confirm(request: ResellerProductConfirmRequest)
    case get(request: UserSellerRequest)
    case getProduct(request: ResellerProductRequest)
    
    func url(baseURL: URL) -> URLRequest {
        switch self {
        
        case let .confirm(request):
            var components = URLComponents()
            components.scheme = baseURL.scheme
            components.host = baseURL.host
            components.path = baseURL.path + "/products/reseller"
            
            let body = try! JSONEncoder().encode(request)
            
            var urlRequest = URLRequest(url: components.url!)
            urlRequest.httpMethod = "POST"
            urlRequest.httpBody = body
            return urlRequest
        case let .get(request):
            var components = URLComponents()
            components.scheme = baseURL.scheme
            components.host = baseURL.host
            components.path = baseURL.path + "/profile/\(request.id)"
            
            var urlRequest = URLRequest(url: components.url!)
            urlRequest.httpMethod = "GET"
            return urlRequest
        case let .getProduct(request):
            var components = URLComponents()
            components.scheme = baseURL.scheme
            components.host = baseURL.host
            components.path = baseURL.path + "/products/\(request.id)"
            
            var urlRequest = URLRequest(url: components.url!)
            urlRequest.httpMethod = "GET"
            return urlRequest
        }
    }
}

struct ResellerProductRequest {
    let id: String
}
