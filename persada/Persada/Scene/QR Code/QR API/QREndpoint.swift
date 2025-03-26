//
//  QREndpoint.swift
//  KipasKipas
//
//  Created by Rahmat Trinanda Pramudya Amar on 05/04/23.
//  Copyright © 2023 Koanba. All rights reserved.
//

import Foundation

enum QREndpoint {
    case product(request: QRProductLoaderRequest)
    case donation(request: QRDonationLoaderRequest)
    
    func url(baseURL: URL) -> URLRequest {
        switch self {
        case let .product(request):
            var url = baseURL
            
            if request.isPublic {
                url.appendPathComponent("public")
            }
            url.appendPathComponent("products")
            url.appendPathComponent(request.id)
            
            return URLRequest(url: url)
            
        case let .donation(request):
            var url = baseURL
            
            if request.isPublic {
                url.appendPathComponent("public")
            }
            url.appendPathComponent("donations")
            url.appendPathComponent(request.id)
            
            return URLRequest(url: url)
            
        }
    }
}
