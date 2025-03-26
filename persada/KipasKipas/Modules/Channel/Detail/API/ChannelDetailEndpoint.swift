//
//  ChannelDetailEndpoint.swift
//  KipasKipas
//
//  Created by DENAZMI on 19/12/22.
//  Copyright © 2022 Koanba. All rights reserved.
//

import Foundation

enum ChannelDetailEndpoint {
    case get(request: ChannelDetailRequest)
    
    func url(baseURL: URL) -> URLRequest {
        switch self {
        case .get(let request):
            var components = URLComponents()
            components.scheme = baseURL.scheme
            components.host = baseURL.host
            components.path = baseURL.path + "/channels/\(request.id)"
            
            var request = URLRequest(url: components.url!)
            request.httpMethod = "GET"
            return request
        }
    }
}
