//
//  RemoteDetailTransactionOrderLoader.swift
//  KipasKipas
//
//  Created by Rahmat Trinanda Pramudya Amar on 27/03/23.
//  Copyright © 2023 Koanba. All rights reserved.
//

import Foundation
import KipasKipasNetworking

class RemoteDetailTransactionOrderLoader: DetailTransactionOrderLoader {
    private let url : URL
    private let client: HTTPClient
  
    typealias Result = DetailTransactionOrderLoader.Result
    
    init(url: URL, client: HTTPClient) {
        self.url = url
        self.client = client
    }
    
    func load(request: DetailTransactionOrderLoaderRequest, completion: @escaping (Result) -> Void) {
        let request = DetailTransactionEndpoint.detail(request: request).url(baseURL: url)
        
        Task {
            do {
                let (data, response) = try await client.request(from: request)
                completion(RemoteDetailTransactionOrderLoader.map(data, from: response))
            } catch {
                completion(.failure(KKNetworkError.connectivity))
            }
        }
    }
    
    private static func map(_ data: Data, from response: HTTPURLResponse) -> Result {
        do {
            let data = try DetailTransactionOrderItemMapper.map(data, from: response)
            return .success(data)
        } catch {
            return .failure(error)
        }
    }
}


