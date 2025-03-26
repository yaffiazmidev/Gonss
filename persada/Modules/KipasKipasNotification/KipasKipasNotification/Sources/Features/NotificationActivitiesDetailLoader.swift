import Foundation

public protocol NotificationActivitiesDetailLoader {
    typealias ResultActivitiesDetail = Swift.Result<NotificationSuggestionAccountContent, Error>
    
    func load(request: NotificationActivitiesDetailRequest, completion: @escaping (ResultActivitiesDetail) -> Void )
}
