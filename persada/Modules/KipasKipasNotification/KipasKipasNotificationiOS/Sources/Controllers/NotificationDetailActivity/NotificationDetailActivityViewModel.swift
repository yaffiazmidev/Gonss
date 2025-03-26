//
//  NotificationDetailActivityViewModel.swift
//  KipasKipasNotificationiOS
//
//  Created by DENAZMI on 05/04/24.
//

import Foundation
import KipasKipasNotification
import KipasKipasDirectMessage
import SendbirdChatSDK

public protocol INotificationDetailActivityViewModel: AnyObject {
    var activitiesCurrentPage: Int { get set }
    var activitiesTotalPage: Int { get set }
    var isSuccessReadActivity: Bool { get set }
    var activity: NotificationActivitiesItem { get set }
    
    func followAccount(by id: String)
    func unfollowAccount(by id: String)
    func readActivity(by id: String)
    func fetchActivitiesDetail()
}

public protocol NotificationDetailActivityViewModelDelegate: AnyObject {
    func displaySuccessUpdateFollowAccount(with id: String)
    func displayActivities(with items: [NotificationSuggestionAccountItem])
    func displayError(with message: String)
}

public class NotificationDetailActivityViewModel: INotificationDetailActivityViewModel {
    
    public weak var delegate: NotificationDetailActivityViewModelDelegate?
    private let followUserLoader: NotificationFollowUserLoader
    private let isReadChecker: NotificationActivitiesIsReadCheck
    private let activitiesDetailLoader: NotificationActivitiesDetailLoader
    
    
    public var activitiesCurrentPage: Int = 0
    public var activitiesTotalPage: Int = 0
    public var isSuccessReadActivity: Bool = false
    public var activity: NotificationActivitiesItem
    
    public init(
        followUserLoader: NotificationFollowUserLoader,
        isReadChecker: NotificationActivitiesIsReadCheck,
        activitiesDetailLoader: NotificationActivitiesDetailLoader,
        activity: NotificationActivitiesItem
    ) {
        self.followUserLoader = followUserLoader
        self.isReadChecker = isReadChecker
        self.activitiesDetailLoader = activitiesDetailLoader
        self.activity = activity
    }
    
    public func followAccount(by id: String) {
        let request = NotificationFollowUserRequest(id: id, action: .follow)
        followUserLoader.load(request: request) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .failure(let error):
                self.delegate?.displayError(with: error.localizedDescription)
            case .success(_):
                self.delegate?.displaySuccessUpdateFollowAccount(with: id)
            }
        }
    }
    
    public func unfollowAccount(by id: String) {
        let request = NotificationFollowUserRequest(id: id, action: .unfollow)
        followUserLoader.load(request: request) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .failure(let error):
                self.delegate?.displayError(with: error.localizedDescription)
            case .success(_):
                self.delegate?.displaySuccessUpdateFollowAccount(with: id)
            }
        }
    }
    
    public func readActivity(by id: String) {
        let request = NotificationActivitiesIsReadRequest(isRead: true, notificationId: id)
        isReadChecker.check(request: request) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .failure(_):
                self.isSuccessReadActivity = false
            case .success(_):
                self.isSuccessReadActivity = true
            }
        }
    }
    
    public func fetchActivitiesDetail() {
        let request = NotificationActivitiesDetailRequest(
            page: activitiesCurrentPage,
            actionType: activity.actionType,
            targetType: activity.targetType,
            targetId: activity.targetId,
            targetAccountId: activity.targetAccountId
        )
        
        activitiesDetailLoader.load(request: request) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .failure(let error):
                self.delegate?.displayError(with: error.localizedDescription)
            case .success(let response):
                self.activitiesTotalPage = (response.totalPages ?? 0) - 1
                self.delegate?.displayActivities(with: response.content)
            }
        }
    }
}
