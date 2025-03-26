//
//  ReviewEndpoint.swift
//  KipasKipas
//
//  Created by Rahmat Trinanda Pramudya Amar on 17/10/22.
//  Copyright © 2022 Koanba. All rights reserved.
//

import Foundation

enum ReviewEndpoint {
    case pagedReview(request: ReviewPagedRequest, isMedia: Bool)
    case createReview(request: ReviewCreateRequest)
    
    public func url(baseURL: URL) -> URLRequest {
        switch self {
        case let .pagedReview(request, isMedia):
            var url = baseURL
            
            if request.isPublic {
                url.appendPathComponent("public")
            }
            
            url.appendPathComponent("products")
            url.appendPathComponent(request.productId)
            url.appendPathComponent("reviews")
            if isMedia{
                url.appendPathComponent("medias")
            }
            
            
            var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false)
            urlComponents?.queryItems = [
                URLQueryItem(name: "page", value: "\(request.page)"),
                URLQueryItem(name: "size", value: "\(request.size)"),
                URLQueryItem(name: "sortBy", value: "\(request.sortBy)"),
                URLQueryItem(name: "direction", value: "\(request.direction)")
            ]
            return URLRequest(url: urlComponents?.url ?? url)
            
        case let .createReview(request):
            var url = baseURL
            url.appendPathComponent("orders")
            url.appendPathComponent(request.orderId)
            url.appendPathComponent("reviews")
            
            var req = try! URLRequest(url: url, method: .post)
            let bodyRequest = try! JSONEncoder().encode(request.body)
            req.httpBody = bodyRequest
            
            return req
        }
    }
}
