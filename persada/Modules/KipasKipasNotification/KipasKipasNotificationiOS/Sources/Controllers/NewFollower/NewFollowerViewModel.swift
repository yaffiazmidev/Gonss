//
//  NewFollowerViewModel.swift
//  KipasKipasNotificationiOS
//
//  Created by DENAZMI on 21/03/24.
//

import Foundation
import KipasKipasNotification
import KipasKipasDirectMessage
import SendbirdChatSDK

public protocol INewFollowerViewModel: AnyObject {
    var newFollowersCurrentPage: Int { get set }
    var suggestionAccountCurrentPage: Int { get set }
    var newFollowersTotalPage: Int { get set }
    var suggestionAccountTotalPage: Int { get set }
    var newFollowers: [NotificationFollowersContent] { get set }
    
    func fetchNewFollowers()
    func fetchSuggestionAccount()
    func followAccount(by id: String)
    func unfollowAccount(by id: String)
    func readNotif()
}

public protocol NewFollowerViewModelViewModelDelegate: AnyObject {
    func displaySuccessUpdateFollowAccount(with id: String)
    func displayNewFollowers(with items: [NotificationFollowersContent])
    func displaySuggestionAccount(with items: [NotificationSuggestionAccountItem])
    func displayError(with message: String)
}

public class NewFollowerViewModelViewModel: INewFollowerViewModel {
    
    public weak var delegate: NewFollowerViewModelViewModelDelegate?
    private let newFollowersLoader: NotificationFollowersLoader
    private let suggestionAccountLoader: NotificationSuggestionAccountLoader
    private let followUserLoader: NotificationFollowUserLoader
    private let readUpdater: NotificationReadUpdater
    
    public var newFollowersCurrentPage: Int = 0
    public var suggestionAccountCurrentPage: Int = 0
    public var newFollowersTotalPage: Int = 0
    public var suggestionAccountTotalPage: Int = 0
    public var newFollowers: [NotificationFollowersContent] = []
    
    public init(
        newFollowersLoader: NotificationFollowersLoader,
        suggestionAccountLoader: NotificationSuggestionAccountLoader,
        followUserLoader: NotificationFollowUserLoader,
        readUpdater: NotificationReadUpdater
    ) {
        self.newFollowersLoader = newFollowersLoader
        self.suggestionAccountLoader = suggestionAccountLoader
        self.followUserLoader = followUserLoader
        self.readUpdater = readUpdater
    }
    
    public func fetchNewFollowers() {
        let request = NotificationFollowersRequest(
            page: newFollowersCurrentPage,
            size: 10
        )
        
        newFollowersLoader.load(request: request) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .failure(let error):
                self.delegate?.displayError(with: error.localizedDescription)
            case .success(let response):
                self.newFollowersTotalPage = (response.totalPages ?? 0) - 1
                self.newFollowers = response.content
                self.delegate?.displayNewFollowers(with: response.content)
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
        readUpdater.update(.init(type: .newFollower)) { result in
            switch result {
            case let .failure(error):
                print("Failed read new followers notification with error: \(error.localizedDescription)")
            case .success(_):
                print("Success read new followers notification..")
                NotificationCenter.default.post(name: Notification.Name("com.kipaskipas.updateNotificationCounterBadge"), object: nil)
            }
        }
    }
}
