//
//  RemoteResellerProductStopper.swift
//  KipasKipas
//
//  Created by Rahmat Trinanda Pramudya Amar on 03/03/23.
//  Copyright © 2023 Koanba. All rights reserved.
//

import Foundation
import KipasKipasNetworking

class RemoteResellerProductStopper: ResellerProductStopper {
    private let url : URL
    private let client: HTTPClient
  
    typealias Result = ResellerProductStopper.Result
    
    init(url: URL, client: HTTPClient) {
        self.url = url
        self.client = client
    }
    
    func stop(request: ResellerProductStopperRequest, completion: @escaping (Result) -> Void) {
        let request = ResellerEndpoint.stop(request: request).url(baseURL: url)
        
        Task {
            do {
                let (data, response) = try await client.request(from: request)
                completion(RemoteResellerProductStopper.map(data, from: response))
            } catch {
                completion(.failure(KKNetworkError.connectivity))
            }
        }
    }
    
    private static func map(_ data: Data, from response: HTTPURLResponse) -> Result {
        do {
            try ResellerDefaultMapper.map(data, from: response)
            return .success(())
        } catch {
            return .failure(error)
        }
    }
}
