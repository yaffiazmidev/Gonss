//
//  ReviewReviewCreateCreator.swift
//  KipasKipas
//
//  Created by Rahmat Trinanda Pramudya Amar on 20/10/22.
//  Copyright © 2022 Koanba. All rights reserved.
//

import Foundation
import KipasKipasNetworking

final class RemoteReviewCreator: ReviewCreator{
    
    private let url : URL
    private let client: HTTPClient
    
    enum Error: Swift.Error {
        case connectivity
        case invalidData
    }
    
    typealias Result = ReviewCreator.Result
    
    init(url: URL, client: HTTPClient) {
        self.url = url
        self.client = client
    }
    
    func create(request: ReviewCreateRequest, completion: @escaping (Result) -> Void) {
        let urlRequest = ReviewEndpoint.createReview(request: request).url(baseURL: url)
        
        Task {
            do {
                let (data, response) = try await client.request(from: urlRequest)
                completion(RemoteReviewCreator.validate(data, from: response))
            } catch {
                completion(.failure(KKNetworkError.connectivity))
            }
        }
    }
    
    private static func validate(_ data: Data, from response: HTTPURLResponse) -> Result {
        if response.statusCode == 200 {
            return .success(data)
        }else{
            return .failure(Error.connectivity)
        }
    }
}
