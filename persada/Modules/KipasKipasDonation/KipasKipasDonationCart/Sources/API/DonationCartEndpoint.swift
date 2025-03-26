//
//  DonationCartEndpoint.swift
//  KipasKipasDonationCart
//
//  Created by Rahmat Trinanda Pramudya Amar on 21/02/24.
//

import Foundation

// MARK: - Param Order
public struct DonationCartOrderParam: Encodable {
    
    public let cartDonations: [DonationCartOrderItemParam]
    public let totalAmount: Int
    
    public init(cartDonations: [DonationCartOrderItemParam], totalAmount: Int) {
        self.cartDonations = cartDonations
        self.totalAmount = totalAmount
    }
}

public struct DonationCartOrderItemParam: Encodable {
    public let amount: Int
    public let orderDetail: DonationCartOrderDetailParam
    
    public init(amount: Int, orderDetail: DonationCartOrderDetailParam) {
        self.amount = amount
        self.orderDetail = orderDetail
    }
}

public struct DonationCartOrderDetailParam: Encodable {
    public let feedId: String
    
    public init(feedId: String) {
        self.feedId = feedId
    }
}

// MARK: - Endpoint
public enum DonationCartEndpoint {
    case orderExist
    case order(DonationCartOrderParam)
    case orderContinue(DonationCartOrderParam)
    case orderDetail(_ id: String)
    
    public func url(baseURL: URL) -> URLRequest {
        switch self {
        case .orderExist:
            var components = URLComponents()
            components.scheme = baseURL.scheme
            components.host = baseURL.host
            components.path = baseURL.path + "/orders/me"
            
            components.queryItems = [
                .init(name: "type", value: "donation")
            ].compactMap { $0 }
            
            return URLRequest(url: components.url!)
            
        case let .order(request):
            var components = URLComponents()
            components.scheme = baseURL.scheme
            components.host = baseURL.host
            components.path = baseURL.path + "/orders/cart-donation"
            
            var urlRequest = URLRequest(url: components.url!)
            urlRequest.httpMethod = "POST"
            urlRequest.httpBody = try? JSONEncoder().encode(request)
            
            return urlRequest
            
        case let .orderContinue(request):
            var components = URLComponents()
            components.scheme = baseURL.scheme
            components.host = baseURL.host
            components.path = baseURL.path + "/orders/cart-donation/continue"
            
            var urlRequest = URLRequest(url: components.url!)
            urlRequest.httpMethod = "POST"
            urlRequest.httpBody = try? JSONEncoder().encode(request)
            
            return urlRequest
            
        case let .orderDetail(id):
            var components = URLComponents()
            components.scheme = baseURL.scheme
            components.host = baseURL.host
            components.path = baseURL.path + "/orders/\(id)"
            
            return URLRequest(url: components.url!)
            
        }
    }
}
