import Foundation

public protocol NotificationActivitiesLoader {
    typealias ResultActivities = Swift.Result<NotificationActivitiesContent, Error>
    
    func load(request: NotificationActivitiesRequest, completion: @escaping (ResultActivities) -> Void )
}
