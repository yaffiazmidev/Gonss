import Foundation
import KipasKipasStory

public class NotificationServiceFactory: NotificationDelegate {
    
    private let story: NotificationStoryControllerDelegate
    private let activities: NotificationActivitiesControllerDelegate
    private let followers: NotificationFollowersControllerDelegate
    private let systemNotif: NotificationSystemControllerDelegate
    private let transaction: NotificationTransactionControllerDelegate
    private let followUser: NotificationFollowUserControllerDelegate
    
    public init(story: NotificationStoryControllerDelegate, activities: NotificationActivitiesControllerDelegate, followers: NotificationFollowersControllerDelegate, systemNotif: NotificationSystemControllerDelegate, transaction: NotificationTransactionControllerDelegate, followUser: NotificationFollowUserControllerDelegate) {
        self.story = story
        self.activities = activities
        self.followers = followers
        self.systemNotif = systemNotif
        self.transaction = transaction
        self.followUser = followUser
    }
    
    
    public func didRequestStory(request: StoryListRequest) {
        story.didRequestStory(request: request)
    }
    
    public func didRequestFollowers(request: NotificationFollowersRequest) {
        followers.didRequestFollowers(request: request)
    }
    
    public func didRequestActivities(request: NotificationActivitiesRequest) {
        activities.didRequestActivities(request: request)
    }
    
    public func didRequestSystems(request: NotificationSystemRequest) {
        systemNotif.didRequestSystems(request: request)
    }
    
    public func didRequestTransaction(request: NotificationTransactionRequest) {
        transaction.didRequestTransaction(request: request)
    }
    
    public func didRequestFollowUser(request: NotificationFollowUserRequest) {
        followUser.didRequestFollowUser(request: request)
    }
    
    public func didRequestSystemIsRead(request: NotificationSystemIsReadRequest, types: String) {
        systemNotif.didRequestSystemIsRead(request: request, types: types)
    }
    
    public func didRequestSystemUnread(request: NotificationSystemUnreadRequest, types: String) {
        systemNotif.didRequestSystemUnread(request: request, types: types)
    }
    
}
