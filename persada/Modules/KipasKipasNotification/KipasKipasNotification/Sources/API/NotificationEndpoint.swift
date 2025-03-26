import Foundation
import KipasKipasNetworking

enum NotificationEndpoint {
    case profile(request: NotificationProfileStoryRequest)
    case story(request: NotificationStoryRequest)
    case activities(request: NotificationActivitiesRequest)
    case followUser(request: NotificationFollowUserRequest)
    case activitiesIsRead(request: NotificationActivitiesIsReadRequest)
    case activitiesDetail(request: NotificationActivitiesDetailRequest)
    case followers(request: NotificationFollowersRequest)
    case systemNotif(request: NotificationSystemRequest)
    case systemNotifIsRead(request: NotificationSystemIsReadRequest, types: String)
    case systemNotifUnread(request: NotificationSystemUnreadRequest, types: String)
    case transaction(request: NotificationTransactionRequest)
    case suggestionAccount(request: NotificationSuggestionAccountRequest)
    case preferences(request: NotificationPreferencesRequest)
    case preferencesUpdate(request: NotificationPreferencesUpdateRequest)
    case transactionDetail(request: NotificationTransactionDetailRequest)
    case notificationUnread
    case notificationRead(request: NotificationReadRequest)
    
    func url(baseURL: URL) -> URLRequest {
        switch self {
        case .profile(let request):
            var components = URLComponents()
            components.scheme = baseURL.scheme
            components.host = baseURL.host
            components.path = baseURL.path + "/profile/\(request.id)"
            
            return URLRequest(url: components.url!)
        case .story(request: let request):
            var components = URLComponents()
            components.scheme = baseURL.scheme
            components.host = baseURL.host
            components.path = baseURL.path + "/statics/stories"
            
            components.queryItems = [
                URLQueryItem(name: "page", value: "\(request.page)"),
                URLQueryItem(name: "size", value: "\(request.size)"),
            ].compactMap { $0 }
            
            var urlRequest = URLRequest(url: components.url!)
            urlRequest.httpMethod = "GET"
            return urlRequest
        case .activities(request: let request):
            var components = URLComponents()
            components.scheme = baseURL.scheme
            components.host = baseURL.host
            components.path = baseURL.path + "/notifications/group-activity"
            
            components.queryItems = [
                URLQueryItem(name: "page", value: "\(request.page)"),
                URLQueryItem(name: "size", value: "\(request.size)"),
            ].compactMap { $0 }
            
            var urlRequest = URLRequest(url: components.url!)
            urlRequest.httpMethod = "GET"
            return urlRequest
        case .activitiesIsRead(let request):
            var components = URLComponents()
            components.scheme = baseURL.scheme
            components.host = baseURL.host
            components.path = baseURL.path + "/notifications/group-activity/\(request.notificationId)"
            
            let body = try! JSONEncoder().encode(request)
            
            var request = URLRequest(url: components.url!)
            request.httpMethod = "PUT"
            request.httpBody = body
            return request
        case .activitiesDetail(let request):
            var components = URLComponents()
            components.scheme = baseURL.scheme
            components.host = baseURL.host
            components.path = baseURL.path + "/notifications/group-activity-detail"
            
            components.queryItems = [
                URLQueryItem(name: "page", value: "\(request.page)"),
                URLQueryItem(name: "size", value: "\(request.size)"),
                URLQueryItem(name: "actionType", value: "\(request.actionType)"),
                URLQueryItem(name: "targetType", value: "\(request.targetType)"),
                URLQueryItem(name: "targetId", value: "\(request.targetId)"),
                URLQueryItem(name: "targetAccountId", value: "\(request.targetAccountId)"),
            ].compactMap { $0 }
            
            var urlRequest = URLRequest(url: components.url!)
            urlRequest.httpMethod = "GET"
            return urlRequest
        case .followers(request: let request):
            var components = URLComponents()
            components.scheme = baseURL.scheme
            components.host = baseURL.host
            components.path = baseURL.path + "/notifications/new-follower"
            
            components.queryItems = [
                URLQueryItem(name: "page", value: "\(request.page)"),
                URLQueryItem(name: "size", value: "\(request.size)"),
            ].compactMap { $0 }
            
            var urlRequest = URLRequest(url: components.url!)
            urlRequest.httpMethod = "GET"
            return urlRequest
        case .followUser(let request):
            var components = URLComponents()
            components.scheme = baseURL.scheme
            components.host = baseURL.host
            components.path = baseURL.path + "/profile/\(request.id)/\(request.action.rawValue)"
            
            var urlRequest = URLRequest(url: components.url!)
            urlRequest.httpMethod = "PATCH"
            return urlRequest
        case .systemNotif(request: let request):
            var components = URLComponents()
            components.scheme = baseURL.scheme
            components.host = baseURL.host
            components.path = baseURL.path + "/notifications/system-notification/\(request.types)"
            
            components.queryItems = [
                URLQueryItem(name: "page", value: "\(request.page)"),
                URLQueryItem(name: "size", value: "\(request.size)"),
            ].compactMap { $0 }
            
            var urlRequest = URLRequest(url: components.url!)
            urlRequest.httpMethod = "GET"
            return urlRequest
        case let .systemNotifIsRead(request, type):
            var components = URLComponents()
            components.scheme = baseURL.scheme
            components.host = baseURL.host
            components.path = baseURL.path + "/notifications/system-notification/\(request.id)"
            
            let body = try! JSONEncoder().encode(request)
            
            var request = URLRequest(url: components.url!)
            request.httpMethod = "PUT"
            request.httpBody = body
            return request
        case let .systemNotifUnread(request, types):
            var components = URLComponents()
            components.scheme = baseURL.scheme
            components.host = baseURL.host
            components.path = baseURL.path + "/notifications/system-notification/unread/\(types)"
            
            let body = try! JSONEncoder().encode(request)
            
            var urlRequest = URLRequest(url: components.url!)
            urlRequest.httpMethod = "GET"
            return urlRequest
        case .transaction(request: let request):
            var components = URLComponents()
            components.scheme = baseURL.scheme
            components.host = baseURL.host
            components.path = baseURL.path + "/notifications/transaction"
            
            components.queryItems = [
                URLQueryItem(name: "page", value: "\(request.page)"),
                URLQueryItem(name: "size", value: "\(request.size)"),
                URLQueryItem(name: "types", value: "\(request.types)"),
            ].compactMap { $0 }
            
            var urlRequest = URLRequest(url: components.url!)
            urlRequest.httpMethod = "GET"
            return urlRequest
        case .suggestionAccount(request: let request):
            var components = URLComponents()
            components.scheme = baseURL.scheme
            components.host = baseURL.host
            components.path = baseURL.path + "/account/suggest"
            
            components.queryItems = [
                URLQueryItem(name: "page", value: "\(request.page)"),
                URLQueryItem(name: "size", value: "\(request.size)"),
            ].compactMap { $0 }
            
            var urlRequest = URLRequest(url: components.url!)
            urlRequest.httpMethod = "GET"
            return urlRequest
        case .preferences(request: let request):
            return URLRequest
                .url(baseURL)
                .path("/notifications/preference")
                .queries([
                    URLQueryItem(name: "code", value: request.code)
                ])
                .build()
        case .preferencesUpdate(request: let request):
            return URLRequest
                .url(baseURL)
                .path("/notifications/preference")
                .queries([
                    URLQueryItem(name: "code", value: request.code)
                ])
                .method(.PATCH)
                .body(request)
                .build()
        case let .transactionDetail(request):
            return URLRequest
                .url(baseURL)
                .path("/notifications/transaction/\(request.id)")
                .build()
        case .notificationUnread:
            return .url(baseURL)
                .path("/notifications/unread")
                .build()
        case let .notificationRead(request):
            return .url(baseURL)
                .path("/notifications/\(request.type.code)/me/read")
                .method(.PATCH)
                .build()
        }
    }
}


