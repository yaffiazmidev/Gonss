//
//  ChannelsFollowingEndpoint.swift
//  KipasKipas
//
//  Created by DENAZMI on 21/12/22.
//  Copyright © 2022 Koanba. All rights reserved.
//

import Foundation

enum ChannelsFollowingEndpoint {
    case get(request: ChannelsFollowingRequest)
    
    func url(baseURL: URL) -> URLRequest {
        
        switch self {
        case .get(let request):
            var components = URLComponents()
            components.scheme = baseURL.scheme
            components.host = baseURL.host
            components.path = baseURL.path + "/channels/me/follow"
            components.queryItems = [
                URLQueryItem(name: "page", value: "\(request.page)"),
                URLQueryItem(name: "size", value: "10"),
                URLQueryItem(name: "sort", value: "createAt,desc")
            ].compactMap({ $0 })
            
            var request = URLRequest(url: components.url!)
            request.httpMethod = "GET"
            return request
        }
    }
}
