//
//  RemoteSTSTokenLoader.swift
//  KipasKipas
//
//  Created by Rahmat Trinanda Pramudya Amar on 13/01/23.
//  Copyright © 2023 Koanba. All rights reserved.
//

import Foundation
import KipasKipasNetworking

public class RemoteSTSTokenLoader: STSTokenLoader {
    
    private let url : URL
    private let client: HTTPClient
    
    public typealias Result = STSTokenLoader.Result
    
    public init(url: URL, client: HTTPClient) {
        self.url = url
        self.client = client
    }
    
    public func load(request: STSTokenLoaderRequest, completion: @escaping (Result) -> Void) {
        let request = STSTokenEndpoint.load(request: request).url(baseUrl: url)
        print("**@@ load token")
        
        Task {
            do {
                let (data, response) = try await client.request(from: request)
                completion(RemoteSTSTokenLoader.map(data, from: response))
            } catch {
                completion(.failure(KKNetworkError.connectivity))
                KKLoggerUpload.instance.send(error: "Connectivity", description: error.localizedDescription)
            }
        }
    }
    
    
    private static func map(_ data: Data, from response: HTTPURLResponse) -> Result {
        do {
            let items = try STSTokenItemMapper.map(data, from: response)
            return .success(items)
        } catch {
            KKLoggerUpload.instance.send(error: "Mapping", description: error.localizedDescription)
            return .failure(error)
        }
    }
    
}
