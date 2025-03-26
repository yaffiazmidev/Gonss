//
//  RemoteNotificationReadUpdater.swift
//  KipasKipasNotification
//
//  Created by DENAZMI on 26/05/24.
//

import Foundation
import KipasKipasNetworking

public class RemoteNotificationReadUpdater: NotificationReadUpdater {
    
    private let baseURL: URL
    private let client: HTTPClient
    public typealias Result = NotificationReadUpdater.Result
    
    public init(
        baseURL: URL,
        client: HTTPClient)
    {
        self.baseURL = baseURL
        self.client = client
    }
    
    public func update(_ request: NotificationReadRequest, completion: @escaping (Result) -> Void) {
        let request = NotificationEndpoint.notificationRead(request: request).url(baseURL: baseURL)
        
        Task {
            do {
                let (data, response) = try await client.request(from: request)
                completion(RemoteNotificationReadUpdater.map(data, from: response))
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    private static func map(_ data: Data, from response: HTTPURLResponse) -> Result {
        do {
            let item = try NotificationReadItemMapper.map(data, from: response)
            return .success(item)
        } catch {
            return .failure(error)
        }
    }
}

public class NotificationReadItemMapper {
    
    static func map(_ data: Data, from response: HTTPURLResponse) throws -> NotificationDefaultResponse {
        guard response.statusCode == 200, let root = try? JSONDecoder().decode(NotificationDefaultResponse.self, from: data) else {
            throw KKNetworkError.invalidData
        }
        
        return root
    }
}
