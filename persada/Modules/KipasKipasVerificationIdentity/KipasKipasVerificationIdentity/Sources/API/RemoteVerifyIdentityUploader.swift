//
//  RemoteVerifyIdentityUploader.swift
//  KipasKipasVerificationIdentity
//
//  Created by DENAZMI on 07/06/24.
//

import Foundation
import KipasKipasNetworking

public class RemoteVerifyIdentityUploader: VerifyIdentityUploader {
    
    public typealias Result = VerifyIdentityUploader.Result
    
    private let baseURL: URL
    private let client: HTTPClient
    
    public init(baseURL: URL, client: HTTPClient) {
        self.baseURL = baseURL
        self.client = client
    }
    
    public func upload(_ request: VerifyIdentityUploadParam, completion: @escaping (Result) -> Void) {
        let request = enrich(baseURL, param: request)
        
        Task {
            do {
                let (data, response) = try await client.request(from: request)
                completion(RemoteVerifyIdentityUploader.map(data, from: response))
            } catch {
                completion(.failure(error))
            }
        }
    }
}

private extension RemoteVerifyIdentityUploader {
    private func enrich(_ baseURL: URL, param: VerifyIdentityUploadParam) -> URLRequest {
        return .url(baseURL)
            .path("/verification-identity/me")
            .method(.POST)
            .body(param)
            .build()
    }
}

private extension RemoteVerifyIdentityUploader {
    static func map(_ data: Data, from response: HTTPURLResponse) -> Result {
        do {
            let response = try Mapper<VerifyIdentityDefaultResponse>.map(data, from: response)
            return .success(response)
        } catch {
            return .failure(error)
        }
    }
}
