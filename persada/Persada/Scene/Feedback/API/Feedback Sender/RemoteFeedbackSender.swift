//
//  RemoteFeedbackSender.swift
//  KipasKipas
//
//  Created by PT.Koanba on 06/12/22.
//  Copyright © 2022 Koanba. All rights reserved.
//

import Foundation
import KipasKipasNetworking

class RemoteFeedbackSender: FeedbackSender {
    private let url : URL
    private let client: HTTPClient
        
    public typealias Result = FeedbackSender.Result
    
    public init(url: URL, client: HTTPClient) {
        self.url = url
        self.client = client
    }
    
    func send(request: FeedbackSenderRequest, completion: @escaping (Result) -> Void) {
        let request = FeedbackEndpoint.send(request: request).url(baseURL: url)
        
        Task {
            do {
                let (data, response) = try await client.request(from: request)
                completion(RemoteFeedbackSender.map(data, from: response))
            } catch {
                completion(.failure(KKNetworkError.connectivity))
            }
        }
    }
    
    private static func map(_ data: Data, from response: HTTPURLResponse) -> Result {
        do {
            let items = try FeedbackSenderItemMapper.map(data, from: response)
            return .success(items)
        } catch {
            return .failure(error)
        }
    }
}
