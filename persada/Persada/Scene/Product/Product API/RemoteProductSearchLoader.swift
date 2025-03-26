//
//  RemoteProductSearchLoader.swift
//  KipasKipas
//
//  Created by Rahmat Trinanda Pramudya Amar on 09/02/23.
//  Copyright © 2023 Koanba. All rights reserved.
//

import Foundation
import KipasKipasNetworking

class RemoteProductSearchLoader: ProductSearchLoader {
    private let url : URL
    private let client: HTTPClient
  
    typealias Result = ProductSearchLoader.Result
    
    init(url: URL, client: HTTPClient) {
        self.url = url
        self.client = client
    }
    
    func load(request: ProductSearchLoaderRequest, completion: @escaping (Result) -> Void) {
        let request = ProductItemEndpoint.search(request: request).url(baseURL: url)
        
        Task {
            do {
                let (data, response) = try await client.request(from: request)
                completion(RemoteProductSearchLoader.map(data, from: response))
            } catch {
                completion(.failure(KKNetworkError.connectivity))
            }
        }
    }
    
    private static func map(_ data: Data, from response: HTTPURLResponse) -> Result {
        do {
            let items = try ProductArrayMapper.map(data, from: response)
            return .success(items)
        } catch {
            return .failure(error)
        }
    }
}

