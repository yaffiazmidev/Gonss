//
//  HotNewsPresenter.swift
//  KipasKipasFeed
//
//  Created by DENAZMI on 04/10/23.
//

import UIKit
import KipasKipasNetworking
import KipasKipasShared
import SDWebImage
import Kingfisher
import KipasKipasStoryiOS

protocol IHotNewsPresenter {
    typealias CompletionHandler<T> = Swift.Result<T, DataTransferError>
    
    func presentPushFeeds(with result: Swift.Result<RemoteFeedItemData, Error>, feedType: FeedType, isLogin: Bool, feedMediaType: FeedMediaType?)
    func presentFeeds(with result: Swift.Result<RemoteFeedItemData, Error>, feedType: FeedType, isLogin: Bool, feedMediaType: FeedMediaType?)
    func presentUpdateLike(with error: Error?)
    func presentMentionUserByUsername(with result: Swift.Result<RemoteUserProfileData, Error>)
    func presentUpdateFollowAccount(with error: Error?, accountId: String)
    func presentUserProfile(with result: Swift.Result<RemoteUserProfileData, Error>)
    func presentFeedTrendingCache(with item: RemoteFeedItemContent?, feedType: FeedType)
    func presentFeed(with result: Swift.Result<RemoteFeedItemContent, Error>, feedType: FeedType)
    func presentFollowingSuggest(with result: Swift.Result<RemoteFollowingSuggestData, Error>)
    func presentStories(with result: StoryListInteractorAdapter.StoryDataResult)
}

class HotNewsPresenter: IHotNewsPresenter {
    weak var controller: IHotNewsViewController?
    
    private var userProfile: RemoteUserProfileData?
    
    init(controller: IHotNewsViewController) {
        self.controller = controller
    }
    
    let LOG_ID = "** HotNewsPresenter"
    
    func presentPushFeeds(with result: Swift.Result<RemoteFeedItemData, Error>, feedType: FeedType, isLogin: Bool, feedMediaType: FeedMediaType?){
        switch result {
        case let .success(response):
            
            guard let feeds = response.content?.toFeedItem(feedType: feedType, account: userProfile, feedMediaType: feedMediaType), !feeds.isEmpty else {
                controller?.displayFeeds(with: [], totalItems: response.content?.count ?? 0, isLogin: isLogin)
                return
            }
             
            
            var clear = true
            if feedType == .profile || feedType == .profile {
                if let controller = controller as? HotNewsViewController {
                    if !controller.interactor.alreadyLoadFeeds.isEmpty {
                        clear = false
                    }
                }
            }
            
            prefetchCovers(feedItems: feeds, clearOlds: clear)
            logUniqueFeed(feedType: feedType, feedItems: feeds)
             
            let totalFeeds = feeds.count
            
            print("**** uniqueFeed TOTAL   ",totalFeeds, feedType)
            
            let uniqFeed = feeds  //.filter({ !KKFeedCache.instance.isAlreadySeen(id: $0.id) })
            uniqFeed.forEach { item in
                  item.feedType = .profile
                print("**** uniqueFeed name: ", item.account?.username ?? "", "  -  ", item.post?.description?.prefix(10) ?? "")
            }
            print("**** uniqueFeed Unique: ", uniqFeed.count, feedType)
            print("**** uniqueFeed -------------")
            controller?.displayFeeds(with: uniqFeed, totalItems: feeds.count, isLogin: isLogin)
            
        case let .failure(error):
            if let error = error as? KKNetworkError, case let .responseFailure(response) = error {
                let errorMessage = "\(response.code) - \(response.message)"
                
                KKLogFile.instance.log(label:"presentFeeds \(feedType)"
                                       , message: errorMessage
                                       , level: .error)
                
                controller?.displayErrorGetFeeds(with: errorMessage)
                return
            }
            
            controller?.displayErrorGetFeeds(with: "Unknown Network Error")
        }
    }
    
