//
//  HotnewsEndpoint.swift
//  FeedCleeps
//
//  Created by Rahmat Trinanda Pramudya Amar on 02/01/24.
//

import Foundation
import UIKit

public enum HotnewsEndpoint {
    case getProfileById(id: String)
    case getProfileByUsername(username: String)
    case followUser(id: String)
    case likeFeed(id: String, isLiking: Bool)
    case getFeedVideo(_ request: PagedFeedVideoLoaderRequest)
    case seenPost(id: String)
    case guestSeenPost(id: String)
    case getFeed(id: String, isLogin:Bool = true)
    case getSuggestFollowing(page: Int, size: Int)

    public func url(baseURL: URL) -> URLRequest {
        switch self {
        case let .getFeed(id,isLogin):
            var components = URLComponents()
            components.scheme = baseURL.scheme
            components.host = baseURL.host
            components.path = baseURL.path +  "/feeds/\(id)"
             
            var request = URLRequest(url: components.url!)
            if let uuid = UIDevice.current.identifierForVendor?.uuidString {
                request.setValue(uuid, forHTTPHeaderField: "deviceId")
            }
            return request

//            return URLRequest(url: components.url!)
        case let .getProfileById(id):
            var components = URLComponents()
            components.scheme = baseURL.scheme
            components.host = baseURL.host
            components.path = baseURL.path + "/profile/\(id)"

            return URLRequest(url: components.url!)

        case let .getProfileByUsername(username):
            var components = URLComponents()
            components.scheme = baseURL.scheme
            components.host = baseURL.host
            components.path = baseURL.path + "/profile/username"

            components.queryItems = [
                .init(name: "value", value: username)
            ].compactMap { $0 }

            return URLRequest(url: components.url!)

        case let .followUser(id):
            var components = URLComponents()
            components.scheme = baseURL.scheme
            components.host = baseURL.host
            components.path = baseURL.path + "/profile/\(id)/follow"

            var request = URLRequest(url: components.url!)
            request.httpMethod = "PATCH"

            return request

        case let .likeFeed(id, isLiking):
            var components = URLComponents()
            components.scheme = baseURL.scheme
            components.host = baseURL.host
            components.path = baseURL.path + "/likes/feed/\(id)"

            components.queryItems = [
                .init(name: "status", value: isLiking ? "like" : "unlike")
            ].compactMap { $0 }

            var request = URLRequest(url: components.url!)
            request.httpMethod = "PATCH"

            return request

        case let .seenPost(id):
            var components = URLComponents()
            components.scheme = baseURL.scheme
            components.host = baseURL.host
            components.path = baseURL.path + "/feeds/\(id)/seen"

            var request = URLRequest(url: components.url!)
            request.httpMethod = "PATCH"
            if let uuid = UIDevice.current.identifierForVendor?.uuidString {
                request.setValue(uuid, forHTTPHeaderField: "deviceId")
            }
            return request
        case let .guestSeenPost(id):
            var components = URLComponents()
            components.scheme = baseURL.scheme
            components.host = baseURL.host
            var path = baseURL.path
            let suffix = "/public"
            if path.hasSuffix(suffix) {
                path = String(path.dropLast(suffix.count))
            }
            components.path = path + "/feed/guest/view"
            var request = URLRequest(url: components.url!)
            request.httpMethod = "POST"
            if let uuid = UIDevice.current.identifierForVendor?.uuidString {
                request.setValue(uuid, forHTTPHeaderField: "deviceId")
            }
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            if let jsonData = try? JSONSerialization.data(withJSONObject: ["feedId": id], options: []) {
                request.httpBody = jsonData
            }
            return request
        case let .getFeedVideo(request):
            var components = URLComponents()
            components.scheme = baseURL.scheme
            components.host = baseURL.host
            components.path = baseURL.path + request.path
            
            var queryItems = components.queryItems ?? []
            
            switch request.feedType {
            case .hotNews:
                queryItems.append(URLQueryItem(name: "code", value: request.country.rawValue))
            case .searchTop:
                queryItems.append(URLQueryItem(name: "value", value: request.searchKeyword))
            default:
                break
            }
            
            queryItems.append(contentsOf: [
                .init(name: "page", value: "\(request.page)"),
                .init(name: "size", value: "\(request.size)"),
                .init(name: "sort", value: "createAt,desc")
            ])

            if let isVodAvailable = request.isVodAvailable {
                queryItems += [.init(name: "isVodAvailable", value: "\(isVodAvailable)")]
            }

            if let latitude = request.latitude, let longitude = request.longitude {
                queryItems += [
                    .init(name: "latitude", value: "\(latitude)"),
                    .init(name: "longitude", value: "\(longitude)")
                ]
            }

            if let isTrending = request.isTrending {
                queryItems += [.init(name: "isTrending", value: "\(isTrending)")]
            }

            if let provinceId = request.provinceId {
                queryItems += [.init(name: "provinceId", value: provinceId)]
            }

            if let categoryId = request.categoryId {
                queryItems += [.init(name: "categoryId", value: categoryId)]
            }
            
            if let mediaType = request.mediaType {
                queryItems += [.init(name: "mediaType", value: mediaType.rawValue)]
            }
            components.queryItems = queryItems.compactMap { $0 }

            var urlRequest = URLRequest(url: components.url!)

            if let deviceId = request.deviceId {
                urlRequest.setValue(deviceId, forHTTPHeaderField: "deviceId")
            }
            if let uuid = UIDevice.current.identifierForVendor?.uuidString {
                urlRequest.setValue(uuid, forHTTPHeaderField: "deviceId")
            }
            return urlRequest

        case let .getSuggestFollowing(page, size):
            var components = URLComponents()
            components.scheme = baseURL.scheme
            components.host = baseURL.host
            components.path = baseURL.path + "/feeds/post/following/suggest-users"
            components.queryItems = [
                .init(name: "size", value: "\(size)"),
                .init(name: "page", value: "\(page)"),
                .init(name: "direction", value: "DESC"),
                .init(name: "sort", value: "createAt")
            ].compactMap { $0 }
            
            var request = URLRequest(url: components.url!)
            request.httpMethod = "GET"
            
            return request
            
        }
    }
}
