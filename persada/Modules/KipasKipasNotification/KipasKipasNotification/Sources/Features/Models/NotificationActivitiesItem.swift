import Foundation
public struct NotificationActivitiesContent {
    public let content: [NotificationActivitiesItem]
    public var totalPages: Int?
}
public struct NotificationActivitiesItem {
    public let notificationid: String
    public let id: String
    public let name: String
    public let actionType: String
    public let targetType: String
    public let value: String
    public var isRead: Bool
    public let targetAccountId: String
    public let targetAccountName: String
    public let targetAccountPhoto: String
    public let targetId: String
    public let feedId: String
    public let thumbnailUrl: String
    public let createDate: String
    public let createAt: Int
    public let groupHour: String
    public let firstId: String
    public let firstName: String
    public let firstPhoto: String
    public let secondId: String
    public let secondName: String
    public let secondPhoto: String
    public let other: Int
    public let actionAccountId: String
    public let actionAccountName: String
    public let actionAccountPhoto: String
    public let modifiedAt: Int
}
