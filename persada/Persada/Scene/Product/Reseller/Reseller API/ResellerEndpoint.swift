//
//  ResellerEndpoint.swift
//  KipasKipas
//
//  Created by Rahmat Trinanda Pramudya Amar on 22/02/23.
//  Copyright © 2023 Koanba. All rights reserved.
//

import Foundation

enum ResellerEndpoint {
    case data(request: ResellerDataLoaderRequest)
    case set(request: ResellerProductSetterRequest)
    case update(request: ResellerProductUpdaterRequest)
    case stop(request: ResellerProductStopperRequest)
    case remove(request: ResellerProductRemoveRequest)
    
    func url(baseURL: URL) -> URLRequest {
        switch self {
        case let .data(request):
            var url = baseURL
            url.appendPathComponent("products")
            url.appendPathComponent("resell")
            
            var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false)
            urlComponents?.queryItems = [
                URLQueryItem(name: "keyword", value: "\(request.keyword)"),
                URLQueryItem(name: "page", value: "\(request.page)"),
                URLQueryItem(name: "size", value: "\(request.size)"),
                URLQueryItem(name: "sortBy", value: "\(request.sortBy)"),
                URLQueryItem(name: "direction", value: "\(request.direction)")
            ]
            return URLRequest(url: urlComponents?.url ?? url)
            
            
        case let .set(request):
            var url = baseURL
            url.appendPathComponent("products")
            url.appendPathComponent("resell")

            let body = try! JSONEncoder().encode(request)
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.httpBody = body
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            return request
            
            
        case let .update(request):
            var url = baseURL
            url.appendPathComponent("products")
            url.appendPathComponent(request.id)
            url.appendPathComponent("resell")

            let body = try! JSONEncoder().encode(request)
            var request = URLRequest(url: url)
            request.httpMethod = "PUT"
            request.httpBody = body
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            return request
            
        case let .stop(request):
            var components = URLComponents()
            components.scheme = baseURL.scheme
            components.host = baseURL.host
            components.path = baseURL.path + "/products/\(request.id)/resell/false"
            
            var request = URLRequest(url: components.url!)
            request.httpMethod = "PUT"
            return request
            
        case let .remove(request):
            var components = URLComponents()
            components.scheme = baseURL.scheme
            components.host = baseURL.host
            components.path = baseURL.path + "/products/\(request.id)/reseller"
            
            var request = URLRequest(url: components.url!)
            request.httpMethod = "DELETE"
            return request
        }
    }
}
