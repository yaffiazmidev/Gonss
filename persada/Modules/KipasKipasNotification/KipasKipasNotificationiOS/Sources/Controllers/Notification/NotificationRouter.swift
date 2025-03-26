//
//  NotificationRouter.swift
//  KipasKipasNotificationiOS
//
//  Created by DENAZMI on 21/03/24.
//

import Foundation
import KipasKipasNotification
import UIKit
import KipasKipasDonationTransactionDetail
import KipasKipasStory
import KipasKipasStoryiOS

public protocol INotificationRouter: AnyObject {
    func navigateToNewFollowers()
    func navigateToNotifSystem()
    func navigateToActivities()
    func navigateToConversation(id: String)
    func navigateToTransactions()
    func navigateToUserProfile(by id: String)
    func presentPreferences()
    
    // story
    func presentMyStory(
        item: StoryFeed,
        data: StoryData,
        otherStories: [StoryFeed]
    )
    func presentStoryLive()
    func presentOtherStory(
        item: StoryFeed,
        data: StoryData,
        otherStories: [StoryFeed]
    )
    func storyDidAdd()
    func storyDidRetry()
    func storyUploadProgress() -> Double?
    func storyOnUpload() -> Bool?
    func storyOnError() -> Bool?
}

public class NotificationRouter: INotificationRouter {
    
    public weak var controller: NotificationController?
    private let systemNotifLoader: NotificationSystemLoader
    private let followersLoader: NotificationFollowersLoader
    private let transactionLoader: NotificationTransactionLoader
    private let suggestionAccountLoader: NotificationSuggestionAccountLoader
    private let activitiesLoader: NotificationActivitiesLoader
    private let followUserLoader: NotificationFollowUserLoader
    private let isReadChecker: NotificationActivitiesIsReadCheck
    private let activitiesDetailLoader: NotificationActivitiesDetailLoader
    private let preferencesLoader: NotificationPreferencesLoader
    private let preferencesUpdater: NotificationPreferencesUpdater
    private let transactionDetailLoader: NotificationTransactionDetailLoader
    private let donationOrderLoader: DonationTransactionDetailOrderLoader
    private let donationGroupLoader: DonationTransactionDetailGroupLoader
    private let isReadSystemChecker: NotificationSystemIsReadCheck
    private let unreadsLoader: NotificationUnreadLoader
    private let readUpdater: NotificationReadUpdater
    private let lotteryLoader: NotificationLotteryLoader
    
    private let handleShowConversation: ((String) -> Void)?
    private let handleShowUserProfile: ((String) -> Void)?
    private let handleShowFeed: ((String) -> Void)?
    private let handleShowSingleFeed: ((String) -> Void)?
    private let handleShowLive: ((String) -> Void)?
    private let handleShowLottery: ((String) -> Void)?
    private let handleShowCurrencyDetail: ((NotificationTransactionItemCurrency) -> Void)?
    private let handleShowWithdrawlDetail: ((NotificationWithdrawl) -> Void)?
    private let handleShowDonationGroupOrder: ((DonationTransactionDetailGroupItem?) -> Void)?
    
    // Story
    public struct StoryHandler {
        public let presentMyStory: ((StoryFeed, StoryData, [StoryFeed]) -> Void)?
        public let presentStoryLive: (() -> Void)?
        public let presentOtherStory: ((StoryFeed, StoryData, [StoryFeed]) -> Void)?
        public let addStory: (() -> Void)?
        public let retryUploadStory: (() -> Void)?
        public let uploadProgress: (() -> Double?)?
        public let onUpload: (() -> Bool?)?
        public let onError: (() -> Bool?)?
        
        public init(
            presentMyStory: ((StoryFeed, StoryData, [StoryFeed]) -> Void)?,
            presentStoryLive: (() -> Void)?,
            presentOtherStory: ((StoryFeed, StoryData, [StoryFeed]) -> Void)?,
            addStory: (() -> Void)?,
            retryUploadStory: (() -> Void)?,
            uploadProgress: (() -> Double?)?,
            onUpload: (() -> Bool?)?,
            onError: (() -> Bool?)?
        ) {
            self.presentMyStory = presentMyStory
            self.presentStoryLive = presentStoryLive
            self.presentOtherStory = presentOtherStory
            self.addStory = addStory
            self.retryUploadStory = retryUploadStory
            self.uploadProgress = uploadProgress
            self.onUpload = onUpload
            self.onError = onError
        }
    }
    private let storyHandler: StoryHandler
    
