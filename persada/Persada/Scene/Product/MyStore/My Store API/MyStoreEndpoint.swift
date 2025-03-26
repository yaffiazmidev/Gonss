//
//  MyStoreEndpoint.swift
//  KipasKipas
//
//  Created by Rahmat Trinanda Pramudya Amar on 10/02/23.
//  Copyright © 2023 Koanba. All rights reserved.
//

import Foundation

enum MyStoreEndpoint {
    case balance
    case address(request: MyStoreAddressLoaderRequest)
    
    func url(baseURL: URL) -> URLRequest {
        switch self {
        case  .balance:
            var url = baseURL
            url.appendPathComponent("balance")
            url.appendPathComponent("info")
            
            return URLRequest(url: url)
            
        case let .address(request):
            var url = baseURL
            url.appendPathComponent("addresses")
            url.appendPathComponent("account")
            
            var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false)
            urlComponents?.queryItems = [
                URLQueryItem(name: "type", value: "\(request.type)")
            ]
            
            return URLRequest(url: urlComponents?.url ?? url)
        }
    }
}
