//
//  RemoteNotificationUnreadLoader.swift
//  KipasKipasNotification
//
//  Created by DENAZMI on 22/05/24.
//

import Foundation
import KipasKipasNetworking

public class RemoteNotificationUnreadLoader: NotificationUnreadLoader {
    
    private let baseURL: URL
    private let client: HTTPClient
    public typealias Result = NotificationUnreadLoader.Result
    
    public init(
        baseURL: URL,
        client: HTTPClient)
    {
        self.baseURL = baseURL
        self.client = client
    }

    public func load(completion: @escaping (Result) -> Void) {
        
        let request = NotificationEndpoint.notificationUnread.url(baseURL: baseURL)
        Task {
            do {
                let (data, response) = try await client.request(from: request)
                print("[DEN] \(response.statusCode) \(request.url?.absoluteString ?? "")")
                completion(RemoteNotificationUnreadLoader.map(data, from: response))
            } catch {
                print("[DEN] 404 \(request.url?.absoluteString ?? "") \n \(error)")
                completion(.failure(error))
            }
        }
    }
    
    private static func map(_ data: Data, from response: HTTPURLResponse) -> Result {
        do {
            let item = try NotificationUnreadLoaderItemMapper.map(data, from: response)
            return .success(item)
        } catch {
            return .failure(error)
        }
    }
}

public class NotificationUnreadLoaderItemMapper {
    
    private struct Root: Decodable {
        private let code, message: String
        private let data: DataClass?
        
        struct DataClass: Decodable {
            let activity: Int
            let newFollower: Int
            let systemNotif: Bool
            let transaction: Bool
            let totalUnread: Int
        }
        
        var item: NotificationUnreadItem {
            NotificationUnreadItem(
                activity: data?.activity ?? 0,
                newFollower: data?.newFollower ?? 0,
                systemNotif: data?.systemNotif ?? true,
                transaction: data?.transaction ?? true,
                totalUnread: data?.totalUnread ?? 0
            )
        }
    }
    
    static func map(_ data: Data, from response: HTTPURLResponse) throws -> NotificationUnreadItem {
        guard response.statusCode == 200, let root = try? JSONDecoder().decode(Root.self, from: data) else {
            throw KKNetworkError.invalidData
        }
        
        return root.item
    }
}


public struct NotificationUnreadItem: Equatable {
    public let activity: Int
    public let newFollower: Int
    public let systemNotif: Bool
    public let transaction: Bool
    public let totalUnread: Int
    
    public init(
        activity: Int = 0,
        newFollower: Int = 0,
        systemNotif: Bool = true,
        transaction: Bool = true,
        totalUnread: Int = 0
    ) {
        self.activity = activity
        self.newFollower = newFollower
        self.systemNotif = systemNotif
        self.transaction = transaction
        self.totalUnread = totalUnread
    }
}
