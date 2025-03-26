import Foundation

public struct DirectMessageRegisterParam: Encodable {
    public let externalChannelId: String
    public let payerId: String
    public let recipientId: String
    
    public init(externalChannelId: String, payerId: String, recipientId: String) {
        self.externalChannelId = externalChannelId
        self.payerId = payerId
        self.recipientId = recipientId
    }
}

public struct ListFollowingParam {
    public let userId: String
    public let page: Int
    
    public init(userId: String, page: Int) {
        self.userId = userId
        self.page = page
    }
}

public struct ChatParam: Encodable {
    public let externalChannelId: String
    public let payerId: String
    public let recipientId: String
    public let mobileMessageId: String
    public let messageText: String
    
    public init(
        externalChannelId: String,
        payerId: String,
        recipientId: String,
        mobileMessageId: String = "",
        messageText: String = ""
    ) {
        self.externalChannelId = externalChannelId
        self.payerId = payerId
        self.recipientId = recipientId
        self.mobileMessageId = mobileMessageId
        self.messageText = messageText
    }
}

public struct ChatPushNotificationParam: Encodable {
    public var appId: String
    public let includeExternalUserIds: [String]
    public let data: NotificationData
    public let contents: NotificationContents
    public let smallIcon: String
    public let iOSAttachments: NotificationiOSAttachements
    public let headings: NotificationHeadings
    public let contentAvailable: Bool
    
    public init(
        appId: String = "",
        includeExternalUserIds: [String],
        data: NotificationData,
        contents: NotificationContents,
        smallIcon: String,
        iOSAttachments: NotificationiOSAttachements = .init(),
        headings: NotificationHeadings,
        contentAvailable: Bool
    ) {
        self.appId = appId
        self.includeExternalUserIds = includeExternalUserIds
        self.data = data
        self.contents = contents
        self.smallIcon = smallIcon
        self.iOSAttachments = iOSAttachments
        self.headings = headings
        self.contentAvailable = contentAvailable
    }
    
    enum CodingKeys: String, CodingKey {
        case appId = "app_id"
        case includeExternalUserIds = "include_external_user_ids"
        case smallIcon = "small_icon"
        case iOSAttachments = "ios_attachments"
        case contentAvailable = "content_available"
        case data, contents, headings
    }
    
    public struct NotificationData: Encodable {
        public let from: String
        public let channelURL: String
        public let senderAccountId: String
        public let senderName: String
        public let senderIsVerified: String
        public let senderImageURL: String
        
        public init(
            from: String,
            channelURL: String,
            senderAccountId: String,
            senderName: String,
            senderIsVerified: String,
            senderImageURL: String
        ) {
            self.from = from
            self.channelURL = channelURL
            self.senderAccountId = senderAccountId
            self.senderName = senderName
            self.senderIsVerified = senderIsVerified
            self.senderImageURL = senderImageURL
        }
        
        enum CodingKeys: String, CodingKey {
            case from = "notif_from"
            case channelURL = "channel_url"
            case senderAccountId = "sender_account_id"
            case senderName = "sender_name"
            case senderIsVerified = "sender_is_verified"
            case senderImageURL = "sender_image_url"
        }
    }
    
    public struct NotificationContents: Encodable {
        public let en: String
        
        public init(en: String) {
            self.en = en
        }
    }
    
    public struct NotificationiOSAttachements: Encodable {
        let photo: String = ""
        
        public init() {}
    }
    
    public struct NotificationHeadings: Encodable {
        public let en: String
        
        public init(en: String) {
            self.en = en
        }
    }
}

public struct ChatChannelParam {
    public let channelURL: String
    public let isPaid: Bool
    
    public init(channelURL: String, isPaid: Bool) {
        self.channelURL = channelURL
        self.isPaid = isPaid
    }
}

public struct AllowCallParam {
    public let targetAccountId: String

    public init(targetAccountId: String) {
        self.targetAccountId = targetAccountId
    }
}

public enum DirectMessageEndpoint {
    case register(DirectMessageRegisterParam) // didn't need it anymore
    case following(ListFollowingParam)
    case searchUser(username: String)
    case paidChatPrice(userId: String)
    case paidSessionBalance(channelURL: String)
    case paidChatToggle(channel: ChatChannelParam, chat: ChatParam)
    case sendChat(ChatParam)
    case confirmSetDiamond(ChatParam)
    case sendPushNotification(param: ChatPushNotificationParam, apiKey: String)
    case profile(username: String)
    case allowCall(AllowCallParam)

