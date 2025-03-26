//
//  RemoteFeedbackChecker.swift
//  KipasKipas
//
//  Created by PT.Koanba on 08/12/22.
//  Copyright © 2022 Koanba. All rights reserved.
//

import Foundation
import KipasKipasNetworking

class RemoteFeedbackChecker: FeedbackChecker {
    private let url : URL
    private let client: HTTPClient
        
    public typealias Result = FeedbackChecker.Result
    
    public init(url: URL, client: HTTPClient) {
        self.url = url
        self.client = client
    }
    
    func check(completion: @escaping (Result) -> Void) {
        let request = FeedbackCheckerEndpoint.check.url(baseURL: url)
        
        Task {
            do {
                let (data, response) = try await client.request(from: request)
                completion(RemoteFeedbackChecker.map(data, from: response))
            } catch {
                completion(.failure(KKNetworkError.connectivity))
            }
        }
    }
    
    private static func map(_ data: Data, from response: HTTPURLResponse) -> Result {
        do {
            let items = try FeedbackCheckerItemMapper.map(data, from: response)
            return .success(items)
        } catch {
            return .failure(error)
        }
    }
}
