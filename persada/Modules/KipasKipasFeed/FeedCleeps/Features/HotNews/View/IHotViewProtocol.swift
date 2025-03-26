//
//  IHotViewProtocol.swift
//  FeedCleeps
//
//  Created by Administer on 2024/7/8.
//

import Foundation
import UIKit
import TUIPlayerShortVideo

protocol IHotViewProtocol {
    var storyView: HotNewsStoryView { get set }
    var storyOverlayView: UIView { get set }
}

protocol HotNewsViewEventDelegate: AnyObject {
    func profile(feed: FeedItem?)
    func like(feed: FeedItem?)
    func share(feed: FeedItem?)
    func follow(feed: FeedItem?)
    func comment(feed: FeedItem?)
    func productDetail(feed: FeedItem?)
    func donationDetail(feed: FeedItem?)
    func shortcutStartPaidDM(feed: FeedItem?)
    func hashtag(feed: FeedItem?, value: String)
    func donationFilterCategory(feed: FeedItem?)
    func mention(feed: FeedItem?, value: String)
    func playPause(feed: FeedItem?, isPlay: Bool)
    func newsPortal(feed: FeedItem?, url: String)
    func shortcutLiveStreaming(feed: FeedItem?)
    func floatingLink(feed: FeedItem?)
    func contentSetting(feed: FeedItem?)
    func bookmark(feed: FeedItem?)
    func donationCart(feed: FeedItem?)
    func donateStuff(feed: FeedItem?)
}

protocol IHotView: UIView {
    var kkRefreshControl: UIRefreshControl { get }
    var isAppear: Bool { get set }
    var tuiView: HotNewsVideoView { get }
    func setupRefreshControl()
    var disablePlay: Bool { get set }
    func isValidTUILicense() -> Bool
    func setupTUIView(cell: TUIPlayerShortVideoControl.Type, feedType: FeedType)
}

protocol IHotNewsView: IHotView, IHotViewProtocol {
    
}
