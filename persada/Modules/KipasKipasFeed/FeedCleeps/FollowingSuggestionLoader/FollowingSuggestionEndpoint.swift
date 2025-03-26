//
//  FollowingSuggestionEndpoint.swift
//  FeedCleeps
//
//  Created by DENAZMI on 03/12/22.
//

import Foundation

enum FollowingSuggestionEndpoint {
    case get(request: PagedFollowingSuggestionLoaderRequest)
    
    func url(baseURL: URL) -> URLRequest {
        switch self {
        case let .get(request):
            var components = URLComponents()
            components.scheme = baseURL.scheme
            components.host = baseURL.host
            components.path = baseURL.path + "/feeds/post/following/suggest-users"
            components.queryItems = [
                URLQueryItem(name: "page", value: "\(request.page)"),
                URLQueryItem(name: "size", value: "3"),
            ].compactMap { $0 }
            
            var request = URLRequest(url: components.url!)
            request.httpMethod = "GET"
            return request
        }
    }
}
