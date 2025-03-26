//
//  RecommendShopEndpoint.swift
//  KipasKipas
//
//  Created by Muhammad Noor on 19/01/23.
//  Copyright © 2023 Koanba. All rights reserved.
//

import Foundation

enum RecommendShopEndpoint {
    case get(isPublic: Bool)
    
    func url(baseURL: URL) -> URLRequest {
        switch self {
        case let .get(isPublic):
            var components = URLComponents()
            components.scheme = baseURL.scheme
            components.host = baseURL.host
            
            if isPublic {
                components.path = baseURL.path + "/public/products/recommendations"
            } else {
                components.path = baseURL.path + "/products/recommendations"
            }
            
            var request = URLRequest(url: components.url!)
            request.httpMethod = "GET"
            return request
        }
    }
}
