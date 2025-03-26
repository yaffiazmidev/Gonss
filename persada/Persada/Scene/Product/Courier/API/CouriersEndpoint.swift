//
//  CouriersAPI.swift
//  KipasKipas
//
//  Created by Muhammad Noor on 24/11/22.
//  Copyright © 2022 Koanba. All rights reserved.
//

import Foundation

enum CouriersEndpoint {
    case get(request: CourierRequest)
    
    func url(baseURL: URL) -> URLRequest {
        switch self {
        case let .get(request):
            var components = URLComponents()
            components.scheme = baseURL.scheme
            components.host = baseURL.host
            components.path = baseURL.path + "/shipments/price"
            
            let body = try! JSONEncoder().encode(request)
            
            var request = URLRequest(url: components.url!)
            request.httpMethod = "POST"
            request.httpBody = body
            return request
        }
    }
}
