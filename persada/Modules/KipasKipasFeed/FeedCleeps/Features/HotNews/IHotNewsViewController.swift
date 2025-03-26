//
//  IHotNewsViewController.swift
//  FeedCleeps
//
//  Created by Administer on 2024/7/4.
//

import UIKit
import KipasKipasStory

public protocol IHotNewsViewController: UIViewController {
    func displayErrorGetFeeds(with message: String)
    func displayFeeds(with items: [FeedItem], totalItems: Int, isLogin: Bool)
    func displayErrorUpdateLike(with message: String)
    func displayUpdateLike()
    func displayMentionUserByUsername(id: String?, type: String?)
    func displayUpdateFollowAccount(id: String)
    func displayFeedTrendingCache(with item: FeedItem)
    func displayUpdateSingleFeed(with item: FeedItem)
    func displayFollowingSuggest(with items: [RemoteFollowingSuggestItem])
    func displayErrorSingleFeed(with message: String)

    func refreshDonation(categoryId: String)
    func requestUpdateIsFollow(accountId: String, isFollow: Bool)
    func requestDonationByProvince(id: String?)
    func requestDonationBylocation(latitude: Double?, longitude: Double?)
    func requestDonationAll()
    
    func updateIsFollow(accountId: String, isFollow: Bool)
    
    func expandStoryListView()
    func collapseStoryListView()
    
    func pauseIfNeeded()
    func resumeIfNeeded()
    func pullToRefresh()
    func pause()
    func resume()
    
    func setRouter(router: IHotNewsRouter)
    func updateDonationCampaign()
    
    var handleUpdateFeeds: (([FeedItem]) -> Void)? { get set }
    var handleLoadMyCurrency: (() -> Void)? { get set }
    var handleGetFeedForStories: (([FeedItem]) -> Void)? { get set }
    var handleUpdateLikes: ((FeedItem?) -> Void)? { get set }
    var viewsFeeds: [FeedItem] { get }
}


public protocol IHotStoryViewController: UIViewController {
    func displayStories(with data: StoryData)
    func expandStoryListView()
    func collapseStoryListView()
}

public protocol IHotViewController: IHotStoryViewController, IHotNewsViewController {}
