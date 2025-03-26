//
//  NotificationPreferencesEndpoint.swift
//  KipasKipas
//
//  Created by PT.Koanba on 15/11/22.
//  Copyright © 2022 Koanba. All rights reserved.
//

import Foundation

enum NotificationPreferencesEndpoint {
    case get(request: NotificationPreferencesRequest)
    case update(request: NotificationPreferencesUpdateRequest)

    func url(baseURL: URL) -> URLRequest {
        switch self {
        case let .get(request):
            var components = URLComponents()
            components.scheme = baseURL.scheme
            components.host = baseURL.host
            components.path = baseURL.path + "/notifications/preference"
            components.queryItems = [
                URLQueryItem(name: "code", value: "\(request.code)"),
            ].compactMap { $0 }
            
            var request = URLRequest(url: components.url!)
            request.httpMethod = "GET"
            return request
            
        case let .update(request):
            
            var components = URLComponents()
            components.scheme = baseURL.scheme
            components.host = baseURL.host
            components.path = baseURL.path + "/notifications/preference"
            components.queryItems = [
                URLQueryItem(name: "code", value: "\(request.code)"),
            ].compactMap { $0 }
            
            let body = try! JSONEncoder().encode(request)
            
            var request = URLRequest(url: components.url!)
            request.httpMethod = "PATCH"
            request.httpBody = body
            return request
        }
        
    }
}
