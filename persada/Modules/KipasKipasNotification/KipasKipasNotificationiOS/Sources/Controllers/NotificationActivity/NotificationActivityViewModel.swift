//
//  NotificationActivityViewModel.swift
//  KipasKipasNotificationiOS
//
//  Created by DENAZMI on 27/03/24.
//

import Foundation
import KipasKipasNotification
import KipasKipasDirectMessage
import SendbirdChatSDK

public protocol INotificationActivityViewModel: AnyObject {
    var activitiesCurrentPage: Int { get set }
    var suggestionAccountCurrentPage: Int { get set }
    var activitiesTotalPage: Int { get set }
    var suggestionAccountTotalPage: Int { get set }
    var activities: [NotificationActivitiesItem] { get set }
    
    func fetchActivities()
    func fetchSuggestionAccount()
    func followAccount(by id: String)
    func unfollowAccount(by id: String)
    func readNotif()
}

public protocol NotificationActivityViewModelDelegate: AnyObject {
    func displaySuccessUpdateFollowAccount(with id: String)
    func displayActivities(with items: [NotificationActivitiesItem])
    func displaySuggestionAccount(with items: [NotificationSuggestionAccountItem])
    func displayError(with message: String)
}

public class NotificationActivityViewModel: INotificationActivityViewModel {
    
    public weak var delegate: NotificationActivityViewModelDelegate?
    private let activitiesLoader: NotificationActivitiesLoader
    private let suggestionAccountLoader: NotificationSuggestionAccountLoader
    private let followUserLoader: NotificationFollowUserLoader
    private let readUpdater: NotificationReadUpdater
    
    public var activitiesCurrentPage: Int = 0
    public var suggestionAccountCurrentPage: Int = 0
    public var activitiesTotalPage: Int = 0
    public var suggestionAccountTotalPage: Int = 0
    public var activities: [NotificationActivitiesItem] = []
    
    public init(
        activitiesLoader: NotificationActivitiesLoader,
        suggestionAccountLoader: NotificationSuggestionAccountLoader,
        followUserLoader: NotificationFollowUserLoader,
        readUpdater: NotificationReadUpdater
    ) {
        self.activitiesLoader = activitiesLoader
        self.suggestionAccountLoader = suggestionAccountLoader
        self.followUserLoader = followUserLoader
        self.readUpdater = readUpdater
    }
    
    public func fetchActivities() {
        let request = NotificationActivitiesRequest(
            page: activitiesCurrentPage,
            size: 10
        )
        activitiesLoader.load(request: request) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .failure(let error):
                self.delegate?.displayError(with: error.localizedDescription)
            case .success(let response):
                self.activitiesTotalPage = (response.totalPages ?? 0) - 1
                
                if activitiesCurrentPage == 0 {
                    self.activities = response.content
                }
                
                self.delegate?.displayActivities(with: response.content)
            }
        }
    }
    
    public func fetchSuggestionAccount() {
        let request = NotificationSuggestionAccountRequest(page: suggestionAccountCurrentPage, size: 10)
        suggestionAccountLoader.load(request: request) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .failure(let error):
                self.delegate?.displayError(with: error.localizedDescription)
            case .success(let response):
                self.suggestionAccountTotalPage = (response.totalPages ?? 0) - 1
                self.delegate?.displaySuggestionAccount(with: response.content)
            }
        }
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
    
    public func readNotif() {
        readUpdater.update(.init(type: .activity)) { result in
            switch result {
            case let .failure(error):
                print("Failed read activity notification with error: \(error.localizedDescription)")
            case .success(_):
                print("Success read activity notification..")
                NotificationCenter.default.post(name: Notification.Name("com.kipaskipas.updateNotificationCounterBadge"), object: nil)
            }
        }
    }
}
