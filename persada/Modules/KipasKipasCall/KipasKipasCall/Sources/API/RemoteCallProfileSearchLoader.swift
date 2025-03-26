//
//  RemoteCallProfileSearchLoader.swift
//  KipasKipasCall
//
//  Created by Rahmat Trinanda Pramudya Amar on 23/12/23.
//

import Foundation
import KipasKipasNetworking

public class RemoteCallProfileSearchLoader: CallProfileSearchLoader {
    private let url : URL
    private let client: HTTPClient
    
    enum Error: Swift.Error {
        case connectivity
        case invalidData
        case noData
    }
    
    public typealias Result = CallProfileSearchLoader.Result
    
    public init(url: URL, client: HTTPClient) {
        self.url = url
        self.client = client
    }
    
    public func load(request: CallProfileSearchLoaderRequest, completion: @escaping (Result) -> Void) {
        let request = CallProfileEndpoint.search(username: request.username).url(baseURL: url)
        
        Task {
            do {
                let (data, response) = try await client.request(from: request)
                completion(RemoteCallProfileSearchLoader.map(data, from: response))
            } catch {
                completion(.failure(KKNetworkError.connectivity))
            }
        }
    }
    
    
    private static func map(_ data: Data, from response: HTTPURLResponse) -> Result {
        do {
            let items = try CallProfileSearchMapper.map(data, from: response)
            return .success(items)
        } catch {
            return .failure(error)
        }
    }
    
}
