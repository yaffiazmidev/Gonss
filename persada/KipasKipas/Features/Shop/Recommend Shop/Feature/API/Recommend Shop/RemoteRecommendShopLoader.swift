//
//  RemoteRecommendShopLoader.swift
//  KipasKipas
//
//  Created by Muhammad Noor on 19/01/23.
//  Copyright © 2023 Koanba. All rights reserved.
//

import Foundation
import KipasKipasNetworking

class RemoteRecommendShopLoader: RecommendShopLoader {
    private let url: URL
    private let client: HTTPClient
    private let isPublic: Bool
    
    public typealias Result = RecommendShopLoader.Result
    
    public init(url: URL, client: HTTPClient, isPublic: Bool) {
        self.url = url
        self.client = client
        self.isPublic = isPublic
    }
    
    func load(completion: @escaping (Result) -> Void) {
        let urlRequest = RecommendShopEndpoint.get(isPublic: isPublic).url(baseURL: url)
        
        Task {
            do {
                let (data, response) = try await client.request(from: urlRequest)
                completion(RemoteRecommendShopLoader.map(data, from: response))
            } catch {
                completion(.failure(KKNetworkError.connectivity))
            }
        }
    }
    
    private static func map(_ data: Data, from response: HTTPURLResponse) -> Result {
        do {
            let items = try RecommendShopItemMapper.map(data, from: response)
            return .success(items)
        } catch {
            return .failure(error)
        }
    }
}
