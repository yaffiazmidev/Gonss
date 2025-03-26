//
//  FeedbackEndpoint.swift
//  KipasKipas
//
//  Created by PT.Koanba on 06/12/22.
//  Copyright © 2022 Koanba. All rights reserved.
//

import Foundation

enum FeedbackEndpoint {
    case send(request: FeedbackSenderRequest)
    
    func url(baseURL: URL) -> URLRequest {
        switch self {
        case let .send(request):
            var components = URLComponents()
            components.scheme = baseURL.scheme
            components.host = baseURL.host
            components.path = baseURL.path + "/feedback"
            
            let body = try! JSONEncoder().encode(request)
            
            var request = URLRequest(url: components.url!)
            request.httpMethod = "POST"
            request.httpBody = body
            return request
        }
    }
}
