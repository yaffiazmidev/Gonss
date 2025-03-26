//
//  RemoteNotificationPreferencesLoader.swift
//  KipasKipasNotification
//
//  Created by DENAZMI on 03/05/24.
//

import Foundation
import KipasKipasNetworking

public class RemoteNotificationPreferencesLoader: NotificationPreferencesLoader {
    private let url : URL
    private let client: HTTPClient
        
    public typealias Result = NotificationPreferencesLoader.ResultPreferences
    
    public init(url: URL, client: HTTPClient) {
        self.url = url
        self.client = client
    }
    
    public func load(request: NotificationPreferencesRequest, completion: @escaping (Result) -> Void) {
        let request = NotificationEndpoint.preferences(request: request).url(baseURL: url)
        
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

class NotificationPreferencesItemMapper {
    
    private struct RemoteNotificationPreferences: Decodable {
        private let code, message: String
        private let data: RemoteNotificationPreferencesData
        
        private struct RemoteNotificationPreferencesData: Decodable {
            let subCodes: RemoteNotificationPreferencesSubCodes
        }

        private struct RemoteNotificationPreferencesSubCodes: Decodable {
            public let socialmedia: Bool
            public let socialMediaComment: Bool
            public let socialMediaLike: Bool
            public let socialMediaMention: Bool
            public let socialMediaFollower: Bool
            public var socialMediaLive: Bool
            public var socialMediaAccount: Bool
        }
        
        var item: NotificationPreferencesItem {
            NotificationPreferencesItem(
                socialmedia: data.subCodes.socialmedia,
                socialMediaComment: data.subCodes.socialMediaComment,
                socialMediaLike: data.subCodes.socialMediaLike,
                socialMediaMention: data.subCodes.socialMediaMention,
                socialMediaFollower: data.subCodes.socialMediaFollower,
                socialMediaLive: data.subCodes.socialMediaLive,
                socialMediaAccount: data.subCodes.socialMediaAccount
            )
        }
    }

    
    public static func map(_ data: Data, from response: HTTPURLResponse) throws -> NotificationPreferencesItem {
        guard response.isOK, let root = try? JSONDecoder().decode(RemoteNotificationPreferences.self, from: data) else {
            throw KKNetworkError.invalidData
        }
        
        return root.item
    }
}
