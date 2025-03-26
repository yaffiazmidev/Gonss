//
//  HashtagEndpoint.swift
//  KipasKipas
//
//  Created by Azam Mukhtar on 09/04/21.
//  Copyright © 2021 Koanba. All rights reserved.
//

import Foundation

enum OrderEndpoint {
    case getDelayedOrder
    case checkoutOrder(order: CheckoutOrderRequest)
    case checkoutOrderContinue(order: CheckoutOrderRequest)
}

extension OrderEndpoint : EndpointType {
    
    var baseUrl: URL {
        return URL(string: APIConstants.baseURL)!
    }
    
    var path: String {
        switch self {
        case .getDelayedOrder:
            return "/orders/me"
        case .checkoutOrder(_):
            return "/orders"
        case .checkoutOrderContinue(_):
            return "/orders/continue"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .checkoutOrder(_), .checkoutOrderContinue(_):
            return .post
        default:
            return .get
        }
    }
    
    var header: [String : String] {
        return [
            "Authorization" : "Bearer \(getToken() ?? "")",
            "Content-Type" : "application/json",
        ]
    }
    
    
    var parameter: [String : Any] {
        switch self {
        case .checkoutOrder(let order):
            return toDictionary(object: order)
        case .checkoutOrderContinue(let order):
            return toDictionary(object: order)
        case .getDelayedOrder:
            return [:]
        }
    }
    
    
    func toDictionary(object: CheckoutOrderRequest) -> [String:Any] {
        let mirror = Mirror(reflecting: object)
        let dict = Dictionary(uniqueKeysWithValues: mirror.children.lazy.map({ (label:String?, value:Any) -> (String, Any)? in
            guard let label = label else { return nil }
            return (label, value)
        }).compactMap { $0 })
        return dict
    }
//    var toDictionary : [String:Any] {
//            let mirror = Mirror(reflecting: self)
//            let dict = Dictionary(uniqueKeysWithValues: mirror.children.lazy.map({ (label:String?, value:Any) -> (String, Any)? in
//                guard let label = label else { return nil }
//                return (label, value)
//            }).compactMap { $0 })
//            return dict
//        }
}
