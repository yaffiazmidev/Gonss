import Foundation
import KipasKipasNetworking

public class RemoteNotificationSystemLoader: NotificationSystemLoader {
    
    private let url: URL
    private let client: HTTPClient
    public typealias Result = NotificationSystemLoader.ResultSystem
    
    public init(
        url: URL,
        client: HTTPClient)
    {
        self.url = url
        self.client = client
    }

    public func load(request: NotificationSystemRequest, completion: @escaping (Result) -> Void) {
        
        let urlRequest = NotificationEndpoint.systemNotif(request: request).url(baseURL: url)
        
        Task {
            do {
                let (data, response) = try await client.request(from: urlRequest)
                completion(RemoteNotificationSystemLoader.map(data, from: response))
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    public func read(request: NotificationSystemIsReadRequest, types: String, completion: @escaping (ResultSystemIsRead) -> Void) {
        let urlRequest = NotificationEndpoint.systemNotifIsRead(request: request, types: types).url(baseURL: url)
        
        Task {
            do {
                let (data, response) = try await client.request(from: urlRequest)
                completion(RemoteNotificationSystemLoader.mapIsRead(data, from: response))
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    public func unread(request: NotificationSystemUnreadRequest, types: String, completion: @escaping (ResultSystemUnread) -> Void) {
        let urlRequest = NotificationEndpoint.systemNotifUnread(request: request, types: types).url(baseURL: url)
        
        Task {
            do {
                let (data, response) = try await client.request(from: urlRequest)
                completion(RemoteNotificationSystemLoader.mapUnread(data, from: response))
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    private static func map(_ data: Data, from response: HTTPURLResponse) -> NotificationSystemLoader.ResultSystem {
        do {
            let content = try NotificationSystemItemMapper.map(data, from: response)
            return .success(content)
        } catch {
            return .failure(error)
        }
    }
    
    private static func mapIsRead(_ data: Data, from response: HTTPURLResponse) -> NotificationSystemLoader.ResultSystemIsRead {
        do {
            let message = try NotificationSystemIsReadItemMapper.map(data, from: response)
            return .success(message)
        } catch {
            return .failure(error)
        }
    }
    
    private static func mapUnread(_ data: Data, from response: HTTPURLResponse) -> NotificationSystemLoader.ResultSystemUnread {
        do {
            let message = try NotificationSystemUnreadItemMapper.map(data, from: response)
            return .success(message)
        } catch {
            return .failure(error)
        }
    }
}

public class NotificationSystemItemMapper {
    
    private struct Root: Codable {
        private let data: DataClass?
        
        private struct DataClass: Codable {
            var content: [Content]?
            var totalPages: Int?
        }
        
        private struct Content: Codable {
            let id, types, title, description, targetId: String?
            let createdAt: Int?
            let targetAccountId: String?
            let isRead: Bool?
        }
        
        var item: NotificationSystemItem {
            let content =  data?.content?.compactMap({
                
                return NotificationSystemContent(
                    id: $0.id ?? "",
                    types: $0.types ?? "",
                    title: $0.title ?? "",
                    subTitle: $0.description ?? "",
                    targetId: $0.targetId ?? "",
                    createdAt: $0.createdAt ?? 0,
                    targetAccountId: $0.targetAccountId ?? "",
                    isRead: $0.isRead ?? false
                )
            }) ?? []
            return NotificationSystemItem(content: content, totalPages: data?.totalPages ?? 0)
        }
    }
    
    static func map(_ data: Data, from response: HTTPURLResponse) throws -> NotificationSystemItem {
        guard response.statusCode == 200, let root = try? JSONDecoder().decode(Root.self, from: data) else {
            throw KKNetworkError.invalidData
        }
        
        return root.item
    }
}

public class NotificationSystemIsReadItemMapper {
    
    static func map(_ data: Data, from response: HTTPURLResponse) throws -> NotificationDefaultResponse {
        guard response.statusCode == 200, let root = try? JSONDecoder().decode(NotificationDefaultResponse.self, from: data) else {
            throw KKNetworkError.invalidData
        }
        
        return root
    }
}


public class NotificationSystemUnreadItemMapper {
    
    static func map(_ data: Data, from response: HTTPURLResponse) throws -> NotificationSystemUnreadItem {
        guard response.statusCode == 200, let root = try? JSONDecoder().decode(NotificationSystemUnreadItem.self, from: data) else {
            throw KKNetworkError.invalidData
        }
        
        return root
    }
}
