//
//  RemoteResellerProductConfirm.swift
//  KipasKipas
//
//  Created by Muhammad Noor on 06/03/23.
//  Copyright © 2023 Koanba. All rights reserved.
//

import Foundation
import KipasKipasNetworking

class RemoteResellerProductConfirm: ResellerProductConfirm {
    private let url : URL
    private let client: HTTPClient
  
    typealias Result = ResellerProductConfirm.Result
    
    init(url: URL, client: HTTPClient) {
        self.url = url
        self.client = client
    }
    
    func confirm(request: ResellerProductConfirmRequest, completion: @escaping (Result) -> Void) {
        let request = ResellerConfirmProductEndpoint.confirm(request: request).url(baseURL: url)
        
        Task {
            do {
                let (data, response) = try await client.request(from: request)
                completion(RemoteResellerProductConfirm.map(data, from: response))
            } catch {
                completion(.failure(KKNetworkError.connectivity))
            }
        }
    }
    
    private static func map(_ data: Data, from response: HTTPURLResponse) -> Result {
        do {
            let item = try ResellerDefaultMessageMapper.map(data, from: response)
            return .success(item)
        } catch {
            return .failure(error)
        }
    }
}
