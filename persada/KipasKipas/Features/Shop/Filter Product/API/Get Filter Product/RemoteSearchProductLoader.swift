//
//  RemoteFilterProductLoader.swift
//  KipasKipas
//
//  Created by Muhammad Noor on 20/01/23.
//  Copyright © 2023 Koanba. All rights reserved.
//

import Foundation
import KipasKipasNetworking

class RemoteFilterProductLoader: FilterProductLoader {

    private let url: URL
    private let client: HTTPClient
    private let isPublic: Bool
    
    public typealias Result = FilterProductLoader.Result
    
    public init(url: URL, client: HTTPClient, isPublic: Bool) {
        self.url = url
        self.client = client
        self.isPublic = isPublic
    }
    
    func load(request: FilterProductRequest, completion: @escaping (Result) -> Void) {
        let urlRequest = FilterProductEndpoint.get(request: request, isPublic: isPublic).url(baseURL: url)
        
        Task {
            do {
                let (data, response) = try await client.request(from: urlRequest)
                completion(RemoteFilterProductLoader.map(data, from: response))
            } catch {
                completion(.failure(KKNetworkError.connectivity))
            }
        }
    }
    
    private static func map(_ data: Data, from response: HTTPURLResponse) -> Result {
        do {
            let items = try FilterProductItemMapper.map(data, from: response)
            return .success(items)
        } catch {
            return .failure(error)
        }
    }
}
