//
//  CallProfileEndpoint.swift
//  KipasKipasCall
//
//  Created by Rahmat Trinanda Pramudya Amar on 23/12/23.
//

import Foundation

public enum CallProfileEndpoint {
    case search(username: String)
    case data(_ userId: String)
    
    public func url(baseURL: URL) -> URLRequest {
        switch self {
        case let .search(username):
            var components = URLComponents()
            components.scheme = baseURL.scheme
            components.host = baseURL.host
            components.path = baseURL.path + "/search/account/username"
            components.queryItems = [
                URLQueryItem(name: "value", value: username)
            ]
            
            return URLRequest(url: components.url!)
            
        case let .data(userId):
            var components = URLComponents()
            components.scheme = baseURL.scheme
            components.host = baseURL.host
            components.path = baseURL.path + "/profile/\(userId)"
            
            return URLRequest(url: components.url!)
        }
    }
}
