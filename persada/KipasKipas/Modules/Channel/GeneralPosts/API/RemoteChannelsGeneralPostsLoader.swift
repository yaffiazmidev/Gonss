//
//  RemoteChannelsGeneralPostsLoader.swift
//  KipasKipas
//
//  Created by DENAZMI on 18/12/22.
//  Copyright © 2022 Koanba. All rights reserved.
//

import Foundation
import KipasKipasNetworking

class RemoteChannelsGeneralPostsLoader: ChannelsGeneralPostsLoader {
    
    private let url: URL
    private let client: HTTPClient
    
    typealias Result = ChannelsGeneralPostsLoader.Result
    
    init(url: URL, client: HTTPClient) {
        self.url = url
        self.client = client
    }
    
    func load(request: ChannelsGeneralPostsRequest, completion: @escaping (Result) -> Void) {
        let request = ChannelsGeneralPostsEndpoint.get(request: request).url(baseURL: url)
        
        Task {
            do {
                let (data, response) = try await client.request(from: request)
                completion(RemoteChannelsGeneralPostsLoader.map(data, response))
            } catch {
                completion(.failure(KKNetworkError.connectivity))
            }
        }
    }
    
    private static func map(_ data: Data, _ response: HTTPURLResponse) -> Result {
        do {
            let items = try RemoteChannelsGeneralPostsItemMapper.map(data, from: response)
            return .success(items)
        } catch {
            return .failure(error)
        }
    }
}
