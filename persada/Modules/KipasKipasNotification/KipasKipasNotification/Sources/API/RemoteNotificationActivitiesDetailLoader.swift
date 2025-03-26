import Foundation
import KipasKipasNetworking

public class RemoteNotificationActivitiesDetailLoader: NotificationActivitiesDetailLoader {
    
    private let url: URL
    private let client: HTTPClient
    public typealias Result = NotificationActivitiesDetailLoader.ResultActivitiesDetail
    
    public init(
        url: URL,
        client: HTTPClient)
    {
        self.url = url
        self.client = client
    }

    public func load(request: NotificationActivitiesDetailRequest, completion: @escaping (Result) -> Void) {
        
        let request = NotificationEndpoint.activitiesDetail(request: request).url(baseURL: url)
        
        Task {
            do {
                let (data, response) = try await client.request(from: request)
                completion(RemoteNotificationActivitiesDetailLoader.map(data, from: response))
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    private static func map(_ data: Data, from response: HTTPURLResponse) -> NotificationActivitiesDetailLoader.ResultActivitiesDetail {
        do {
            let items = try NotificationActivitiesDetailItemMapper.map(data, from: response)
            return .success(items)
        } catch {
            return .failure(error)
        }
    }
}

public class NotificationActivitiesDetailItemMapper {
    
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
        }
        
        var content: NotificationSuggestionAccountContent {
            let content = data?.content?.compactMap({
                return NotificationSuggestionAccountItem(
                    id: $0.id ?? "",
                    username: $0.username ?? "",
                    name: $0.name ?? "",
                    photo: $0.photo ?? "",
                    isFollow: $0.isFollow ?? false,
                    isFollowed: $0.isFollowed ?? false,
                    isVerified: $0.isVerified ?? false,
                    suggestId: "",
                    suggestType: "",
                    firstId: "",
                    firstName: "",
                    firstPhoto: "",
                    secondId: "",
                    secondName: "",
                    secondPhoto: "",
                    othersLike:  0,
                    followedAt: 0
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
