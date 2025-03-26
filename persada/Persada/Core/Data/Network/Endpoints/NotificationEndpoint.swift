//
//  NotificationEndpoint.swift
//  KipasKipas
//
//  Created by movan on 13/08/20.
//  Copyright © 2020 Muhammad Noor. All rights reserved.
//

import Foundation

enum NotificationEndpoint {
    case social(page: Int, size: Int)
    case transaction(page: Int, size: Int)
    case detailTransaction(id: String)
    case isReadNotification(type: String, id: String)
}

extension NotificationEndpoint: EndpointType {
    var baseUrl: URL {
        return URL(string: APIConstants.baseURL)!
    }
    
    var path: String {
        switch self {
        case .social:
            return "/notifications/social"
        case .transaction:
            return "/notifications/transaction"
        case .detailTransaction(let id):
            return "/orders/\(id)"
        case let .isReadNotification(type, id):
            return "/notifications/\(type)/\(id)"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .isReadNotification:
            return .patch
        default:
            return .get
        }
    }
    
    var header: [String : Any] {
        return [
            "Authorization" : "Bearer \(getToken() ?? "")",
            "Content-Type": "application/json"
        ]
    }
    
    var parameter: [String : Any] {
        switch self {
        case let .social(page, size), let .transaction(page, size):
            return [
                "page" : "\(page)",
                "size" : "\(size)"
            ]
        default:
            return [:]
        }
    }
    
}

