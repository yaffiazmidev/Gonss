//
//  RemoteResellerProductLoader.swift
//  KipasKipas
//
//  Created by Muhammad Noor on 10/03/23.
//  Copyright © 2023 Koanba. All rights reserved.
//

import Foundation
import KipasKipasNetworking

final class RemoteResellerProductLoader: ResellerProductLoader {
    private let url: URL
    private let client: HTTPClient
    
    typealias Result = ResellerProductLoader.Result
    
    init(url: URL, client: HTTPClient) {
        self.url = url
        self.client = client
    }
    
    func load(request: ResellerProductRequest, completion: @escaping (Result) -> Void) {
        let urlRequest = ResellerConfirmProductEndpoint.getProduct(request: request).url(baseURL: url)
        
        Task {
            do {
                let (data, response) = try await client.request(from: urlRequest)
                completion(RemoteResellerProductLoader.map(data, from: response))
            } catch {
                completion(.failure(KKNetworkError.connectivity))
            }
        }
    }
    
    private static func map(_ data: Data, from response: HTTPURLResponse) -> Result {
        do {
            let item = try ResellerProductItemMapper.map(data, from: response)
            return .success(item)
        } catch {
            return .failure(error)
        }
    }
}
