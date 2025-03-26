//
//  RemoteReviewLoader.swift
//  KipasKipas
//
//  Created by Rahmat Trinanda Pramudya Amar on 19/10/22.
//  Copyright © 2022 Koanba. All rights reserved.
//

import Foundation
import KipasKipasNetworking

class RemoteReviewLoader: ReviewPagedLoader {
    private let url : URL
    private let client: HTTPClient
    
    enum Error: Swift.Error {
        case connectivity
        case invalidData
        case noData
    }
    
    typealias Result = ReviewPagedLoader.Result
    
    init(url: URL, client: HTTPClient) {
        self.url = url
        self.client = client
    }
    
    func load(request: ReviewPagedRequest, completion: @escaping (Result) -> Void) {
        let request = ReviewEndpoint.pagedReview(request: request, isMedia: false).url(baseURL: url)
        
        Task {
            do {
                let (data, response) = try await client.request(from: request)
                completion(RemoteReviewLoader.map(data, from: response))
            } catch {
                completion(.failure(KKNetworkError.connectivity))
            }
        }
    }
    
    
    private static func map(_ data: Data, from response: HTTPURLResponse) -> Result {
        do {
            let items = try ReviewMapper.map(data, from: response)
            return .success(items)
        } catch {
            return .failure(error)
        }
    }
    
}
