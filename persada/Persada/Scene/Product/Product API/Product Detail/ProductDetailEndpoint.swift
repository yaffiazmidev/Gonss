//
//  ProductDetailEndpoint.swift
//  KipasKipas
//
//  Created by Muhammad Noor on 10/02/23.
//  Copyright © 2023 Koanba. All rights reserved.
//

import Foundation

enum ProductDetailEndpoint {
    case detail(request: ProductDetailRequest, isPublic: Bool)
//    case getAccount(id: String, isPublic: Bool)
//    case address(id: String, isPublic: Bool)
//    case archive(isArchived: Bool, productId)
    
    func url(baseURL: URL) -> URLRequest {
        switch self {
        case let .detail(request, isPublic):
            var components = URLComponents()
            components.scheme = baseURL.scheme
            components.host = baseURL.host
            
            if isPublic {
                components.path = baseURL.path + "/public/products/\(request.id)"
            } else {
                components.path = baseURL.path + "/products/\(request.id)"
            }
            
            var urlRequest = URLRequest(url: components.url!)
            urlRequest.httpMethod = "GET"
            return urlRequest
        }
    }
}
