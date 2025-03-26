//
//  RemoteUserSellerLoader.swift
//  KipasKipas
//
//  Created by Muhammad Noor on 07/03/23.
//  Copyright © 2023 Koanba. All rights reserved.
//

import Foundation
import KipasKipasNetworking

final class RemoteUserSellerLoader: UserSellerLoader {
    private let url: URL
    private let client: HTTPClient
    
    public typealias Result = UserSellerLoader.Result
    
    public init(url: URL, client: HTTPClient) {
        self.url = url
        self.client = client
    }
    
    func load(request: UserSellerRequest, completion: @escaping (Result) -> Void) {
        let urlRequest = ResellerConfirmProductEndpoint.get(request: request).url(baseURL: url)

        Task {
            do {
                let (data, response) = try await client.request(from: urlRequest)
                completion(RemoteUserSellerLoader.map(data, from: response))
            } catch {
                completion(.failure(KKNetworkError.connectivity))
            }
        }
    }
    
    private static func map(_ data: Data, from response: HTTPURLResponse) -> Result {
        do {
            let item = try UserSellerItemMapper.map(data, from: response)
            return .success(item)
        } catch  {
            return .failure(error)
        }
    }
}
