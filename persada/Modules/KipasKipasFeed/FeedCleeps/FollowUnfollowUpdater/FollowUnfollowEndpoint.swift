//
//  FollowUnfollowEndpoint.swift
//  FeedCleeps
//
//  Created by DENAZMI on 05/12/22.
//

import Foundation

enum FollowUnfollowEndpoint {
    case update(request: FollowUnfollowUpdaterRequest)
    
    func url(baseURL: URL) -> URLRequest {
        switch self {
        case let .update(request):
            var components = URLComponents()
            components.scheme = baseURL.scheme
            components.host = baseURL.host
            
            let updateStatus = request.isFollow ? "unfollow" : "follow"
            components.path = baseURL.path + "/profile/\(request.id)/\(updateStatus)"
            
            var request = URLRequest(url: components.url!)
            request.httpMethod = "PATCH"
            return request
        }
    }
}
