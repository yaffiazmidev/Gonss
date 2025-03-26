import Foundation
public struct NotificationSystemUnreadItem: Codable, Equatable {
    public let code, message: String
    public let data: NotificationSystemReadData
}

public struct NotificationSystemReadData: Codable, Equatable {
    public let hasUnreadNotifications: Bool
}
