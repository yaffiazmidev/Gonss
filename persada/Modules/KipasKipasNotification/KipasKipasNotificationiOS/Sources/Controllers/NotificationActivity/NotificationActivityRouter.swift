//
//  NotificationActivityRouter.swift
//  KipasKipasNotificationiOS
//
//  Created by DENAZMI on 05/04/24.
//

import Foundation
import KipasKipasNotification

public protocol INotificationActivityRouter {
    func navigateToDetailActivity(with item: NotificationActivitiesItem)
    func navigateToConversation(id: String)
    func navigateToUserProfile(by id: String)
    func presentSingleFeed(by id: String)
}

public class NotificationActivityRouter: INotificationActivityRouter {
    
    public weak var controller: NotificationActivityController?
    private let suggestionAccountLoader: NotificationSuggestionAccountLoader
    private let followUserLoader: NotificationFollowUserLoader
    private let isReadChecker: NotificationActivitiesIsReadCheck
    private let activitiesDetailLoader: NotificationActivitiesDetailLoader
    
    private let handleShowConversation: ((String) -> Void)?
    private let handleShowUserProfile: ((String) -> Void)?
    private let handleShowSingleFeed: ((String) -> Void)?
    
    public init(
        suggestionAccountLoader: NotificationSuggestionAccountLoader,
        followUserLoader: NotificationFollowUserLoader,
        isReadChecker: NotificationActivitiesIsReadCheck,
        activitiesDetailLoader: NotificationActivitiesDetailLoader,
        handleShowConversation: ((String) -> Void)?,
        handleShowUserProfile: ((String) -> Void)?,
        handleShowSingleFeed: ((String) -> Void)?
    ) {
        self.suggestionAccountLoader = suggestionAccountLoader
        self.followUserLoader = followUserLoader
        self.isReadChecker = isReadChecker
        self.handleShowConversation = handleShowConversation
        self.handleShowUserProfile = handleShowUserProfile
        self.handleShowSingleFeed = handleShowSingleFeed
        self.activitiesDetailLoader = activitiesDetailLoader
    }
    
    public func navigateToDetailActivity(with item: NotificationActivitiesItem) {
        let viewModel = NotificationDetailActivityViewModel(
            followUserLoader: followUserLoader,
            isReadChecker: isReadChecker,
            activitiesDetailLoader: activitiesDetailLoader,
            activity: item
        )
        
        let vc = NotificationDetailActivityController(viewModel: viewModel)
        
        vc.hidesBottomBarWhenPushed = true
        viewModel.delegate = vc
        
        vc.handleShowSingleFeed = handleShowSingleFeed
        vc.handleShowConversation = handleShowConversation
        vc.handleShowUserProfile = handleShowUserProfile
        controller?.push(vc)
    }
    
    public func navigateToConversation(id: String) {
        handleShowConversation?(id)
    }
    
    public func navigateToUserProfile(by id: String) {
        handleShowUserProfile?(id)
    }
    
    public func presentSingleFeed(by id: String) {
        handleShowSingleFeed?(id)
    }
}

extension NotificationActivityRouter {
    static func create(
        activitiesLoader: NotificationActivitiesLoader,
        suggestionAccountLoader: NotificationSuggestionAccountLoader,
        followUserLoader: NotificationFollowUserLoader,
        isReadChecker: NotificationActivitiesIsReadCheck,
        activitiesDetailLoader: NotificationActivitiesDetailLoader,
        readUpdater: NotificationReadUpdater,
        handleShowConversation: ((String) -> Void)?,
        handleShowUserProfile: ((String) -> Void)?,
        handleShowSingleFeed: ((String) -> Void)?
    ) -> NotificationActivityController {
        
        let viewModel = NotificationActivityViewModel(
            activitiesLoader: activitiesLoader,
            suggestionAccountLoader: suggestionAccountLoader,
            followUserLoader: followUserLoader, 
            readUpdater: readUpdater
        )
        
        let router = NotificationActivityRouter(
            suggestionAccountLoader: suggestionAccountLoader,
            followUserLoader: followUserLoader,
            isReadChecker: isReadChecker,
            activitiesDetailLoader: activitiesDetailLoader,
            handleShowConversation: handleShowConversation,
            handleShowUserProfile: handleShowUserProfile,
            handleShowSingleFeed: handleShowSingleFeed
        )
        
        let controller = NotificationActivityController(viewModel: viewModel)
        controller.hidesBottomBarWhenPushed = true
        
        controller.router = router
        viewModel.delegate = controller
        router.controller = controller
        
        return controller
    }
}
