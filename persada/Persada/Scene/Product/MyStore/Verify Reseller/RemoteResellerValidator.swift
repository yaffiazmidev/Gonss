//
//  RemoteResellerValidator.swift
//  KipasKipas
//
//  Created by Muhammad Noor on 26/02/23.
//  Copyright © 2023 Koanba. All rights reserved.
//

import Foundation
import KipasKipasNetworking

final class RemoteResellerValidator: ResellerValidator {
    private let url: URL
    private let client: HTTPClient
    
    public typealias Result = ResellerValidator.Result
    
    public init(url: URL, client: HTTPClient) {
        self.url = url
        self.client = client
    }
    
    func verify(completion: @escaping (Result) -> Void) {
        let urlRequest = ResellerValidatorEndpoint.verify.url(baseURL: url)

        Task {
            do {
                let (data, response) = try await client.request(from: urlRequest)
                completion(RemoteResellerValidator.map(data, from: response))
            } catch {
                completion(.failure(KKNetworkError.connectivity))
            }
        }
    }
    
    private static func map(_ data: Data, from response: HTTPURLResponse) -> Result {
        do {
            let item = try ResellerValidatorItemMapper.map(data, from: response)
            return .success(item)
        } catch  {
            return .failure(error)
        }
    }
}



