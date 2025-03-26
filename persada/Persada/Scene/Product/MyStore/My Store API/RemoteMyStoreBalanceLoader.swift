//
//  RemoteMyStoreBalanceLoader.swift
//  KipasKipas
//
//  Created by Rahmat Trinanda Pramudya Amar on 10/02/23.
//  Copyright © 2023 Koanba. All rights reserved.
//

import Foundation
import KipasKipasNetworking

class RemoteMyStoreBalanceLoader: MyStoreBalanceLoader{
    private let url : URL
    private let client: HTTPClient
  
    typealias Result = MyStoreBalanceLoader.Result
    
    init(url: URL, client: HTTPClient) {
        self.url = url
        self.client = client
    }
    
    func load(completion: @escaping (Result) -> Void) {
        let request = MyStoreEndpoint.balance.url(baseURL: url)
        
        Task {
            do {
                let (data, response) = try await client.request(from: request)
                completion(RemoteMyStoreBalanceLoader.map(data, from: response))
            } catch {
                completion(.failure(KKNetworkError.connectivity))
            }
        }
    }
    
    private static func map(_ data: Data, from response: HTTPURLResponse) -> Result {
        do {
            let items = try MyStoreBalanceMapper.map(data, from: response)
            return .success(items)
        } catch {
            return .failure(error)
        }
    }
}
