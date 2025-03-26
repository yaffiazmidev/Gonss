//
//  RemoteCourierLoader.swift
//  KipasKipas
//
//  Created by Muhammad Noor on 24/11/22.
//  Copyright © 2022 Koanba. All rights reserved.
//

import Foundation

class RemoteCourierLoader: CourierLoader {
    private let url: URL
    private let client: HTTPClient
    
    public typealias Result = CourierLoader.Result
    
    public init(url: URL, client: HTTPClient) {
        self.url = url
        self.client = client
    }
    
    func load(request: CourierRequest, completion: @escaping (Result) -> Void) {
        let urlRequest = CourierAPI.get(request: request).url(baseURL: url)
        client.request(from: urlRequest) { [weak self] result in
            guard self != nil else { return }
            
            switch result {
            case let .success((data, response)):
                completion(RemoteCourierLoader.map(data, from: response))
            case .failure:
                completion(.failure(KKNetworkError.connectivity))
            }
        }
    }
    
    private static func map(_ data: Data, from response: HTTPURLResponse) -> Result {
        do {
            let items = try CourierItemMapper.map(data, from: response)
            return .success(items)
        } catch {
            return .failure(error)
        }
    }
}
