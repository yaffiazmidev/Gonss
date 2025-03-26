//
//  RemoteChannelsFollowingLoader.swift
//  KipasKipas
//
//  Created by DENAZMI on 21/12/22.
//  Copyright © 2022 Koanba. All rights reserved.
//

import Foundation
import KipasKipasNetworking

class RemoteChannelsFollowingLoader: ChannelsFollowingLoader {
    
    private let url: URL
    private let client: HTTPClient
    
    public typealias Result = ChannelsFollowingLoader.Result
    
    public init(url: URL, client: HTTPClient) {
        self.url = url
        self.client = client
    }
    
    func load(request: ChannelsFollowingRequest, completion: @escaping (Result) -> Void) {
        let urlRequest = ChannelsFollowingEndpoint.get(request: request).url(baseURL: url)
        
        Task {
            do {
                let (data, response) = try await client.request(from: urlRequest)
                completion(RemoteChannelsFollowingLoader.map(data, response))
            } catch {
                completion(.failure(KKNetworkError.connectivity))
            }
        }
    }
    
    private static func map(_ data: Data, _ response: HTTPURLResponse) -> Result {
        do {
            let item = try RemoteChannelsFollowingItemMapper.map(data, from: response)
            return .success(item)
        } catch {
            return .failure(error)
        }
    }
}

