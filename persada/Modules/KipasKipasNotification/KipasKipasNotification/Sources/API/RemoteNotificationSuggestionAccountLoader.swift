import Foundation
import KipasKipasNetworking

public class RemoteNotificationSuggestionAccountLoader: NotificationSuggestionAccountLoader {
    
    private let url: URL
    private let client: HTTPClient
    public typealias Result = NotificationSuggestionAccountLoader.ResultSuggestionAccount
    
    public init(
        url: URL,
        client: HTTPClient)
    {
        self.url = url
        self.client = client
    }

    public func load(request: NotificationSuggestionAccountRequest, completion: @escaping (Result) -> Void) {
        
        let request = NotificationEndpoint.suggestionAccount(request: request).url(baseURL: url)
        
        Task {
            do {
                let (data, response) = try await client.request(from: request)
                completion(RemoteNotificationSuggestionAccountLoader.map(data, from: response))
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    private static func map(_ data: Data, from response: HTTPURLResponse) -> NotificationSuggestionAccountLoader.ResultSuggestionAccount {
        do {
            let content = try NotificationSuggestionAccountItemMapper.map(data, from: response)
            return .success(content)
        } catch {
            return .failure(error)
        }
    }
}

public class NotificationSuggestionAccountItemMapper {
    
    private struct Root: Codable {
        private let data: DataClass?
        
        private struct DataClass: Codable {
            var content: [Content]?
            var totalPages: Int?
        }
        
        private struct Content: Codable {
            var id, username, name: String?
            var photo: String?
            var isFollow: Bool?
            var isFollowed: Bool?
            var isVerified: Bool?
            var suggestId, suggestType: String?
            var firstId, firstName: String?
            var firstPhoto: String?
            var secondId, secondName, secondPhoto: String?
            var othersLike, followedAt: Int?
        }
        
        var content: NotificationSuggestionAccountContent {
            let content = data?.content?.compactMap({
                return NotificationSuggestionAccountItem(
                    id: $0.id ?? "",
                    username: $0.username ?? "-",
                    name: $0.name ?? "",
                    photo: $0.photo ?? "",
                    isFollow: $0.isFollow ?? false,
                    isFollowed: $0.isFollowed ?? false,
                    isVerified: $0.isVerified ?? false,
                    suggestId: $0.suggestId ?? "",
                    suggestType: $0.suggestType ?? "",
                    firstId: $0.firstId ?? "",
                    firstName: $0.firstName ?? "",
                    firstPhoto: $0.firstPhoto ?? "",
                    secondId: $0.secondId ?? "",
                    secondName: $0.secondName ?? "",
                    secondPhoto: $0.secondPhoto ?? "",
                    othersLike: $0.othersLike ?? 0,
                    followedAt: $0.followedAt ?? 0
                )
            }) ?? []
            return NotificationSuggestionAccountContent(content: content, totalPages: data?.totalPages)
        }
    }
    
    static func map(_ data: Data, from response: HTTPURLResponse) throws -> NotificationSuggestionAccountContent {
        guard response.statusCode == 200, let root = try? JSONDecoder().decode(Root.self, from: data) else {
            throw KKNetworkError.invalidData
        }
        
        return root.content
    }
}
