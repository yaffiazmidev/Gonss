//
//  FanBaseEndpoint.swift
//  Persada
//
//  Created by Muhammad Noor on 09/04/20.
//  Copyright © 2020 Muhammad Noor. All rights reserved.
//

import Foundation

enum FanBaseEndpoint {
    case fanbaseKamu
    case fanbase
}

extension FanBaseEndpoint: EndpointType {
    var baseUrl: URL {
        return URL(string: APIConstants.baseURL)!
    }
    
    var body: [String : Any] {
        return [:]
    }
    
    var path: String {
        switch self {
        case .fanbase:
            return "/api/v1/fansbase"
        case .fanbaseKamu:
            return ""
        }
    }
    
    var method: HTTPMethod {
        return .get
    }
    
    
}
