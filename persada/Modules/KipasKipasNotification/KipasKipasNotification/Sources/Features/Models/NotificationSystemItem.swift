import Foundation

public struct NotificationSystemContent {
    public let id: String
    public let types, title, subTitle, targetId: String
    public let createdAt: Int
    public let targetAccountId: String
    public var isRead: Bool
    
    public init(
        id: String = "",
        types: String = "",
        title: String = "",
        subTitle: String = "",
        targetId: String = "",
        createdAt: Int = 0,
        targetAccountId: String = "",
        isRead: Bool = false
    ) {
        self.id = id
        self.types = types
        self.title = title
        self.subTitle = subTitle
        self.targetId = targetId
        self.createdAt = createdAt
        self.targetAccountId = targetAccountId
        self.isRead = isRead
    }
}

public struct NotificationSystemItem {
    public let content: [NotificationSystemContent]
    public var totalPages: Int?
}
