//
//  DetailTransactionEndpoint.swift
//  KipasKipas
//
//  Created by Rahmat Trinanda Pramudya Amar on 24/03/23.
//  Copyright © 2023 Koanba. All rights reserved.
//

import Foundation

enum DetailTransactionEndpoint {
    case product(request: DetailTransactionProductLoaderRequest)
    case detail(request: DetailTransactionOrderLoaderRequest)
    
    func url(baseURL: URL) -> URLRequest {
        switch self {
        case let .product(request):
            var url = baseURL
            url.appendPathComponent("products")
            url.appendPathComponent(request.id)
            
            return URLRequest(url: url)
            
        case let .detail(request):
            var url = baseURL
            url.appendPathComponent("orders")
            url.appendPathComponent(request.id)
            
            return URLRequest(url: url)
        }
    }
}
