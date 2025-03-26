import Foundation
import KipasKipasNetworking

public class RemoteNotificationFollowersLoader: NotificationFollowersLoader {
    
    private var url: URL
    private var client: HTTPClient
    
    public typealias Result = NotificationFollowersLoader.ResultFollowers
    
    public init(url: URL, client: HTTPClient) {
        self.url = url
        self.client = client
    }
    
    public func load(request: NotificationFollowersRequest, completion: @escaping (Result) -> Void) {
        let urlRequest = NotificationEndpoint.followers(request: request).url(baseURL: url)
        
        Task {
            do {
                let (data, response) = try await client.request(from: urlRequest)
                completion(RemoteNotificationFollowersLoader.map(data, from: response))
            } catch {
                completion(.failure(KKNetworkError.connectivity))
            }
        }
    }
    
    private static func map(_ data: Data, from response: HTTPURLResponse) -> Result {
        do {
            let items = try NotificationFollowersItemMapper.map(data, from: response)
            return .success(items)
        } catch {
            return .failure(error)
        }
    }
}

public class NotificationFollowersItemMapper {
    
    private struct Root: Codable {
        private let data: DataClass?
        
        private struct DataClass: Codable {
            let content: [Content]?
            var totalPages: Int?
        }
        
        private struct Content: Codable {
            var id, username, name: String?
            var photo: String?
            var isFollow: Bool?
            var isFollowed: Bool?
            var followedAt: Int?
            var isVerified: Bool?
        }
        
        var items: NotificationFollowersItem {
            let content = data?.content?.compactMap {
                return NotificationFollowersContent(
                    id: $0.id ?? "",
                    name: $0.name ?? "",
                    username: $0.username ?? "''",
                    photo: $0.photo ?? "",
                    isFollow: $0.isFollow ?? false,
                    isFollowed: $0.isFollowed ?? false,
                    followedAt: $0.followedAt ?? 0, 
                    isVerified: $0.isVerified ?? false
                )
            } ?? []
            return NotificationFollowersItem(content: content, totalPages: data?.totalPages)
        }
    }
    
    static func map(_ data: Data, from response: HTTPURLResponse) throws -> NotificationFollowersItem {
        guard response.statusCode == 200, let root = try? JSONDecoder().decode(Root.self, from: data) else {
            throw KKNetworkError.invalidData
        }
        
        return root.items
    }
}

