import Foundation

public enum LiveStreamProfileEndpoint {
    case profileByUserId(_ userId: String)
    case follow(_ userId: String)
    case unfollow(_ userId: String)
    
    public func url(baseURL: URL) -> URLRequest {
        switch self {
        case let .profileByUserId(userId):
            var components = URLComponents()
            components.scheme = baseURL.scheme
            components.host = baseURL.host
            components.path = baseURL.path + "/profile/\(userId)"
            
            return URLRequest(url: components.url!)
            
        case let .follow(userId):
            var components = URLComponents()
            components.scheme = baseURL.scheme
            components.host = baseURL.host
            components.path = baseURL.path + "/profile/\(userId)/follow"
            
            var request = URLRequest(url: components.url!)
            request.httpMethod = "PATCH"
            
            return request
        case let .unfollow(userId):
            var components = URLComponents()
            components.scheme = baseURL.scheme
            components.host = baseURL.host
            components.path = baseURL.path + "/profile/\(userId)/unfollow"
            
            var request = URLRequest(url: components.url!)
            request.httpMethod = "PATCH"
            
            return request 
        }
    }
}