    public init(
        followersLoader: NotificationFollowersLoader,
        systemNotifLoader: NotificationSystemLoader,
        transactionLoader: NotificationTransactionLoader,
        suggestionAccountLoader: NotificationSuggestionAccountLoader,
        activitiesLoader: NotificationActivitiesLoader,
        followUserLoader: NotificationFollowUserLoader,
        isReadChecker: NotificationActivitiesIsReadCheck,
        activitiesDetailLoader: NotificationActivitiesDetailLoader,
        preferencesLoader: NotificationPreferencesLoader,
        preferencesUpdater: NotificationPreferencesUpdater,
        transactionDetailLoader: NotificationTransactionDetailLoader,
        donationOrderLoader: DonationTransactionDetailOrderLoader,
        donationGroupLoader: DonationTransactionDetailGroupLoader,
        isReadSystemChecker: NotificationSystemIsReadCheck,
        unreadsLoader: NotificationUnreadLoader,
        readUpdater: NotificationReadUpdater,
        lotteryLoader: NotificationLotteryLoader,
        handleShowConversation: ((String) -> Void)?,
        handleShowUserProfile: ((String) -> Void)?,
        handleShowFeed: ((String) -> Void)?,
        handleShowSingleFeed: ((String) -> Void)?,
        handleShowLive: ((String) -> Void)?,
        handleShowLottery: ((String) -> Void)?,
        handleShowCurrencyDetail: ((NotificationTransactionItemCurrency) -> Void)?,
        handleShowWithdrawlDetail: ((NotificationWithdrawl) -> Void)?,
        handleShowDonationGroupOrder: ((DonationTransactionDetailGroupItem?) -> Void)?,
        storyHandler: StoryHandler
    ) {
        self.followersLoader = followersLoader
        self.systemNotifLoader = systemNotifLoader
        self.transactionLoader = transactionLoader
        self.suggestionAccountLoader = suggestionAccountLoader
        self.activitiesLoader = activitiesLoader
        self.followUserLoader = followUserLoader
        self.isReadChecker = isReadChecker
        self.activitiesDetailLoader = activitiesDetailLoader
        self.preferencesLoader = preferencesLoader
        self.preferencesUpdater = preferencesUpdater
        self.transactionDetailLoader = transactionDetailLoader
        self.donationOrderLoader = donationOrderLoader
        self.donationGroupLoader = donationGroupLoader
        self.isReadSystemChecker = isReadSystemChecker
        self.unreadsLoader = unreadsLoader
        self.readUpdater = readUpdater
        self.lotteryLoader = lotteryLoader
        
        self.handleShowConversation = handleShowConversation
        self.handleShowUserProfile = handleShowUserProfile
        self.handleShowFeed = handleShowFeed
        self.handleShowSingleFeed = handleShowSingleFeed
        self.handleShowLive = handleShowLive
        self.handleShowLottery = handleShowLottery
        self.handleShowCurrencyDetail = handleShowCurrencyDetail
        self.handleShowWithdrawlDetail = handleShowWithdrawlDetail
        self.handleShowDonationGroupOrder = handleShowDonationGroupOrder
        
        // Story
        self.storyHandler = storyHandler
    }
    
    public func navigateToNewFollowers() {
        let viewModel = NewFollowerViewModelViewModel(
            newFollowersLoader: followersLoader,
            suggestionAccountLoader: suggestionAccountLoader,
            followUserLoader: followUserLoader,
            readUpdater: readUpdater
        )
        let vc = NewFollowerController(viewModel: viewModel)
        viewModel.delegate = vc
        vc.hidesBottomBarWhenPushed = true
        vc.handleShowConversation = handleShowConversation
        vc.handleShowUserProfile = handleShowUserProfile
        controller?.push(vc)
    }
    
    public func navigateToNotifSystem() {
        let viewModel = KKNotificationSystemViewModel(
            systemNotifLoader: systemNotifLoader,
            isReadChecker: isReadSystemChecker,
            readUpdater: readUpdater, 
            lotteryLoader: lotteryLoader
        )
        let router = KKNotificationSystemRouter(
            systemNotifLoader: systemNotifLoader,
            preferencesLoader: preferencesLoader,
            preferencesUpdater: preferencesUpdater
        )
        let vc = KKNotificationSystemController(viewModel: viewModel)
        vc.hidesBottomBarWhenPushed = true
        
        router.controller = vc
        viewModel.delegate = vc
        
        vc.router = router
        vc.showFeed = handleShowFeed
        vc.showLive = handleShowLive
        vc.showLottery = handleShowLottery
        
        controller?.push(vc)
    }
    
