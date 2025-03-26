//
//  RemoteUsernameValidator.swift
//  KipasKipas
//
//  Created by Muhammad Noor on 19/12/22.
//  Copyright © 2022 Koanba. All rights reserved.
//

import Foundation
import KipasKipasNetworking

final class RemoteUsernameValidator: UsernameValidator {
    private let url: URL
    private let client: HTTPClient
    
    public typealias Result = UsernameValidator.Result
    
    public init(url: URL, client: HTTPClient) {
        self.url = url
        self.client = client
    }
    
    func check(request: UsernameValidatorRequest, completion: @escaping (Result) -> Void) {
        let urlRequest = InputUserEndpoint.checkUsername(request: request).url(baseURL: url)

        Task {
            do {
                let (data, response) = try await client.request(from: urlRequest)
                completion(RemoteUsernameValidator.map(data, from: response))
            } catch {
                completion(.failure(KKNetworkError.connectivity))
            }
        }
    }
    
    private static func map(_ data: Data, from response: HTTPURLResponse) -> Result {
        do {
            let item = try UsernameValidatorItemMapper.map(data, from: response)
            return .success(item)
        } catch  {
            return .failure(error)
        }
    }
}