    public func url(baseURL: URL) -> URLRequest {
        switch self {
        case let .register(param):
            var components = URLComponents()
            components.scheme = baseURL.scheme
            components.host = baseURL.host
            components.path = baseURL.path + "/chat/register-account"
            
            var urlRequest = URLRequest(url: components.url!)
            urlRequest.httpMethod = "POST"
            urlRequest.httpBody = try? JSONEncoder().encode(param)
            
            return urlRequest
            
        case let .following(param):
            var components = URLComponents()
            components.scheme = baseURL.scheme
            components.host = baseURL.host
            components.path = baseURL.path + "/profile/\(param.userId)/following"
            
            components.queryItems = [
                .init(name: "page", value: String(param.page)),
                .init(name: "size", value: "10"),
                .init(name: "sort", value: "createAt,desc")
            ].compactMap { $0 }
            
            return URLRequest(url: components.url!)
            
        case let .searchUser(username):
            var components = URLComponents()
            components.scheme = baseURL.scheme
            components.host = baseURL.host
            components.path = baseURL.path + "/search/account/username"
            
            components.queryItems = [
                .init(name: "value", value: username)
            ].compactMap { $0 }
            
            return URLRequest(url: components.url!)
            
        case let .paidChatPrice(userId):
            var components = URLComponents()
            components.scheme = baseURL.scheme
            components.host = baseURL.host
            components.path = baseURL.path + "/chat/diamond/setting/account/\(userId)"
            
            return URLRequest(url: components.url!)
            
        case let .paidSessionBalance(channelURL):
            var components = URLComponents()
            components.scheme = baseURL.scheme
            components.host = baseURL.host
            components.path = baseURL.path + "/balance/currency/\(channelURL)"
            
            return URLRequest(url: components.url!)
            
        case let .paidChatToggle(channel, chat):
            var components = URLComponents()
            components.scheme = baseURL.scheme
            components.host = baseURL.host
            
            let path = channel.isPaid ? "active" : "inactive/\(channel.channelURL)"
            
            components.path = baseURL.path + "/chat/channel/\(path)"
            
            var request = URLRequest(url: components.url!)
            request.httpMethod = channel.isPaid ? "POST" : "PUT"
            request.httpBody = try? JSONEncoder().encode(chat)
            
            return request
            
        case let .sendChat(param):
            var components = URLComponents()
            components.scheme = baseURL.scheme
            components.host = baseURL.host
            components.path = baseURL.path + "/chat"
            
            var urlRequest = URLRequest(url: components.url!)
            urlRequest.httpMethod = "POST"
            urlRequest.httpBody = try? JSONEncoder().encode(param)
            
            return urlRequest
            
        case let .confirmSetDiamond(param):
            var components = URLComponents()
            components.scheme = baseURL.scheme
            components.host = baseURL.host
            components.path = baseURL.path + "/chat/diamond/setting/confirmation"
            
            var urlRequest = URLRequest(url: components.url!)
            urlRequest.httpMethod = "POST"
            urlRequest.httpBody = try? JSONEncoder().encode(param)
            
            return urlRequest
            
        case let .sendPushNotification(param, apiKey):
            var components = URLComponents()
            components.scheme = baseURL.scheme
            components.host = baseURL.host
            components.path = baseURL.path
            
            var urlRequest = URLRequest(url: components.url!)
            urlRequest.httpMethod = "POST"
            urlRequest.httpBody = try? JSONEncoder().encode(param)
            urlRequest.setValue("Basic \(apiKey)", forHTTPHeaderField: "Authorization")
            urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            return urlRequest

        case let .profile(username):
            var components = URLComponents()
            components.scheme = baseURL.scheme
            components.host = baseURL.host
            components.path = baseURL.path + "/profile/username"

            components.queryItems = [
                .init(name: "value", value: username)
            ].compactMap { $0 }

            return URLRequest(url: components.url!)

        case let .allowCall(param):
            var components = URLComponents()
            components.scheme = baseURL.scheme
            components.host = baseURL.host
            components.path = baseURL.path + "/account/mutual"

            components.queryItems = [
                .init(name: "targetAccountId", value: param.targetAccountId)
            ].compactMap { $0 }

            return URLRequest(url: components.url!)

        }
    }
}

