import Foundation

public protocol NotificationFollowUserLoader {
    typealias ResultFollowUser = Swift.Result<Void, Error>
    
    func load(request: NotificationFollowUserRequest, completion: @escaping (ResultFollowUser) -> Void)
}
