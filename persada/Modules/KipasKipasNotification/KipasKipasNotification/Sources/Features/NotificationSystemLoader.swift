import Foundation

public protocol NotificationSystemLoader {
    typealias ResultSystem = Swift.Result<NotificationSystemItem ,Error>
    typealias ResultSystemUnread = Swift.Result<NotificationSystemUnreadItem ,Error>
    typealias ResultSystemIsRead = Swift.Result<NotificationDefaultResponse ,Error>
    
    func load(request: NotificationSystemRequest, completion: @escaping (ResultSystem) -> Void)
    func read(request: NotificationSystemIsReadRequest, types: String, completion: @escaping (ResultSystemIsRead) -> Void)
    func unread(request: NotificationSystemUnreadRequest, types: String, completion: @escaping (ResultSystemUnread) -> Void)
}
