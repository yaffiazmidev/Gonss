//
//  RemoteChannelsLoader.swift
//  KipasKipas
//
//  Created by DENAZMI on 19/12/22.
//  Copyright © 2022 Koanba. All rights reserved.
//

import Foundation
import KipasKipasNetworking

class RemoteChannelsLoader: ChannelsLoader {
    
    private let url: URL
    private let client: HTTPClient
    
    public typealias Result = ChannelsLoader.Result
    
    public init(url: URL, client: HTTPClient) {
        self.url = url
        self.client = client
    }
    
    func load(request: ChannelsRequest, completion: @escaping (Result) -> Void) {
        let request = ChannelsEndpoint.get(request: request).url(baseURL: url)
        
        Task {
            do {
                let (data, response) = try await client.request(from: request)
                completion(RemoteChannelsLoader.map(data, response: response))
            } catch {
                completion(.failure(KKNetworkError.connectivity))
            }
        }
    }
    
    private static func map(_ data: Data, response: HTTPURLResponse) -> Result {
        do {
            let item = try RemoteChannelsItemMapper.map(data, from: response)
            return .success(item)
        } catch {
            return .failure(error)
        }
    }
}
