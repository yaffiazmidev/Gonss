//
//  HotNewsRouter.swift
//  KipasKipasFeed
//
//  Created by DENAZMI on 04/10/23.
//

import Foundation
import KipasKipasNetworking
import KipasKipasStory
import KipasKipasStoryiOS

public protocol IHotNewsRouter {
	func presentLoginPopUp(onDismiss: (() -> Void)?)
    func presentComment(feed: FeedItem?)
    func presentShare(feed: FeedItem?)
    func presentProfile(feed: FeedItem?)
    func presentNewsPortal(url: String)
    func presentHashtag(feed: FeedItem?, value: String?)
    func presentMention(id: String?, type: String?)
    func presentDonationNow(feed: FeedItem?)
    func presentDonationCart(feed: FeedItem?)
    func presentDonationFilterCategory(id: String?)
    func presentShortcutStartPaidDM(feed: FeedItem?)
    func presentIconFollow(feed: FeedItem?)
    func presentProductDetail(feed: FeedItem?)
    func gotoLiveStreamingList()
    func presentPublicEmptyPopup()
    func presentFloatingLink(url: String)
    func presentContentSetting(feed: FeedItem?)
    func presentStories(feedItems: [FeedItem])
    func presentBookmark(feed: FeedItem?)
    func presentDonateStuff(feed: FeedItem?)
    func presentSingleFeed(feedId: String)
    
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

public class HotNewsRouter: IHotNewsRouter {
    private weak var controller: IHotNewsViewController?
    
    public init(controller: IHotNewsViewController?) {
        self.controller = controller
    }
    
    public func presentLoginPopUp(onDismiss: (() -> Void)?) {}
    public func presentComment(feed: FeedItem?) {}
    public func presentShare(feed: FeedItem?) {}
    public func presentProfile(feed: FeedItem?) {}
    public func presentNewsPortal(url: String) {}
    public func presentHashtag(feed: FeedItem?, value: String?) {}
    public func presentMention(id: String?, type: String?) {}
    public func presentDonationNow(feed: FeedItem?) {}
    public func presentDonationCart(feed: FeedItem?) {}
    public func presentDonationFilterCategory(id: String?) {}
    public func presentShortcutStartPaidDM(feed: FeedItem?) {}
    public func presentIconFollow(feed: FeedItem?) {}
    public func presentProductDetail(feed: FeedItem?) {}
    public func gotoLiveStreamingList() {}
    public func presentPublicEmptyPopup() {}
    public func presentFloatingLink(url: String) {}
    public func presentContentSetting(feed: FeedItem?) {}
    public func presentStories(feedItems: [FeedItem]) {}
    public func presentBookmark(feed: FeedItem?) {}
    public func presentDonateStuff(feed: FeedItem?) {}
    public func presentSingleFeed(feedId: String) {}
    
    //Story
    public func presentMyStory(item: StoryFeed, data: StoryData, otherStories: [StoryFeed]) {}
    public func presentStoryLive() {}
    public func presentOtherStory(item: StoryFeed, data: StoryData, otherStories: [StoryFeed]) {}
    public func storyDidAdd() {}
    public func storyDidRetry() {}
    public func storyUploadProgress() -> Double? { nil }
    public func storyOnUpload() -> Bool? { nil }
    public func storyOnError() -> Bool? { nil }
}

extension HotNewsRouter {
    public static func create(
        loader: HotnewsLoader,
        storyListLoader: StoryListInteractorAdapter? = nil,
        baseUrl: String,
        authToken: String?,
        feedType: FeedType,
        isLogin: Bool,
        page: Int,
        profileId: String,
        selectedFeedId: String,
        alreadyLoadFeeds: [FeedItem],
        mediaType: FeedMediaType? = nil,
        channelId: String = "",
        searchKeyword: String = "",
        totalFollowing: Int,
        isForSingleFeed: Bool = false
    ) -> IHotNewsViewController {
        let controller = HotNewsViewController(feedType: feedType)
        let router = HotNewsRouter(controller: controller)
        let presenter = HotNewsPresenter(controller: controller)
        
        let network = DIContainer.shared.apiAUTHDTS(
            baseUrl: baseUrl,
            authToken: authToken
        )
        
        let interactor = HotNewsInteractor(
            loader: loader,
            storyListLoader: storyListLoader,
            presenter: presenter,
            network: network,
            feedType: feedType,
            isLogin: isLogin,
            mediaType: mediaType, 
            totalFollowing: totalFollowing
        )
        
        interactor.page = page
        interactor.profileId = profileId
        interactor.selectedFeedId = selectedFeedId
        interactor.alreadyLoadFeeds = alreadyLoadFeeds
        interactor.channelId = channelId
        interactor.searchKeyword = searchKeyword
        interactor.isForSingleFeed = isForSingleFeed
        
        controller.router = router
        controller.interactor = interactor
        
        return controller
    }
    
    public static func createHotRoom(
        loader: HotnewsLoader,
        baseUrl: String,
        authToken: String?,
        feedType: FeedType,
        isLogin: Bool,
        page: Int,
        profileId: String,
        selectedFeedId: String,
        alreadyLoadFeeds: [FeedItem],
        mediaType: FeedMediaType? = nil,
        channelId: String = "",
        searchKeyword: String = "",
        totalFollowing: Int,
        isForSingleFeed: Bool = false,
        isFromPushFeed : Bool = false
    ) -> IHotNewsViewController {
        let controller = HotRoomViewController(feedType: feedType)
        controller.isFromPushFeed = isFromPushFeed
        let router = HotNewsRouter(controller: controller)
        let presenter = HotNewsPresenter(controller: controller)
        
        let network = DIContainer.shared.apiAUTHDTS(
            baseUrl: baseUrl,
            authToken: authToken
        )
        
        let interactor = HotNewsInteractor(
            loader: loader,
            presenter: presenter,
            network: network,
            feedType: feedType,
            isLogin: isLogin,
            mediaType: mediaType,
            totalFollowing: totalFollowing
        )
        
        interactor.page = page
        interactor.profileId = profileId
        interactor.selectedFeedId = selectedFeedId
        interactor.alreadyLoadFeeds = alreadyLoadFeeds
        interactor.channelId = channelId
        interactor.searchKeyword = searchKeyword
        interactor.isForSingleFeed = isForSingleFeed
        
        controller.router = router
        controller.interactor = interactor
        
        return controller
    }

}
