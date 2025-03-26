//
//  ShopEndpoint.swift
//  KipasKipas
//
//  Created by Muhammad Noor on 20/01/23.
//  Copyright © 2023 Koanba. All rights reserved.
//

import Foundation

enum ShopEndpoint {
    case get(request: ShopRequest, isPublic: Bool)
    
    func url(baseURL: URL) -> URLRequest {
        
        switch self {
        case let .get(request, isPublic):
            var components = URLComponents()
            components.scheme = baseURL.scheme
            components.host = baseURL.host
            if isPublic {
                components.path = baseURL.path + "/public/products"
            } else {
                components.path = baseURL.path + "/products"
            }
            
            components.queryItems = [
                URLQueryItem(name: "page", value: "\(request.page)"),
                URLQueryItem(name: "size", value: "\(request.size)"),
            ].compactMap { $0 }
            
            var request = URLRequest(url: components.url!)
            request.httpMethod = "GET"
            return request
        }
        
    }
}
