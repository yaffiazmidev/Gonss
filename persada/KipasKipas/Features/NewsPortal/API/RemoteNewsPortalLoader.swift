//
//  RemoteNewsPortalLoader.swift
//  KipasKipas
//
//  Created by Rahmat Trinanda Pramudya Amar on 07/02/24.
//  Copyright © 2024 Koanba. All rights reserved.
//

import Foundation
import KipasKipasNetworking

class RemoteNewsPortalLoader: NewsPortalLoader {
    private let url : URL
    private let client: HTTPClient
    
    typealias Result = NewsPortalLoader.Result
    
    init(url: URL, client: HTTPClient) {
        self.url = url
        self.client = client
    }
    
    func load(completion: @escaping (Result) -> Void) {
        let request = NewsPortalEndpoint.data.url(baseURL: url)
        
        Task {
            do {
                let (data, response) = try await client.request(from: request)
                completion(RemoteNewsPortalLoader.map(data, from: response))
            } catch {
                completion(.failure(KKNetworkError.connectivity))
            }
        }
    }
    
    
    private static func map(_ data: Data, from response: HTTPURLResponse) -> Result {
        do {
            let items = try NewsPortalMapper.map(data, from: response)
            return .success(items)
        } catch {
            return .failure(error)
        }
    }
}
