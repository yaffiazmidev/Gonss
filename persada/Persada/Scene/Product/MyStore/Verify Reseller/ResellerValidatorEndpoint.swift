//
//  ResellerValidatorEndpoint.swift
//  KipasKipas
//
//  Created by Muhammad Noor on 26/02/23.
//  Copyright © 2023 Koanba. All rights reserved.
//

import Foundation
import KipasKipasNetworking

enum ResellerValidatorEndpoint {
    case verify
    
    func url(baseURL: URL) -> URLRequest {
        switch self {
        case .verify:
            var components = URLComponents()
            components.scheme = baseURL.scheme
            components.host = baseURL.host
            components.path = baseURL.path + "/products/reseller/validation"
            
            var urlRequest = URLRequest(url: components.url!)
            urlRequest.httpMethod = "GET"
            return urlRequest
        }
    }
}