    func presentFeeds(with result: Result<RemoteFeedItemData, Error>, feedType: FeedType, isLogin: Bool, feedMediaType: FeedMediaType?) {
        switch result {
        case let .success(response):
            
            guard let feeds = response.content?.toFeedItem(feedType: feedType, account: userProfile, feedMediaType: feedMediaType), !feeds.isEmpty else {
                controller?.displayFeeds(with: [], totalItems: response.content?.count ?? 0, isLogin: isLogin)
                return
            }
            
            if feedType == .explore || feedType == .channel || feedType == .searchTop || feedType == .following {
                controller?.displayFeeds(with: feeds, totalItems: response.content?.count ?? 0, isLogin: isLogin)
                return
            }
            
            var clear = true
            if feedType == .profile || feedType == .profile {
                if let controller = controller as? HotNewsViewController {
                    if !controller.interactor.alreadyLoadFeeds.isEmpty {
                        clear = false
                    }
                }
            }
            
            prefetchCovers(feedItems: feeds, clearOlds: clear)
            logUniqueFeed(feedType: feedType, feedItems: feeds)
            
            if feedType == .donation || feedType == .profile || feedType == .otherProfile {
                let validFeeds = feeds.filter({ $0.post?.medias?.isEmpty == false })
                controller?.displayFeeds(with: validFeeds, totalItems: feeds.count, isLogin: isLogin)
                return
            }
            let totalFeeds = feeds.count
            
            print("**** uniqueFeed TOTAL   ",totalFeeds, feedType)
            var uniqFeed = feeds
            if feedType != .hotNews {
                uniqFeed = feeds.filter({ !KKFeedCache.instance.isAlreadySeen(id: $0.id) })
            }
            uniqFeed.forEach { item in
                
                print("**** uniqueFeed name: ", item.account?.username ?? "", "  -  ", item.post?.description?.prefix(10) ?? "")
            }
            print("**** uniqueFeed Unique: ", uniqFeed.count, feedType)
            print("**** uniqueFeed -------------")
            controller?.displayFeeds(with: uniqFeed, totalItems: feeds.count, isLogin: isLogin)
            
        case let .failure(error):
            if let error = error as? KKNetworkError, case let .responseFailure(response) = error {
                let errorMessage = "\(response.code) - \(response.message)"
                
                KKLogFile.instance.log(label:"presentFeeds \(feedType)"
                                       , message: errorMessage
                                       , level: .error)
                
                controller?.displayErrorGetFeeds(with: errorMessage)
                return
            }
            
            controller?.displayErrorGetFeeds(with: "Unknown Network Error")
        }
    }

    func presentFollowingSuggest(with result: Result<RemoteFollowingSuggestData, Error>) {
        switch result {
        case .success(let response):
            controller?.displayFollowingSuggest(with: response.content ?? [])
        case .failure(let error):
            if let error = error as? KKNetworkError, case let .responseFailure(response) = error {
                let errorMessage = "\(response.code) - \(response.message)"
                controller?.displayErrorGetFeeds(with: errorMessage)
                return
            }
            
            controller?.displayErrorGetFeeds(with: error.localizedDescription)
        }
    }
    
    func logUniqueFeed(feedType: FeedType, feedItems: [FeedItem]){
        feedItems.forEach { feedItem in
            if(feedItem.videoUrl.contains(".mp4") || feedItem.videoUrl.contains(".m3u8")){
                //KKLogFile.instance.log(label:"HotNewsPresenter-logUniqueFeed \(feedType)", message: "\(feedItem.videoUrl)")
            }
        }
    }
    
    func prefetchCovers(feedItems: [FeedItem], clearOlds: Bool = true){
        var covers = [URL]()
        
        feedItems.forEach { feedItem in
            if let coverUrl = URL(string: feedItem.coverPictureUrl) {
                covers.append(coverUrl)
            }
        }
        
        if clearOlds {
            clearAndPrefetchSDWebImage(with: covers)
            kingfisherImageCacheSize()
        }
        
        let thumbnails = feedItems.map({ feed in
            let media = feed.post?.medias?.first
            guard media?.type == "image" else { return URL(string: "") }
            let ossSize: OSSSizeImage = .w720
            let thumbnailURLStringWithOSS = (media?.thumbnail?.large ?? "") + ossPerformance + ossSize.rawValue
            return URL(string: thumbnailURLStringWithOSS)
        }).compactMap({ $0 })
        
        let prefetcher = ImagePrefetcher(urls: thumbnails) { skipped, failed, completed in
            //print("These resources are prefetched: \(completed)")
        }
        prefetcher.start()
    }
    
