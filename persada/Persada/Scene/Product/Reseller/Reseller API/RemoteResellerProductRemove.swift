//
//  RemoteResellerProductRemove.swift
//  KipasKipas
//
//  Created by Muhammad Noor on 28/02/23.
//  Copyright © 2023 Koanba. All rights reserved.
//

import Foundation
import KipasKipasNetworking

class RemoteResellerProductRemove: ResellerProductRemove {
    private let url : URL
    private let client: HTTPClient
  
    typealias Result = ResellerProductRemove.Result
    
    init(url: URL, client: HTTPClient) {
        self.url = url
        self.client = client
    }
    
    func remove(request: ResellerProductRemoveRequest, completion: @escaping (Result) -> Void) {
        let request = ResellerEndpoint.remove(request: request).url(baseURL: url)
        
        Task {
            do {
                let (data, response) = try await client.request(from: request)
                completion(RemoteResellerProductRemove.map(data, from: response))
            } catch {
                completion(.failure(KKNetworkError.connectivity))
            }
        }
    }
    
    private static func map(_ data: Data, from response: HTTPURLResponse) -> Result {
        do {
            let item = try ResellerDefaultMessageMapper.map(data, from: response)
            return .success(item.message)
        } catch {
            return .failure(error)
        }
    }
}
