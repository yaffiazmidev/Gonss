//
//  RemoteCallProfileDataLoader.swift
//  KipasKipasCall
//
//  Created by Rahmat Trinanda Pramudya Amar on 23/12/23.
//

import Foundation
import KipasKipasNetworking

public class RemoteCallProfileDataLoader: CallProfileDataLoader {
    private let url : URL
    private let client: HTTPClient
    
    enum Error: Swift.Error {
        case connectivity
        case invalidData
        case noData
    }
    
    public typealias Result = CallProfileDataLoader.Result
    
    public init(url: URL, client: HTTPClient) {
        self.url = url
        self.client = client
    }
    
    public func load(request: CallProfileDataLoaderRequest, completion: @escaping (Result) -> Void) {
        let request = CallProfileEndpoint.data(request.userId).url(baseURL: url)
        
        Task {
            do {
                let (data, response) = try await client.request(from: request)
                completion(RemoteCallProfileDataLoader.map(data, from: response))
            } catch {
                completion(.failure(KKNetworkError.connectivity))
            }
        }
    }
    
    
    private static func map(_ data: Data, from response: HTTPURLResponse) -> Result {
        do {
            let items = try CallProfileDataMapper.map(data, from: response)
            return .success(items)
        } catch {
            return .failure(error)
        }
    }
    
}