public struct NotificationProfileStoryRequest {
    public let id: String
    
    public init(id: String) {
        self.id = id
    }
}

public struct NotificationStoryRequest {
    public let page: Int
    public let size: Int
    
    public init(page: Int, size: Int) {
        self.page = page
        self.size = size
    }
}

public struct NotificationActivitiesRequest {
    public let page: Int
    public let size: Int
    
    public init(page: Int, size: Int) {
        self.page = page
        self.size = size
    }
}

public struct NotificationActivitiesIsReadRequest: Encodable {
    public let isRead: Bool
    public let notificationId: String
    
    public init(isRead: Bool, notificationId: String) {
        self.isRead = isRead
        self.notificationId = notificationId
    }
}

public enum FollowAction: String {
    case follow, unfollow
}

public struct NotificationFollowUserRequest {
    public let id: String
    public let action: FollowAction
    
    public init(id: String, action: FollowAction) {
        self.id = id
        self.action = action
    }
}

public struct NotificationActivitiesDetailRequest {
    public let page: Int
    public let size: Int
    public let actionType: String
    public let targetType: String
    public let targetId: String
    public let targetAccountId: String
    
    public init(page: Int, size: Int = 10, actionType: String, targetType: String, targetId: String, targetAccountId: String) {
        self.page = page
        self.size = size
        self.actionType = actionType
        self.targetType = targetType
        self.targetId = targetId
        self.targetAccountId = targetAccountId
    }
}

