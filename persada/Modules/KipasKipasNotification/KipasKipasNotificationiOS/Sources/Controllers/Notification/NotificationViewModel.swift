//
//  NotificationViewModel.swift
//  KipasKipasNotificationiOS
//
//  Created by DENAZMI on 21/03/24.
//

import Foundation
import KipasKipasNotification
import KipasKipasDirectMessage
import SendbirdChatSDK
import KipasKipasStory

public protocol INotificationViewModel: AnyObject {
    var suggestAccountCurrentPage: Int { get set }
    var suggestAccountTotalPage: Int { get set }
    var storyPage: Int { get set }
    
    func fetchActivities()
    func fetchMessages()
    func fetchSuggestionAccount()
    func fetchSystemNotif()
    func fetchLastTransaction()
    func loadMoreMessages()
    func fetchNotifUnread()
    func fetchStories(reset: Bool)
}

public protocol NotificationViewModelDelegate: AnyObject {
    func displaySuccessUpdateFollowAccount(with id: String)
    func displayLastActivity(with item: NotificationActivitiesItem?)
    func displayDirectMessage(with channels: [GroupChannel])
    func displayErrorFetchDirectMessage(with error: SBError)
    func displaySuggestionAccount(with items: [NotificationSuggestionAccountItem])
    func displayLastSystemNotif(with item: NotificationSystemContent?)
    func displayLastTransaction(with item: NotificationTransactionItem?)
    func displayError(with message: String)
    func displayNoInternetConnection()
    func displayNotifUnread(item: NotificationUnreadItem)
    func displayStories(with data: StoryData)
}

public class NotificationViewModel: INotificationViewModel {
    
    public weak var delegate: NotificationViewModelDelegate?
    private let activitiesLoader: NotificationActivitiesLoader
    private let suggestionAccountLoader: NotificationSuggestionAccountLoader
    private let systemNotifLoader: NotificationSystemLoader
    private let transactionLoader: NotificationTransactionLoader
    private let followUserLoader: NotificationFollowUserLoader
    private let unreadsLoader: NotificationUnreadLoader
    private let storyListLoader: StoryListInteractor
    
    var channels: [GroupChannel] = []
    public var suggestAccountCurrentPage: Int = 0
    public var suggestAccountTotalPage: Int = 0
    public var storyPage: Int = 0
    
    private lazy var channelsUseCase: GroupChannelListUseCase = {
        let useCase = GroupChannelListUseCase()
        useCase.delegate = self
        return useCase
    }()
    
    public init(
        activitiesLoader: NotificationActivitiesLoader,
        suggestionAccountLoader: NotificationSuggestionAccountLoader,
        systemNotifLoader: NotificationSystemLoader,
        transactionLoader: NotificationTransactionLoader,
        followUserLoader: NotificationFollowUserLoader,
        unreadsLoader: NotificationUnreadLoader,
        storyListLoader: StoryListInteractor
    ) {
        self.activitiesLoader = activitiesLoader
        self.suggestionAccountLoader = suggestionAccountLoader
        self.systemNotifLoader = systemNotifLoader
        self.transactionLoader = transactionLoader
        self.followUserLoader = followUserLoader
        self.unreadsLoader = unreadsLoader
        self.storyListLoader = storyListLoader
    }
    
    public func fetchActivities() {
        guard ReachabilityNetwork.isConnectedToNetwork() else {
            delegate?.displayNoInternetConnection()
            return
        }
        
        let request = NotificationActivitiesRequest(page: 0, size: 1)
        activitiesLoader.load(request: request) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .failure(let error):
                self.delegate?.displayError(with: error.localizedDescription)
            case .success(let response):
                self.delegate?.displayLastActivity(with: response.content.first)
            }
        }
    }
    
    public func fetchMessages() {
        guard ReachabilityNetwork.isConnectedToNetwork() else {
            delegate?.displayNoInternetConnection()
            return
        }
        
        channelsUseCase.reloadChannels(limit: 3)
    }
    
    public func loadMoreMessages() {
        guard ReachabilityNetwork.isConnectedToNetwork() else {
            delegate?.displayNoInternetConnection()
            return
        }
        
        channelsUseCase.loadNextPage()
    }
    
    public func fetchSuggestionAccount() {
        guard ReachabilityNetwork.isConnectedToNetwork() else {
            delegate?.displayNoInternetConnection()
            return
        }
        
        let request = NotificationSuggestionAccountRequest(page: suggestAccountCurrentPage, size: 10)
        suggestionAccountLoader.load(request: request) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .failure(let error):
                self.delegate?.displayError(with: error.localizedDescription)
            case .success(let response):
                self.suggestAccountTotalPage = (response.totalPages ?? 0) - 1
                self.delegate?.displaySuggestionAccount(with: response.content)
            }
        }
    }
    
    public func fetchSystemNotif() {
        guard ReachabilityNetwork.isConnectedToNetwork() else {
            delegate?.displayNoInternetConnection()
            return
        }
        
        let request = NotificationSystemRequest(page: 0, size: 1, types: "live")
        systemNotifLoader.load(request: request) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .failure(let error):
                self.delegate?.displayError(with: error.localizedDescription)
            case .success(let response):
                self.delegate?.displayLastSystemNotif(with: response.content.first)
            }
        }
    }
    
    public func fetchLastTransaction() {
        guard ReachabilityNetwork.isConnectedToNetwork() else {
            delegate?.displayNoInternetConnection()
            return
        }
        
        let request = NotificationTransactionRequest(page: 0, size: 1, types: "Coin")
        transactionLoader.load(request: request) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .failure(let error):
                self.delegate?.displayError(with: error.localizedDescription)
            case .success(let response):
                self.delegate?.displayLastTransaction(with: response.content.first)
            }
        }
    }
    
    public func followAccount(by id: String) {
        guard ReachabilityNetwork.isConnectedToNetwork() else {
            delegate?.displayNoInternetConnection()
            return
        }
        
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
        guard ReachabilityNetwork.isConnectedToNetwork() else {
            delegate?.displayNoInternetConnection()
            return
        }
        
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
    
    public func fetchNotifUnread() {
        unreadsLoader.load { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .failure(let error):
                print(error.localizedDescription)
            case .success(let response):
                self.delegate?.displayNotifUnread(item: response)
            }
        }
    }
    
    public func fetchStories(reset: Bool) {
        guard ReachabilityNetwork.isConnectedToNetwork() else {
            delegate?.displayNoInternetConnection()
            return
        }
        
        let loadPage = reset ? 0 : storyPage + 1
        storyListLoader.load(.init(page: loadPage)) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let data): 
                self.storyPage = loadPage
                self.delegate?.displayStories(with: data)
            case .failure(let error):
                print("Story error", error.localizedDescription)
            }
        }
    }
}

extension NotificationViewModel: GroupChannelListUseCaseDelegate {
    
    public func groupChannelListUseCase(_ groupChannelListUseCase: GroupChannelListUseCase, 
                                        didReceiveError error: SBError) {
        delegate?.displayErrorFetchDirectMessage(with: error)
    }
    
    public func groupChannelListUseCase(_ groupChannelListUseCase: GroupChannelListUseCase, 
                                        didUpdateChannels: [GroupChannel]) {
        
        let newChannels = didUpdateChannels.reduce(into: [GroupChannel]()) { uniqueChannels, channel in
            if !uniqueChannels.contains(channel) {
                uniqueChannels.append(channel)
            }
        }
        delegate?.displayDirectMessage(with: newChannels)
    }
}
