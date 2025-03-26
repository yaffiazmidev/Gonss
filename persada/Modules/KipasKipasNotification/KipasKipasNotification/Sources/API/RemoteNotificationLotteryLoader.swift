//
//  RemoteNotificationLotteryLoader.swift
//  KipasKipasNotification
//
//  Created by DENAZMI on 25/07/24.
//

import Foundation
import KipasKipasNetworking

public class RemoteNotificationLotteryLoader: NotificationLotteryLoader {
    
    private let baseURL: URL
    private let client: HTTPClient
    public typealias Result = NotificationLotteryLoader.Result
    
    public init(
        baseURL: URL,
        client: HTTPClient)
    {
        self.baseURL = baseURL
        self.client = client
    }

    public func load(request: NotificationLotteryRequest, completion: @escaping (Result) -> Void) {
        
        let request = enrich(request)
        
        Task {
            do {
                let (data, response) = try await client.request(from: request)
                completion(RemoteNotificationLotteryLoader.map(data, from: response))
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    private static func map(_ data: Data, from response: HTTPURLResponse) -> Result {
        do {
            let items = try NotificationLotteryItemMapper.map(data, from: response)
            return .success(items)
        } catch {
            return .failure(error)
        }
    }
}

extension RemoteNotificationLotteryLoader {
    private func enrich(_ request: NotificationLotteryRequest) -> URLRequest {
        return .url(baseURL)
            .path("/notifications/lottery")
            .queries([
                .init(name: "page", value: "\(request.page)"),
                .init(name: "size", value: "\(request.size)"),
                .init(name: "direction", value: "desc")
            ])
            .build()
    }
}

public class NotificationLotteryItemMapper {
    
    private struct Root: Codable {
        private let data: DataClass?
        
        private struct DataClass: Codable {
            var content: [Content]?
            var totalPages: Int?
        }
        
        private struct Content: Codable {
            var id: String?
            var actionType: String?
            var targetType: String?
            var actionMessage: String?
            var targetId: String?
        }
        
        var item: NotificationLotteryItem {
            let content = data?.content?.compactMap({
                return NotificationLotteryContent(
                    id: $0.id ?? "",
                    actionType: $0.actionType ?? "",
                    targetType: $0.targetType ?? "",
                    actionMessage: $0.actionMessage ?? "",
                    targetId: $0.targetId ?? ""
                )
            }) ?? []
            return NotificationLotteryItem(content: content, totalPages: data?.totalPages ?? 0)
        }
    }
    
    static func map(_ data: Data, from response: HTTPURLResponse) throws -> NotificationLotteryItem {
        guard response.statusCode == 200, let root = try? JSONDecoder().decode(Root.self, from: data) else {
            throw KKNetworkError.invalidData
        }
        
        return root.item
    }
}

