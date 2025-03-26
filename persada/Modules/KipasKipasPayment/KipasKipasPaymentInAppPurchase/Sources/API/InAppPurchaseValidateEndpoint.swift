//
//  InAppPurchaseValidateEndpoint.swift
//  KipasKipasPaymentInAppPurchase
//
//  Created by Rahmat Trinanda Pramudya Amar on 17/10/23.
//

import Foundation

enum InAppPurchaseValidateEndpoint {
    case coin(request: CoinInAppPurchaseValidatorRequest)
    
    public func url(baseURL: URL) -> URLRequest {
        switch self {
        case let .coin(request):
            var url = baseURL
            
            url.appendPathComponent("coin/purchase-apple")
            
            var req = URLRequest(url: url)
            req.httpMethod = "POST"
            let bodyRequest = try! JSONEncoder().encode(request)
            req.httpBody = bodyRequest
            
            return req
        }
    }
}
