//
//  RemoteNotificationPreferencesUpdater.swift
//  KipasKipas
//
//  Created by PT.Koanba on 15/11/22.
//  Copyright © 2022 Koanba. All rights reserved.
//

import Foundation
import KipasKipasNetworking

class RemoteNotificationPreferencesUpdater: NotificationPreferencesUpdater {
    private let url : URL
    private let client: HTTPClient
        
    public typealias Result = NotificationPreferencesUpdater.Result
    
    public init(url: URL, client: HTTPClient) {
        self.url = url
        self.client = client
    }
    
    func update(request: NotificationPreferencesUpdateRequest, completion: @escaping (Result) -> Void) {
        let request = NotificationPreferencesEndpoint.update(request: request).url(baseURL: url)
        
        Task {
            do {
                let (data, response) = try await client.request(from: request)
                completion(RemoteNotificationPreferencesUpdater.map(data, from: response))
            } catch {
                completion(.failure(KKNetworkError.connectivity))
            }
        }
    }
    
    private static func map(_ data: Data, from response: HTTPURLResponse) -> Result {
        do {
            let items = try NotificationPreferencesUpdateItemMapper.map(data, from: response)
            return .success(items)
        } catch {
            return .failure(error)
        }
    }
}
