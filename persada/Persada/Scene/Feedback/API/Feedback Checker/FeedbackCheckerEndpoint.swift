//
//  FeedbackCheckerEndpoint.swift
//  KipasKipas
//
//  Created by PT.Koanba on 08/12/22.
//  Copyright © 2022 Koanba. All rights reserved.
//

import Foundation

enum FeedbackCheckerEndpoint {
    case check
    
    func url(baseURL: URL) -> URLRequest {
        switch self {
        case .check:
            var components = URLComponents()
            components.scheme = baseURL.scheme
            components.host = baseURL.host
            components.path = baseURL.path + "/feedback"
            
            var request = URLRequest(url: components.url!)
            request.httpMethod = "GET"
            return request
        }
    }
}
