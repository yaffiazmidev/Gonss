//
//  RemoteChannelDetailLoader.swift
//  KipasKipas
//
//  Created by DENAZMI on 19/12/22.
//  Copyright © 2022 Koanba. All rights reserved.
//

import Foundation
import KipasKipasNetworking

class RemoteChannelDetailLoader: ChannelDetailLoader {
    
    private let url: URL
    private let client: HTTPClient
    
    public typealias Result = ChannelDetailLoader.Result
    
    public init(url: URL, client: HTTPClient) {
        self.url = url
        self.client = client
    }
    
    func load(request: ChannelDetailRequest, completion: @escaping (Result) -> Void) {
        let request = ChannelDetailEndpoint.get(request: request).url(baseURL: url)
        
        Task {
            do {
                let (data, response) = try await client.request(from: request)
                completion(RemoteChannelDetailLoader.map(data, response))
            } catch {
                completion(.failure(KKNetworkError.connectivity))
            }
        }
    }
    
    private static func map(_ data: Data, _ response: HTTPURLResponse) -> Result {
        do {
            let item = try RemoteChannelDetailItemMapper.map(data, response)
            return .success(item)
        } catch {
            return .failure(error)
        }
    }
}
