//
//  RemoteNotificationSystemIsReadCheck.swift
//  KipasKipasNotification
//
//  Created by DENAZMI on 17/05/24.
//

import Foundation
import KipasKipasNetworking

public class RemoteNotificationSystemIsReadCheck: NotificationSystemIsReadCheck {
    
    private let url: URL
    private let client: HTTPClient
    public typealias Result = NotificationActivitiesIsReadCheck.ResultActivitiesIsRead
    
    public init(
        url: URL,
        client: HTTPClient)
    {
        self.url = url
        self.client = client
    }

    public func check(request: NotificationSystemIsReadRequest, completion: @escaping (Result) -> Void) {
        
        let request = NotificationEndpoint.systemNotifIsRead(request: request, types: "").url(baseURL: url)
        
        Task {
            do {
                let (data, response) = try await client.request(from: request)
                completion(RemoteNotificationSystemIsReadCheck.map(data, from: response))
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    private static func map(_ data: Data, from response: HTTPURLResponse) -> NotificationActivitiesIsReadCheck.ResultActivitiesIsRead {
        do {
            let item = try NotificationSystemIsReadItemMapper.map(data, from: response)
            return .success(item)
        } catch {
            return .failure(error)
        }
    }
}
