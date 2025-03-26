//
//  EndpointType.swift
//  Persada
//
//  Created by Muhammad Noor on 05/04/20.
//  Copyright © 2020 Muhammad Noor. All rights reserved.
//

import Foundation

protocol EndpointType {

    var baseUrl: URL { get }
    var path: String { get }
    var parameter: [String: Any] { get }
    var header: [String: Any] { get }
    var method: HTTPMethod { get }
    var body: [String: Any] { get }
}

extension EndpointType {

    var header: [String: Any] {
        return [:]
    }

    var parameter: [String: Any] {
        return [:]
    }
    
    var body: [String: Any] {
        return [:]
    }

}

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case delete = "DELETE"
    case put = "PUT"
    case patch = "PATCH"
}
