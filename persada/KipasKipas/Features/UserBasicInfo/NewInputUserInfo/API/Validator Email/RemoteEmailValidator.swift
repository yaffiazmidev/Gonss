//
//  RemoteValidateUserWithEmailChecker.swift
//  KipasKipas
//
//  Created by Muhammad Noor on 19/12/22.
//  Copyright © 2022 Koanba. All rights reserved.
//

import Foundation
import KipasKipasNetworking

final class RemoteEmailValidator: EmailValidator {
    private let url: URL
    private let client: HTTPClient
    
    public typealias Result = EmailValidator.Result
    
    public init(url: URL, client: HTTPClient) {
        self.url = url
        self.client = client
    }

    func check(request: EmailValidatorRequest, completion: @escaping (Result) -> Void) {
        let urlRequest = InputUserEndpoint.checkEmail(request: request).url(baseURL: url)
        
        Task {
            do {
                let (data, response) = try await client.request(from: urlRequest)
                completion(RemoteEmailValidator.map(data, from: response))
            } catch {
                completion(.failure(KKNetworkError.connectivity))
            }
        }
    }
    
    private static func map(_ data: Data, from response: HTTPURLResponse) -> Result {
        do {
            let item = try EmailValidatorItemMapper.map(data, from: response)
            return .success(item)
        } catch  {
            return .failure(error)
        }
    }
}
