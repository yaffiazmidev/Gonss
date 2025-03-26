//
//  LocationDonationLoader.swift.swift
//  KipasKipas
//
//  Created by Muhammad Noor on 03/08/23.
//  Copyright © 2023 Koanba. All rights reserved.
//

import Foundation
import KipasKipasNetworking

struct LocationDonationRequest {
    let size: Int
}

protocol LocationDonationLoader {
    typealias Result = Swift.Result<[LocationDonationItem], Error>
    func load(request: LocationDonationRequest, completion: @escaping (Result) -> Void)
}

struct LocationDonationItem: Codable, Equatable {
    let id, name, code: String
}

enum LocationDonationEndpoint {
    case get(request: LocationDonationRequest)
    
    func url(baseURL: URL) -> URLRequest {
        switch self {
        case let .get(request):
            var components = URLComponents()
            components.scheme = baseURL.scheme
            components.host = baseURL.host
            components.path = baseURL.path + "/areas/province"
            
            components.queryItems = [
                URLQueryItem(name: "size", value: "\(request.size)"),
            ].compactMap { $0 }
            
            var urlRequest = URLRequest(url: components.url!)
            urlRequest.httpMethod = "GET"
            return urlRequest
        }
    }
}
