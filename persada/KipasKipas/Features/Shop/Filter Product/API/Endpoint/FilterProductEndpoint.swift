//
//  FilterProductEndpoint.swift
//  KipasKipas
//
//  Created by Muhammad Noor on 20/01/23.
//  Copyright © 2023 Koanba. All rights reserved.
//

import Foundation

enum FilterProductEndpoint {
    case get(request: FilterProductRequest, isPublic: Bool)
    
    func url(baseURL: URL) -> URLRequest {
        switch self {
        case let .get(request, isPublic):
            var components = URLComponents()
            components.scheme = baseURL.scheme
            components.host = baseURL.host
            if isPublic {
                components.path = baseURL.path + "/public/products/search"
            } else {
                components.path = baseURL.path + "/products/search"
            }
            
            if let productCategoryId = request.productCategoryId {
                components.queryItems = [
                    URLQueryItem(name: "productCategoryId", value: "\(productCategoryId)"),
                    URLQueryItem(name: "isVerified", value: "\(request.isVerified)"),
                    URLQueryItem(name: "page", value: "\(request.page)"),
                    URLQueryItem(name: "size", value: "\(request.size)"),
                ].compactMap { $0 }
                if let keyword = request.keyword {
                    components.queryItems = [
                        URLQueryItem(name: "productCategoryId", value: "\(productCategoryId)"),
                        URLQueryItem(name: "isVerified", value: "\(request.isVerified)"),
                        URLQueryItem(name: "keyword", value: "\(keyword)"),
                        URLQueryItem(name: "page", value: "\(request.page)"),
                        URLQueryItem(name: "size", value: "\(request.size)"),
                    ].compactMap { $0 }
                }
            } else if let keyword = request.keyword  {
                components.queryItems = [
                    URLQueryItem(name: "keyword", value: "\(keyword)"),
                    URLQueryItem(name: "isVerified", value: "\(request.isVerified)"),
                    URLQueryItem(name: "page", value: "\(request.page)"),
                    URLQueryItem(name: "size", value: "\(request.size)"),
                ].compactMap { $0 }
            }
            
            var urlRequest = URLRequest(url: components.url!)
            urlRequest.httpMethod = "GET"
            return urlRequest
        }
    }
}