    func clearAndPrefetchSDWebImage(with urls: [URL]){
        SDImageCache.shared.clearMemory()
        SDImageCache.shared.clearDisk {
            SDWebImagePrefetcher.shared.prefetchURLs(urls)
        }
    }
    
    private func kingfisherImageCacheSize() {
        DispatchQueue.main.async {
            let cache = ImageCache.default
            cache.memoryStorage.config.totalCostLimit = 50 * 1024 * 1024 // Limit memory cache size to 50 MB.
            cache.calculateDiskStorageSize { result in
                switch result {
                case .success(let size):
                    let sizeMB = (Double(size) / 1024 / 1024)
                    print("Disk cache size: \(sizeMB) MB")
                    if sizeMB >= 50 {
                        cache.clearMemoryCache()
                        KingfisherManager.shared.cache.clearCache()
                        KingfisherManager.shared.cache.clearMemoryCache()
                    }
                    
                case .failure(let error):
                    print("Disk cache size error", error)
                }
            }
        }
    }
    
    func presentUpdateLike(with error: Error?) {
        if let error = error as? KKNetworkError {
            if case let .responseFailure(response) = error {
                let errorMessage = "\(response.code) - \(response.message)"
                KKLogFile.instance.log(label:"presentUpdateLike"
                                       , message: errorMessage
                                       , level: .error)
                
                controller?.displayErrorUpdateLike(with: response.message)
            }
        } else {
            controller?.displayUpdateLike()
        }
    }
    
    func presentMentionUserByUsername(with result: Swift.Result<RemoteUserProfileData, Error>) {
        switch result {
        case let .success(profile):
            controller?.displayMentionUserByUsername(id: profile.id, type: profile.accountType)
        case .failure:
            controller?.displayMentionUserByUsername(id: nil, type: nil)
        }
    }
    
    func presentUpdateFollowAccount(with error: Error?, accountId: String) {
        if error == nil {
            controller?.displayUpdateFollowAccount(id: accountId)
        }
    }
    
    func presentUserProfile(with result: Swift.Result<RemoteUserProfileData, Error>) {
        switch result {
        case let .success(profile):
            userProfile = profile
        case .failure: break
        }
    }
    
    func presentFeedTrendingCache(with item: RemoteFeedItemContent?, feedType: FeedType) {
        if let item = item {
            controller?.displayFeedTrendingCache(with: FeedItem.from(remote: item, type: feedType, account: userProfile, feedMediaType: nil))
        }
    }
    
    func presentFeed(with result: Swift.Result<RemoteFeedItemContent, Error>, feedType: FeedType) {
        switch result {
        case .success(let response):
            controller?.displayUpdateSingleFeed(with: FeedItem.from(remote: response, type: feedType, account: userProfile, feedMediaType: nil))
        case .failure(let error):
            controller?.displayErrorSingleFeed(with: error.localizedDescription)
        }
    }
    
    func presentStories(with result: StoryListInteractorAdapter.StoryDataResult) {
        switch result {
        case .success(let data): 
            if let vc = controller as? IHotStoryViewController {
                vc.displayStories(with: data)
            }
        case .failure(let error): print("Story error", error.localizedDescription)
        }
    }
    
}

private extension Array where Element == RemoteFeedItemContent {
    func toFeedItem(feedType: FeedType, account: RemoteUserProfileData?, feedMediaType: FeedMediaType?) -> [FeedItem] {
        return compactMap({ FeedItem.from(remote: $0, type: feedType, account: account, feedMediaType: feedMediaType) })
    }
}
