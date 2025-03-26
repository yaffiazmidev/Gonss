import Foundation

public protocol NotificationFollowersLoader {
    typealias ResultFollowers = Swift.Result<NotificationFollowersItem, Error>
    
    func load(request: NotificationFollowersRequest, completion: @escaping (ResultFollowers) -> Void )
}
