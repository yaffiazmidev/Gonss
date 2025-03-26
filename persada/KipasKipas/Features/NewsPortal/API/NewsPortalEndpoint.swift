//
//  NewsPortalEndpoint.swift
//  KipasKipas
//
//  Created by Rahmat Trinanda Pramudya Amar on 07/02/24.
//  Copyright © 2024 Koanba. All rights reserved.
//

import Foundation

enum NewsPortalEndpoint {
    case data
    
    func url(baseURL: URL) -> URLRequest {
        switch self {
        case .data:
            var components = URLComponents()
            components.scheme = baseURL.scheme
            components.host = baseURL.host
            components.path = baseURL.path + "/portal"
//            components.queryItems = [
//                URLQueryItem(name: "value", value: username)
//            ]
            
            return URLRequest(url: components.url!)
        }
    }
}
