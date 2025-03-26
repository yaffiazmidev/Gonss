//
//  RemoteProductDetailLoader.swift
//  KipasKipas
//
//  Created by Muhammad Noor on 10/02/23.
//  Copyright © 2023 Koanba. All rights reserved.
//

import Foundation
import KipasKipasNetworking

class RemoteProductDetailLoader: ProductDetailLoader {
    private let url : URL
    private let client: HTTPClient
    private let isPublic: Bool
  
    typealias Result = ProductDetailLoader.Result
    
    init(url: URL, client: HTTPClient, isPublic: Bool) {
        self.url = url
        self.client = client
        self.isPublic = isPublic
    }
    
    func load(request: ProductDetailRequest, completion: @escaping (Result) -> Void) {
        let urlRequest = ProductDetailEndpoint.detail(request: request, isPublic: isPublic).url(baseURL: url)
        
        Task {
            do {
                let (data, response) = try await client.request(from: urlRequest)
                completion(RemoteProductDetailLoader.map(data, from: response))
            } catch {
                completion(.failure(KKNetworkError.connectivity))
            }
        }
    }
    
    private static func map(_ data: Data, from response: HTTPURLResponse) -> Result {
        do {
            let item = try ProductDetailItemMapper.map(data, from: response)
            return .success(item)
        } catch {
            return .failure(error)
        }
    }
}
