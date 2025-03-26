//
//  RemoteCreateUser.swift
//  KipasKipas
//
//  Created by Muhammad Noor on 19/12/22.
//  Copyright © 2022 Koanba. All rights reserved.
//

import Foundation
import KipasKipasNetworking

final class RemoteCreateUser: CreateUser {
    private let url: URL
    private let client: HTTPClient
    
    public typealias Result = CreateUser.Result
    
    public init(url: URL, client: HTTPClient) {
        self.url = url
        self.client = client
    }

    func create(request: CreateUserRequest, completion: @escaping (Result) -> Void) {
        let urlRequest = InputUserEndpoint.create(request: request).url(baseURL: url)
        
        Task {
            do {
                let (data, response) = try await client.request(from: urlRequest)
                completion(RemoteCreateUser.map(data, from: response))
            } catch {
                completion(.failure(KKNetworkError.connectivity))
            }
        }
    }
    
    private static func map(_ data: Data, from response: HTTPURLResponse) -> Result {
        do {
            let item = try CreateUserItemMapper.map(data, from: response)
            return .success(item)
        } catch  {
            return .failure(error)
        }
    }
}


