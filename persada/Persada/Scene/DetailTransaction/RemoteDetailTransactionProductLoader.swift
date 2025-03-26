//
//  RemoteDetailTransactionProductLoader.swift
//  KipasKipas
//
//  Created by Rahmat Trinanda Pramudya Amar on 24/03/23.
//  Copyright © 2023 Koanba. All rights reserved.
//

import Foundation
import KipasKipasNetworking

class RemoteDetailTransactionProductLoader: DetailTransactionProductLoader {
    private let url : URL
    private let client: HTTPClient
  
    typealias Result = DetailTransactionProductLoader.Result
    
    init(url: URL, client: HTTPClient) {
        self.url = url
        self.client = client
    }
    
    func load(request: DetailTransactionProductLoaderRequest, completion: @escaping (Result) -> Void) {
        let request = DetailTransactionEndpoint.product(request: request).url(baseURL: url)
        
        Task {
            do {
                let (data, response) = try await client.request(from: request)
                completion(RemoteDetailTransactionProductLoader.map(data, from: response))
            } catch {
                completion(.failure(KKNetworkError.connectivity))
            }
        }
    }
    
    private static func map(_ data: Data, from response: HTTPURLResponse) -> Result {
        do {
            let data = try DetailTransactionProductItemMapper.map(data, from: response)
            return .success(data)
        } catch {
            return .failure(error)
        }
    }
}