    private func makeContentController(types: String) -> UIViewController {
        let vc = NotificationSystemContentUIComposer.composeNotificationSystemWith(types: types, emptyMessage: "Belum ada notif", loader: systemNotifLoader, showFeed:  {_ in
            print("noor testing navigate feed")
        })
        return vc
    }
    
    public func navigateToActivities() {
        let activityController = NotificationActivityRouter.create(
            activitiesLoader: activitiesLoader,
            suggestionAccountLoader: suggestionAccountLoader,
            followUserLoader: followUserLoader,
            isReadChecker: isReadChecker,
            activitiesDetailLoader: activitiesDetailLoader,
            readUpdater: readUpdater,
            handleShowConversation: handleShowConversation,
            handleShowUserProfile: handleShowUserProfile,
            handleShowSingleFeed: handleShowSingleFeed
        )
        
        activityController.hidesBottomBarWhenPushed = true
        controller?.push(activityController)
    }
    
    public func navigateToConversation(id: String) {
        handleShowConversation?(id)
    }
    
    public func navigateToTransactions() {
        let vc = TransactionController(
            loader: transactionLoader,
            readUpdater: readUpdater
        )
        vc.hidesBottomBarWhenPushed = true
        
        let router = TransactionRouter(
            transactionDetailLoader: transactionDetailLoader,
            donationOrderLoader: donationOrderLoader,
            donationGroupLoader: donationGroupLoader,
            handleShowUserProfile: handleShowUserProfile,
            handleShowCurrencyDetail: handleShowCurrencyDetail,
            handleShowWithdrawlDetail: handleShowWithdrawlDetail,
            handleShowDonationGroupOrder: handleShowDonationGroupOrder
        )
        
        router.controller = vc
        vc.router = router
        
        controller?.push(vc)
    }
    
    public func navigateToUserProfile(by id: String) {
        handleShowUserProfile?(id)
    }
    
    public func presentPreferences() {
        let viewModel = NotificationSettingViewModel(
            preferencesLoader: preferencesLoader,
            preferencesUpdater: preferencesUpdater
        )
        
        let vc = NotificationSettingController(viewModel: viewModel)
        vc.modalPresentationStyle = .overFullScreen
        viewModel.delegate = vc
        controller?.present(vc, animated: false)
    }
}

// MARK: - Story
extension NotificationRouter {
    public func presentMyStory(
        item: StoryFeed,
        data: StoryData,
        otherStories: [StoryFeed]
    ) {
        storyHandler.presentMyStory?(item, data, otherStories)
    }
    
    public func presentStoryLive() {
        storyHandler.presentStoryLive?()
    }
    
    public func presentOtherStory(
        item: StoryFeed,
        data: StoryData,
        otherStories: [StoryFeed]
    ) {
        storyHandler.presentOtherStory?(item, data, otherStories)
    }
    
    public func storyDidAdd() {
        storyHandler.addStory?()
    }
    
    public func storyDidRetry() {
        storyHandler.retryUploadStory?()
    }
    
    public func storyUploadProgress() -> Double? {
        storyHandler.uploadProgress?()
    }
    
    public func storyOnUpload() -> Bool? {
        storyHandler.onUpload?()
    }
    
    public func storyOnError() -> Bool? {
        storyHandler.onError?()
    }
}

