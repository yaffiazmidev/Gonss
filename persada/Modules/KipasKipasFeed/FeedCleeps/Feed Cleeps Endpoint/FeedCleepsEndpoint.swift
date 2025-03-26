//
//  FeedCleepsEndpoint.swift
//  FeedCleeps
//
//  Created by PT.Koanba on 27/12/22.
//

import Foundation

public enum FeedCleepsEndpoint {
    case getFeed(request: GetFeedEndpointRequest)
    case getCleeps(request: GetCleepsEndpointRequest)
    case getProfileFeed(request: GetProfileEndpointRequest)
    case getTrending(request: GetTrendingEndpointRequest)
    case getHashtag(request: GetHashtagEndpointRequest)
    case getExplore(request: GetExploreEndpointRequest)
    case getFeedChannel(request: GetFeedChannelEndpointRequest)
    case getFeedSearch(request: GetFeedSearchEndpointRequest)
    case getFollowingFeed(request: GetFollowingEndpointRequest)
    
    public func url(baseURL: URL) -> URLRequest {
        switch self {
        case let .getFeed(request):
            var components = URLComponents()
            components.scheme = baseURL.scheme
            components.host = baseURL.host
            if request.isPublic {
                components.path = baseURL.path + "/public/feeds/post/home"
            } else {
                components.path = baseURL.path + "/feeds/post/home"
            }
            components.queryItems = [
                URLQueryItem(name: "page", value: "\(request.page)"),
                URLQueryItem(name: "size", value: "10"),
            ].compactMap { $0 }
            return URLRequest(url: components.url!)
            
        case let .getCleeps(request):
            var components = URLComponents()
            components.scheme = baseURL.scheme
            components.host = baseURL.host
            components.path = baseURL.path + "/feeds/channels"
            components.queryItems = [
                URLQueryItem(name: "code", value: "\(request.country.rawValue)"),
                URLQueryItem(name: "page", value: "\(request.page)"),
                URLQueryItem(name: "size", value: "10"),
//                URLQueryItem(name: "isTrending", value: "\(request.isTrending)"),
            ].compactMap { $0 }
            return URLRequest(url: components.url!)
            
        case let .getProfileFeed(request):
            var components = URLComponents()
            components.scheme = baseURL.scheme
            components.host = baseURL.host
            components.path = baseURL.path + "/profile/post/\(request.userID)"
            components.queryItems = [
                URLQueryItem(name: "page", value: "\(request.page)"),
                URLQueryItem(name: "size", value: "10"),
            ].compactMap { $0 }
            return URLRequest(url: components.url!)
            
        case let .getTrending(request):
            var components = URLComponents()
            components.scheme = baseURL.scheme
            components.host = baseURL.host
            components.path = baseURL.path + "/feeds/post/trending"
            components.queryItems = [
                URLQueryItem(name: "page", value: "\(request.page)"),
                URLQueryItem(name: "size", value: "10"),
            ].compactMap { $0 }
            return URLRequest(url: components.url!)
           
        case let .getHashtag(request):
            var components = URLComponents()
            components.scheme = baseURL.scheme
            components.host = baseURL.host
            components.path = baseURL.path + "/feeds/search/hashtag"
            components.queryItems = [
                URLQueryItem(name: "page", value: "\(request.page)"),
                URLQueryItem(name: "size", value: "10"),
                URLQueryItem(name: "value", value: "\(request.hashtag)"),
            ].compactMap { $0 }
            return URLRequest(url: components.url!)
            
        case let .getExplore(request):
            var components = URLComponents()
            components.scheme = baseURL.scheme
            components.host = baseURL.host
            if request.isPublic {
                components.path = baseURL.path + "/public/channels/general/posts"
            } else {
                components.path = baseURL.path + "/channels/general/posts"
            }
            components.queryItems = [
                URLQueryItem(name: "page", value: "\(request.page)"),
                URLQueryItem(name: "size", value: "10"),
            ].compactMap { $0 }
            return URLRequest(url: components.url!)
            
        case let .getFeedChannel(request):
            var components = URLComponents()
            components.scheme = baseURL.scheme
            components.host = baseURL.host
            if request.isPublic {
                components.path = baseURL.path + "/public/feeds/channel/\(request.channelId)"
            } else {
                components.path = baseURL.path + "/feeds/post/home"
            }
            components.queryItems = [
                URLQueryItem(name: "page", value: "\(request.page)"),
                URLQueryItem(name: "size", value: "10"),
            ].compactMap { $0 }
            return URLRequest(url: components.url!)
            
        case let .getFeedSearch(request):
            var components = URLComponents()
            components.scheme = baseURL.scheme
            components.host = baseURL.host
            components.path = baseURL.path + "/search/top"

            components.queryItems = [
                URLQueryItem(name: "page", value: "\(request.page)"),
                URLQueryItem(name: "size", value: "10"),
                URLQueryItem(name: "value", value: "\(request.searchText)"),
            ].compactMap { $0 }
            return URLRequest(url: components.url!)
            
        case let .getFollowingFeed(request):
            var components = URLComponents()
            components.scheme = baseURL.scheme
            components.host = baseURL.host
            components.path = baseURL.path + "/feeds/following"

            components.queryItems = [
                URLQueryItem(name: "page", value: "\(request.page)"),
                URLQueryItem(name: "size", value: "10")
            ].compactMap { $0 }
            return URLRequest(url: components.url!)
        }
        
        
    }
}
