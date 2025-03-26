//
//  AuthOTPEndpoint.swift
//  KipasKipas
//
//  Created by DENAZMI on 06/01/23.
//  Copyright © 2023 Koanba. All rights reserved.
//

import Foundation

enum AuthOTPEndpoint {
    case post(request: AuthOTPRequest)
    
    func url(baseURL: URL) -> URLRequest {
        
        switch self {
        case .post(let request):
            var components = URLComponents()
            components.scheme = baseURL.scheme
            components.host = baseURL.host
            components.path = "/auth/otp"
            
            let body = try! JSONEncoder().encode(request)
            
            var request = URLRequest(url: components.url!)
            request.httpMethod = "POST"
            request.httpBody = body
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            return request
        }
    }
}
