import Foundation
import KipasKipasStory

public protocol NotificationStoryControllerDelegate {
    func didRequestStory(request: StoryListRequest)
}

public protocol NotificationActivitiesControllerDelegate {
    func didRequestActivities(request: NotificationActivitiesRequest)
}

public protocol NotificationActivitiesDetailControllerDelegate {
    func didRequestActivitiesDetail(request: NotificationActivitiesDetailRequest)
}

public protocol NotificationActivitiesIsReadControllerDelegate {
    func didRequestActivitiesIsRead(request: NotificationActivitiesIsReadRequest)
}

public protocol NotificationFollowersControllerDelegate {
    func didRequestFollowers(request: NotificationFollowersRequest)
}

public protocol NotificationSystemControllerDelegate {
    func didRequestSystems(request: NotificationSystemRequest)
    func didRequestSystemIsRead(request: NotificationSystemIsReadRequest, types: String)
    func didRequestSystemUnread(request: NotificationSystemUnreadRequest, types: String)
}

public protocol NotificationTransactionControllerDelegate {
    func didRequestTransaction(request: NotificationTransactionRequest)
}

public protocol NotificationFollowUserControllerDelegate {
    func didRequestFollowUser(request: NotificationFollowUserRequest)
}

public typealias NotificationDelegate = NotificationStoryControllerDelegate & NotificationActivitiesControllerDelegate & NotificationFollowersControllerDelegate & NotificationSystemControllerDelegate & NotificationTransactionControllerDelegate & NotificationFollowUserControllerDelegate
