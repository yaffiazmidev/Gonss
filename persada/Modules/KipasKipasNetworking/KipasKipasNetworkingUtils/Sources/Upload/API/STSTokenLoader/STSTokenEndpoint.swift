//
//  STSTokenEndpoint.swift
//  KipasKipas
//
//  Created by Rahmat Trinanda Pramudya Amar on 13/01/23.
//  Copyright © 2023 Koanba. All rights reserved.
//

import Foundation

enum STSTokenEndpoint {
    case load(request: STSTokenLoaderRequest)
    
    func url(baseUrl: URL) -> URLRequest {
        switch self {
        case let .load(req):
            
            let loginString = String(format: "%@:%@", req.username, req.password)
            let loginData = loginString.data(using: String.Encoding.utf8)!
            let base64LoginString = loginData.base64EncodedString()
            
            var request = URLRequest(url: baseUrl)
            request.httpMethod = "GET"
            request.setValue("Basic \(base64LoginString)", forHTTPHeaderField: "Authorization")
            
            return request
        }
        
    }
}
