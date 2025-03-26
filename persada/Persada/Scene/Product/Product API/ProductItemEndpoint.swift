//
//  ProductEndpoint.swift
//  KipasKipas
//
//  Created by Rahmat Trinanda Pramudya Amar on 09/02/23.
//  Copyright © 2023 Koanba. All rights reserved.
//

import Foundation

enum ProductItemEndpoint {
    case list(request: ProductListLoaderRequest)
    case search(request: ProductSearchLoaderRequest)
    case detail(request: ProductDetailRequest, isPublic: Bool)
    
    func url(baseURL: URL) -> URLRequest {
        switch self {
        case let .list(request):
            var url = baseURL
            url.appendPathComponent("products")
            url.appendPathComponent("account")
            url.appendPathComponent(request.accountId)
            
            var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false)
            urlComponents?.queryItems = [
                URLQueryItem(name: "page", value: "\(request.page)"),
                URLQueryItem(name: "size", value: "\(request.size)"),
                URLQueryItem(name: "sortBy", value: "\(request.sortBy)"),
                URLQueryItem(name: "direction", value: "\(request.direction)"),
                URLQueryItem(name: "type", value: "\(request.type)")
            ]
            
            return URLRequest(url: urlComponents?.url ?? url)
            
        case let .search(request):
            var url = baseURL
            url.appendPathComponent("products")
            url.appendPathComponent("search")
            url.appendPathComponent("account")
            url.appendPathComponent(request.accountId)
            
            var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false)
            urlComponents?.queryItems = [
                URLQueryItem(name: "page", value: "\(request.page)"),
                URLQueryItem(name: "size", value: "\(request.size)"),
                URLQueryItem(name: "sortBy", value: "\(request.sortBy)"),
                URLQueryItem(name: "direction", value: "\(request.direction)"),
                URLQueryItem(name: "type", value: "\(request.type)"),
                URLQueryItem(name: "keyword", value: "\(request.keyword)")
            ]
            
            return URLRequest(url: urlComponents?.url ?? url)
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