extension NotificationRouter {
    public static func create(
        followersLoader: NotificationFollowersLoader,
        systemNotifLoader: NotificationSystemLoader,
        transactionLoader: NotificationTransactionLoader,
        suggestionAccountLoader: NotificationSuggestionAccountLoader,
        activitiesLoader: NotificationActivitiesLoader,
        followUserLoader: NotificationFollowUserLoader,
        storyListLoader: StoryListInteractor,
        isReadChecker: NotificationActivitiesIsReadCheck,
        activitiesDetailLoader: NotificationActivitiesDetailLoader,
        preferencesLoader: NotificationPreferencesLoader,
        preferencesUpdater: NotificationPreferencesUpdater,
        transactionDetailLoader: NotificationTransactionDetailLoader,
        donationOrderLoader: DonationTransactionDetailOrderLoader,
        donationGroupLoader: DonationTransactionDetailGroupLoader,
        isReadSystemChecker: NotificationSystemIsReadCheck,
        unreadsLoader: NotificationUnreadLoader,
        readUpdater: NotificationReadUpdater,
        lotteryLoader: NotificationLotteryLoader,
        handleShowConversation: ((String) -> Void)?,
        handleShowUserProfile: ((String) -> Void)?,
        handleShowFeed: ((String) -> Void)?,
        handleShowSingleFeed: ((String) -> Void)?,
        handleShowLive: ((String) -> Void)?,
        handleShowLottery: ((String) -> Void)?,
        handleShowCurrencyDetail: ((NotificationTransactionItemCurrency) -> Void)?,
        handleShowWithdrawlDetail: ((NotificationWithdrawl) -> Void)?,
        handleShowDonationGroupOrder: ((DonationTransactionDetailGroupItem?) -> Void)?,
        storyHandler: StoryHandler
    ) -> (notif: NotificationController, transaction: TransactionController)  {
        let viewModel = NotificationViewModel(
            activitiesLoader: activitiesLoader,
            suggestionAccountLoader: suggestionAccountLoader,
            systemNotifLoader: systemNotifLoader,
            transactionLoader: transactionLoader,
            followUserLoader: followUserLoader,
            unreadsLoader: unreadsLoader,
            storyListLoader: storyListLoader
        )
        
        let router = NotificationRouter(
            followersLoader:  followersLoader,
            systemNotifLoader:  systemNotifLoader,
            transactionLoader: transactionLoader,
            suggestionAccountLoader: suggestionAccountLoader,
            activitiesLoader: activitiesLoader,
            followUserLoader: followUserLoader,
            isReadChecker: isReadChecker,
            activitiesDetailLoader: activitiesDetailLoader,
            preferencesLoader: preferencesLoader,
            preferencesUpdater: preferencesUpdater,
            transactionDetailLoader: transactionDetailLoader,
            donationOrderLoader: donationOrderLoader,
            donationGroupLoader: donationGroupLoader,
            isReadSystemChecker: isReadSystemChecker,
            unreadsLoader: unreadsLoader,
            readUpdater: readUpdater, 
            lotteryLoader: lotteryLoader,
            handleShowConversation: handleShowConversation,
            handleShowUserProfile: handleShowUserProfile,
            handleShowFeed: handleShowFeed,
            handleShowSingleFeed: handleShowSingleFeed,
            handleShowLive: handleShowLive, 
            handleShowLottery: handleShowLottery,
            handleShowCurrencyDetail: handleShowCurrencyDetail,
            handleShowWithdrawlDetail: handleShowWithdrawlDetail,
            handleShowDonationGroupOrder: handleShowDonationGroupOrder,
            storyHandler: storyHandler
        )
        
        let controller = NotificationController(viewModel: viewModel)
        controller.router = router
        
        viewModel.delegate = controller
        router.controller = controller
        
        let transaction = createTransactionController(
            transactionLoader: transactionLoader,
            donationOrderLoader: donationOrderLoader,
            donationGroupLoader: donationGroupLoader,
            transactionDetailLoader: transactionDetailLoader,
            readUpdater: readUpdater,
            handleShowUserProfile: handleShowUserProfile,
            handleShowCurrencyDetail: handleShowCurrencyDetail,
            handleShowWithdrawlDetail: handleShowWithdrawlDetail,
            handleShowDonationGroupOrder: handleShowDonationGroupOrder
        )
        return (controller, transaction)
    }
    
    public static func createTransactionController(
        transactionLoader: NotificationTransactionLoader,
        donationOrderLoader: DonationTransactionDetailOrderLoader,
        donationGroupLoader: DonationTransactionDetailGroupLoader,
        transactionDetailLoader: NotificationTransactionDetailLoader,
        readUpdater: NotificationReadUpdater,
        handleShowUserProfile: ((String) -> Void)?,
        handleShowCurrencyDetail: ((NotificationTransactionItemCurrency) -> Void)?,
        handleShowWithdrawlDetail: ((NotificationWithdrawl) -> Void)?,
        handleShowDonationGroupOrder: ((DonationTransactionDetailGroupItem?) -> Void)?
    ) -> TransactionController {
        let vc = TransactionController(
            loader: transactionLoader,
            readUpdater: readUpdater
        )
        vc.hidesBottomBarWhenPushed = true
        
        let router = TransactionRouter(
            transactionDetailLoader: transactionDetailLoader,
            donationOrderLoader: donationOrderLoader,
            donationGroupLoader: donationGroupLoader,
            handleShowUserProfile: handleShowUserProfile,
            handleShowCurrencyDetail: handleShowCurrencyDetail,
            handleShowWithdrawlDetail: handleShowWithdrawlDetail,
            handleShowDonationGroupOrder: handleShowDonationGroupOrder
        )
        
        router.controller = vc
        vc.router = router
        return vc
    }
}
