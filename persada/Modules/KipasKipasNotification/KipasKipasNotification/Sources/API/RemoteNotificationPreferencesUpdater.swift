//
//  RemoteNotificationPreferencesUpdater.swift
//  KipasKipasNotification
//
//  Created by DENAZMI on 03/05/24.
//

import Foundation
import KipasKipasNetworking

public class RemoteNotificationPreferencesUpdater: NotificationPreferencesUpdater {
    private let url : URL
    private let client: HTTPClient
        
    public typealias Result = NotificationPreferencesUpdater.Result
    
    public init(url: URL, client: HTTPClient) {
        self.url = url
        self.client = client
    }
    
    public func update(request: NotificationPreferencesUpdateRequest, completion: @escaping (Result) -> Void) {
        let request = NotificationEndpoint.preferencesUpdate(request: request).url(baseURL: url)
        
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

class NotificationPreferencesUpdateItemMapper {
    
    private struct Root: Decodable {
        private let code, message: String
        
        var item: NotificationPreferencesUpdateItem {
            NotificationPreferencesUpdateItem(code: code, message: message)
        }
    }

    
    public static func map(_ data: Data, from response: HTTPURLResponse) throws -> NotificationPreferencesUpdateItem {
        guard response.isOK, let root = try? JSONDecoder().decode(Root.self, from: data) else {
            throw KKNetworkError.invalidData
        }
        
        return root.item
    }
}
