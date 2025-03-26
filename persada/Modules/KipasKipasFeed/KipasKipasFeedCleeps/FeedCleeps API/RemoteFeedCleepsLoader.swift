//
//  RemoteFeedCleepsLoader.swift
//  KipasKipasFeedCleeps
//
//  Created by DENAZMI on 22/06/22.
//

import Foundation
import KipasKipasNetworking

public class RemoteFeedCleepsLoader: FeedCleepsLoader {
    
    private var url: URL
    private var client: HTTPClient
    
    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }
    
    public typealias Result = FeedCleepsLoader.Result
    
    public init(url: URL, client: HTTPClient) {
        self.url = url
        self.client = client
    }
    
    public func load(request: PagedFeedCleepsLoaderRequest, completion: @escaping (Result) -> Void) {
        let request = URLRequest(url: enrich(url, with: request))
        client.request(from: request) { [weak self] result in
            guard self != nil else { return }
            switch result {
            case let .success((data, response)):
                completion(RemoteFeedCleepsLoader.map(data, from: response))
            case .failure:
                completion(.failure(Error.connectivity))
            }
        }
    }
    
    private static func map(_ data: Data, from response: HTTPURLResponse) -> Result {
        do {
            let items = try FeedCleepsItemMapper.map(data, from: response)
            return .success(items)
        } catch {
            return .failure(error)
        }
    }
}

extension RemoteFeedCleepsLoader {
    func enrich(_ url: URL, with request: PagedFeedCleepsLoaderRequest) -> URL {
        var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false)
        urlComponents?.queryItems = [
            URLQueryItem(name: "page", value: "\(request.page)"),
            URLQueryItem(name: "size", value: "\(request.size)")
        ]
        return urlComponents?.url ?? url
    }
}