public struct NotificationFollowersRequest {
    public let page: Int
    public let size: Int
    
    public init(page: Int, size: Int) {
        self.page = page
        self.size = size
    }
}

public struct NotificationSystemRequest {
    public let page: Int
    public let size: Int
    public let types: String
    
    public init(page: Int, size: Int, types: String) {
        self.page = page
        self.size = size
        self.types = types
    }
}

public struct NotificationSystemIsReadRequest: Encodable {
    public let isRead: Bool
    public let id: String
    
    public init(isRead: Bool, id: String) {
        self.isRead = isRead
        self.id = id
    }
}

public struct NotificationSystemUnreadRequest: Encodable {
    public let isRead: Bool
    
    public init(isRead: Bool) {
        self.isRead = isRead
    }
}


public struct NotificationTransactionRequest {
    public let page: Int
    public let size: Int
    public let types: String
    
    public init(page: Int, size: Int, types: String) {
        self.page = page
        self.size = size
        self.types = types
    }
}

public struct NotificationSuggestionAccountRequest {
    public let page: Int
    public let size: Int
    
    public init(page: Int, size: Int) {
        self.page = page
        self.size = size
    }
}

public struct NotificationPreferencesRequest {
    public let code: String
    
    public init(code: String) {
        self.code = code
    }
}

public struct NotificationPreferencesUpdateRequest: Encodable {
    public let code: String
    public let subCodes: SubCodes
    
    public init(code: String, subCodes: SubCodes) {
        self.code = code
        self.subCodes = subCodes
    }
}

public struct SubCodes: Encodable {
    public var socialmedia: Bool
    public var socialMediaComment: Bool
    public var socialMediaLike: Bool
    public var socialMediaMention: Bool
    public var socialMediaFollower: Bool
    public var socialMediaLive: Bool
    public var socialMediaAccount: Bool
    
    public init(
        socialmedia: Bool,
        socialMediaComment: Bool,
        socialMediaLike: Bool,
        socialMediaMention: Bool,
        socialMediaFollower: Bool,
        socialMediaLive: Bool,
        socialMediaAccount: Bool
    ) {
        self.socialmedia = socialmedia
        self.socialMediaComment = socialMediaComment
        self.socialMediaLike = socialMediaLike
        self.socialMediaMention = socialMediaMention
        self.socialMediaFollower = socialMediaFollower
        self.socialMediaLive = socialMediaLive
        self.socialMediaAccount = socialMediaAccount
    }
}

public struct NotificationTransactionDetailRequest {
    public let id: String
    
    public init(id: String) {
        self.id = id
    }
}

public struct NotificationReadRequest {
    public let type: NotificationItemType
    
    public init(type: NotificationItemType) {
        self.type = type
    }
}

public enum NotificationItemType {
    case activity
    case systemNotif
    case transaction
    case newFollower
    
    public var code: String {
        switch self {
        case .activity:
            return "group-activity"
        case .systemNotif:
            return "system-notification"
        case .transaction:
            return "transaction"
        case .newFollower:
            return "new-follower"
        }
    }
}

public struct NotificationLotteryRequest {
    public let page: Int
    public let size: Int
    
    public init(page: Int, size: Int = 10) {
        self.page = page
        self.size = size
    }
}
