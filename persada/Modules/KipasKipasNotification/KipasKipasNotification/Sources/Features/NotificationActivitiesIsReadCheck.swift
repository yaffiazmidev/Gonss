import Foundation

public protocol NotificationActivitiesIsReadCheck {
    typealias ResultActivitiesIsRead = Swift.Result<NotificationDefaultResponse, Error>
    
    func check(request: NotificationActivitiesIsReadRequest, completion: @escaping (ResultActivitiesIsRead) -> Void )
}
