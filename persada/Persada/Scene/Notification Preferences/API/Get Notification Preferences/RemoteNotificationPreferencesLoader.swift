//
//  RemoteNotificationPreferencesLoader.swift
//  KipasKipas
//
//  Created by PT.Koanba on 15/11/22.
//  Copyright © 2022 Koanba. All rights reserved.
//

import Foundation
import KipasKipasNetworking

class RemoteNotificationPreferencesLoader: NotificationPreferencesLoader {
    private let url : URL
    private let client: HTTPClient
        
    public typealias Result = NotificationPreferencesLoader.Result
    
    public init(url: URL, client: HTTPClient) {
        self.url = url
        self.client = client
    }
    
    func load(request: NotificationPreferencesRequest, completion: @escaping (Result) -> Void) {
        let request = NotificationPreferencesEndpoint.get(request: request).url(baseURL: url)
        
        Task {
            do {
                let (data, response) = try await client.request(from: request)
                completion(RemoteNotificationPreferencesLoader.map(data, from: response))
            } catch {
                completion(.failure(KKNetworkError.connectivity))
            }
        }
    }
    
    private static func map(_ data: Data, from response: HTTPURLResponse) -> Result {
        do {
            let items = try NotificationPreferencesItemMapper.map(data, from: response)
            return .success(items)
        } catch {
            return .failure(error)
        }
    }
}
