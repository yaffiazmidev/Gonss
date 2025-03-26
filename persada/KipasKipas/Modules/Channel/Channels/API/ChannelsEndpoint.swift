//
//  ChannelsEndpoint.swift
//  KipasKipas
//
//  Created by DENAZMI on 19/12/22.
//  Copyright © 2022 Koanba. All rights reserved.
//

import Foundation

enum ChannelsEndpoint {
    case get(request: ChannelsRequest)
    
    func url(baseURL: URL) -> URLRequest {
        switch self {
        case .get(let request):
            var components = URLComponents()
            components.scheme = baseURL.scheme
            components.host = baseURL.host
            components.path = baseURL.path + "\(request.isPublic ? "/public" : "")/channels"
            components.queryItems = [
                URLQueryItem(name: "page", value: "\(request.page)"),
            ].compactMap { $0 }
            
            var request = URLRequest(url: components.url!)
            request.httpMethod = "GET"
            return request
        }
    }
}
