import Foundation
import KipasKipasNetworking

public class RemoteNotificationActivitiesLoader: NotificationActivitiesLoader {
    
    private var url: URL
    private var client: HTTPClient
    
    public typealias Result = NotificationActivitiesLoader.ResultActivities
    
    public init(url: URL, client: HTTPClient) {
        self.url = url
        self.client = client
    }
    
    public func load(request: NotificationActivitiesRequest, completion: @escaping (Result) -> Void) {
        let urlRequest = NotificationEndpoint.activities(request: request).url(baseURL: url)
        
        Task {
            do {
                let (data, response) = try await client.request(from: urlRequest)
                completion(RemoteNotificationActivitiesLoader.map(data, from: response))
            } catch {
                completion(.failure(KKNetworkError.connectivity))
            }
        }
    }
    
    private static func map(_ data: Data, from response: HTTPURLResponse) -> Result {
        do {
            let content = try NotificationActivitiesItemMapper.map(data, from: response)
            return .success(content)
        } catch {
            return .failure(error)
        }
    }
}

public class NotificationActivitiesItemMapper {
    
    private struct Root: Codable {
        private let data: DataClass?
        
        private struct DataClass: Codable {
            var content: [Content]?
            var totalPages: Int?
        }
        
        private struct Content: Codable {
            public var notificationid: String?
            public var groupHour: String?
            public var feedid: String?
            public var thumbnailurl: String?
            public var actionType: String?
            public var targetType: String?
            public var targetId, targetAccountId: String?
            public var targetAccountName: String?
            public var targetAccountPhoto: String?
            public var createDate: String?
            public var createAt: Int?
            public var firstid: String?
            public var firstName: String?
            public var firstPhoto: String?
            public var secondid, secondName: String?
            public var secondPhoto: String?
            public var othersLike: Int?
            public var valueComment: String?
            public var actionAccountId: String?
            public var actionAccountName: String?
            public var actionAccountPhoto: String?
            public var isRead: Bool?
            public var id: String?
            public var modifiedAt: Int?
            
            enum CodingKeys: String, CodingKey {
                case notificationid = "notificationId"
                case groupHour
                case feedid = "feedId"
                case thumbnailurl = "thumbnailUrl"
                case actionType, targetType
                case targetId = "targetId"
                case targetAccountId = "targetAccountId"
                case targetAccountName, targetAccountPhoto, createDate, createAt
                case firstid = "firstId"
                case firstName, firstPhoto
                case secondid = "secondId"
                case secondName, secondPhoto, othersLike, valueComment
                case actionAccountId = "actionAccountId"
                case actionAccountName, actionAccountPhoto, isRead, id
                case modifiedAt = "modifiedAt"
            }
        }
        
        var content: NotificationActivitiesContent {
            let content = data?.content?.compactMap {
                return NotificationActivitiesItem(
                    notificationid: $0.notificationid ?? "",
                    id: $0.id ?? "",
                    name: $0.targetAccountName ?? "-",
                    actionType: $0.actionType ?? "",
                    targetType: $0.targetType ?? "",
                    value: $0.valueComment ?? "",
                    isRead:$0.isRead ?? false,
                    targetAccountId: $0.targetAccountId ?? "",
                    targetAccountName: $0.targetAccountName ?? "",
                    targetAccountPhoto: $0.targetAccountPhoto ?? "",
                    targetId: $0.targetId ?? "",
                    feedId: $0.feedid ?? "",
                    thumbnailUrl: $0.thumbnailurl ?? "",
                    createDate: $0.createDate ?? "",
                    createAt: $0.createAt ?? 0,
                    groupHour: $0.groupHour ?? "",
                    firstId: $0.firstid ?? "",
                    firstName: $0.firstName ?? "",
                    firstPhoto: $0.firstPhoto ?? "",
                    secondId: $0.secondid ?? "",
                    secondName: $0.secondName ?? "",
                    secondPhoto: $0.secondPhoto ?? "",
                    other: $0.othersLike ?? 0,
                    actionAccountId: $0.actionAccountId ?? "",
                    actionAccountName: $0.actionAccountName ?? "",
                    actionAccountPhoto: $0.actionAccountPhoto ?? "", 
                    modifiedAt: $0.modifiedAt ?? 0)
            } ?? []
            return NotificationActivitiesContent(content: content, totalPages: data?.totalPages)
        }
    }
    
    static func map(_ data: Data, from response: HTTPURLResponse) throws -> NotificationActivitiesContent {
        guard response.statusCode == 200, let root = try? JSONDecoder().decode(Root.self, from: data) else {
            throw KKNetworkError.invalidData
        }
        
        return root.content
    }
}

