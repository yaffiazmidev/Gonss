//
//  FeedTikTokPresenter.swift
//  KipasKipas
//
//  Created by Muhammad Noor on 20/05/22.
//  Copyright © 2022 Koanba. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import Combine
import Kingfisher
import AVFoundation
import KipasKipasNetworking

public struct FeedCleepsPresenterParam {
    var token: String?
    var isLogin: Bool
    var userID: String
    var baseURL: String
    
    public init(token: String? = nil, isLogin: Bool, userID: String, endpoint: String) {
        self.token = token
        self.isLogin = isLogin
        self.userID = userID
        self.baseURL = endpoint
    }
}

public class FeedCleepsPresenter {
    let LOG_ID = "***FC-Presenter"
    let disposeBag = DisposeBag()
    let usecase: FeedUseCase
    var requestedPage: Int = 0
    var counterFeed: Int = 0
    var selectedCommentIndex: Int = 0
    var cancellables: Set<AnyCancellable> = []
    //var urlVideo: [URL] = []
    //var isViewActive: Bool = false
    
    private let _errorMessage = BehaviorRelay<String?>(value: nil)
    var errorMessage: Driver<String?> {
        return _errorMessage.asDriver()
    }
    
    let loadingState = BehaviorRelay<Bool>(value: false)
    var loadingEmptyContentState = BehaviorRelay<Bool>(value: false)
    var tokenExpired = BehaviorRelay<Bool>(value: false)
    let networkStatus = BehaviorRelay<NetworkSpeedMonitorStatus>(value: NetworkSpeedMonitor.instance.currentNetworkSpeed())
    
    var feedsDataSource: BehaviorRelay<[Feed]> = BehaviorRelay<[Feed]>(value: [])
    var mentionAccount: BehaviorRelay<Profile?> = BehaviorRelay<Profile?>(value: nil)
    
    //var loadNextPage = PublishSubject<Void>()
    let concurrentBackground = ConcurrentDispatchQueueScheduler.init(qos: .background)
    
    let openProfile = PublishSubject<Profile?>()
    
    //private let preference = TiktokCache.instance

    //var isCaching = false

    //let dispatchGroup = DispatchGroup()
    
    //    var willPreloadedFeeds = [Feed]()
    //
    //    var didPreloadedFeeds = [Feed]()
    
    var dataIsEmpty = false
    
    var KEY_CACHE_FEED = "cache-tiktok"
    
    let KEY_FEED_CACHE: String
    
    private let loader: FeedCleepsLoader
    
    //var isGettingNetworkFeed = false
    
    public var identifier: TiktokType // can be country, or etc

    //var isLastPage = false
    var totalPage = 0
    var isProfile = false
    var isFirstLoad = true
    let backgroundQueue = DispatchQueue(label: "com.app.kipaskipas", qos: .background)
    var isFinishedUpdate = true
    var isLoadFirstTime = true
    var lastPrepareIndex = 0
    var worker:DispatchWorkItem?
    
    var isDonePreload: (() -> Void)?

    private var param: FeedCleepsPresenterParam
    var userId: String = ""
    let followingSuggestLoader: FollowingSuggestionLoader?
    var userSuggestItems: BehaviorRelay<[FollowingSuggestionContent]> = BehaviorRelay<[FollowingSuggestionContent]>(value: [])
    var loadingFollowingSuggestion: BehaviorRelay<Bool> = BehaviorRelay<Bool>(value: false)
    
    let followUnfollowUpdater: FollowUnfollowUpdater
    var userSuggestPage: Int = 0
    var userSuggestTotalPage: Int = 0
    
    public var donationCategoryId: String = ""
    public var filterByProvinceId: String? = nil
    public var filterByCurrentLocation: (long: Double?, lat: Double?)? = nil
    
    var totalPageLookup = 0
    
    public init(loader: FeedCleepsLoader, identifier: TiktokType, param: FeedCleepsPresenterParam, requestedPage: Int = 0, totalPage: Int = 0,
                followingSuggestionLoader: FollowingSuggestionLoader? = nil,
                followUnfollowUpdater: FollowUnfollowUpdater
    ) {
        LoginStateShared.shared.isLogin = param.isLogin
        
        self.usecase = Injection.init().provideFeedUseCase(endpoint: param.baseURL, token: param.token)
        self.loader = loader
        self.identifier = identifier
        self.KEY_FEED_CACHE = "FEED" + identifier.rawValue
        
        //self.LOG_ID = "*** FeedCleepsPresenter " + identifier.rawValue
        
        self.param = param
        self.requestedPage = requestedPage
        self.totalPage = totalPage
        switch identifier {
        case .profile(_):
            self.isProfile = true
        default:
            self.isProfile = false
        }
        //print("****== FeedTikTokPresenter \(identifier), self.KEY_FEED_CACHE: \(self.KEY_FEED_CACHE)")
        self.userId = param.userID

        self.followingSuggestLoader = followingSuggestionLoader
        self.followUnfollowUpdater = followUnfollowUpdater
        
        // Network Monitor
//        NetworkSpeedMonitor.instance.delegate = self
//        if let url = URL(string: param.baseURL){
//            NetworkSpeedMonitor.instance.start(with: url)
//        } else {
//            NetworkSpeedMonitor.instance.start()
//        }
    }
    
    func requestFollowingSuggestion() {
        loadingFollowingSuggestion.accept(true)
        followingSuggestLoader?.load(request: PagedFollowingSuggestionLoaderRequest(page: userSuggestPage)) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let item):
                self.userSuggestItems.accept(item.content ?? [])
                self.loadingFollowingSuggestion.accept(false)
                self.userSuggestTotalPage = (item.totalPage ?? 0) - 1
            case .failure(_):
                self.userSuggestItems.accept([])
                self.loadingFollowingSuggestion.accept(false)
            }
        }
    }
    
    func updateFollowUser(id: String, isFollow: Bool) {
        followUnfollowUpdater.load(request: FollowUnfollowUpdaterRequest(id: id, isFollow: isFollow)) { result in
            switch result {
            case .success(let item):
                print("@@@@ successs follow id \(id)")
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }

    var startTimeUpdateData = CFAbsoluteTimeGetCurrent()
    
    @objc func updateDidPreloadedFeeds(notification: NSNotification) {
        isDonePreload?()
        if let data = notification.object as? NSDictionary {
            if let feed = data[identifier] as? Feed {

                if isUnique(feed: feed) {

                    let timeElapsed = CFAbsoluteTimeGetCurrent() - self.startTimeUpdateData

                    self.startTimeUpdateData = CFAbsoluteTimeGetCurrent()

                    print("** updateDidPreloadedFeeds append accept \(self.identifier):","\(String(format: "%.1f", timeElapsed)) s",",\(feed.account?.username ?? "" )", feed.id ?? "")

                    self.feedsDataSource.accept([feed])

                    lastPrepareIndex += 1
                }
            }
        }
    }
    
    func getLog() -> String {
        let logId = self.LOG_ID + " " + self.identifier.rawValue
        return logId
    }
    
    func getNetworkFeed(getTrending: Bool = false, size: Int = 10, doneFetch: @escaping () -> (), isNetworkError: ((String) -> ())? = nil) {
        //print("====getNetworkFeed start : identifier \(self.identifier) requestedPage: \(requestedPage)")
        //        var size = size
        //        if getTrending {
        //            size = 20
        //        }
        // this prevent call "same requestedPage" multiple times
        
        //        if(self.isGettingNetworkFeed){
        //            print("====getNetworkFeed \(self.identifier) page:\(requestedPage) ignore, wait isGettingNetworkFeed")
        //            doneFetch()
        ////            return
        //        }

        print(getLog(), "getNetworkFeed TRY requestedPage:", requestedPage, "trending:", getTrending)

        //self.isGettingNetworkFeed = true

        if isCleeps() && !param.isLogin {

            print(getLog(), "getNetworkFeed ignore NOT LOgin")
            //self.isGettingNetworkFeed = false
            tokenExpired.accept(true)
        }

        loadingState.accept(true)

        var isVodAvailable: Bool? = nil
        if KKVideoManager.instance.type == .tencent{
            isVodAvailable = true
        }

        let request = PagedFeedCleepsLoaderRequest(
            page: requestedPage,
            isTrending: getTrending,
            size: size,
            categoryId: donationCategoryId,
            isVodAvailable: isVodAvailable,
            provinceId: filterByProvinceId,
            longitude: filterByCurrentLocation?.long,
            latitude: filterByCurrentLocation?.lat
        )
        
        print("****getNetworkFeed \(self.identifier.rawValue) START : request.page: \(request.page)", "requestedPage: \(requestedPage)")
        
        print(getLog(), "getNetworkFeed START requestedPage:", requestedPage, "request.page:", request.page,"trending:", getTrending)
        
        let startTime = CFAbsoluteTimeGetCurrent()

        loader.load(request: request) { [weak self] result in
            guard let self = self else { return }
            
            //self.isGettingNetworkFeed = false
            
            switch result {
            case .success(let result):
                self.totalPage = result.data?.totalPages ?? 0
                if (result.code == "1000") {

                    let dataCount = result.data?.content?.count ?? 0

                    print(self.getLog(), "getNetworkFeed SUCCESS requestedPage:", self.requestedPage, "request.page:", request.page,"trending:", getTrending, "dataCount.count:", dataCount)


                    if !getTrending {
                        self.requestedPage += 1
                        print(self.getLog(), "getNetworkFeed INCR requestedPage:", self.requestedPage, "request.page:", request.page,"trending:", getTrending)

                    }

                    self.loadingState.accept(false)

                    // if data.count <= MIN_DATA_PER_PAGE, then we assume that data is Empty
                    let MIN_DATA_PER_PAGE = 4
                    //let MIN_DATA_PER_PAGE = 2

                    if self.identifier != .donation {
                        if let feeds = result.data?.content {
                            self.loadingEmptyContentState.accept(false)
                            self.feedsDataSource.accept(feeds)
                        }

                        //*
                        if dataCount <= MIN_DATA_PER_PAGE {
                            //print(self.identifier, "**** loadingEmptyContentState accept \(self.identifier.rawValue) All ZERO", "page:", request.page, "trending:", getTrending)

                            if !getTrending {
                                print(self.getLog(), "getNetworkFeed LACKDATA requestedPage:", self.requestedPage, "request.page:", request.page,"trending:", getTrending)

                                print(self.identifier.rawValue, "LACKDATA **** loadingEmptyContentState TRUE \(self.identifier.rawValue) dataCount <= MIN_DATA_PER_PAGE", "page:", request.page, "trending:", getTrending)

                                //if(self.totalPageLookup > 3){
                                self.loadingEmptyContentState.accept(true)
                                doneFetch()
                                //}

                            } else {
                                //print(self.identifier, "**** loadingEmptyContentState accept \(self.identifier.rawValue) All ZERO", "page:", request.page, "trending:", getTrending)
                                print(self.getLog(), "getNetworkFeed LACKDATA-JumpPage trending:TRUE", "requestedPage:", self.requestedPage, "request.page:", request.page)

                                self.getNetworkFeed {}
                            }

                            //return
                        } else {
                            if let feeds = result.data?.content {
                                print(self.identifier.rawValue, "loadingEmptyContentState FALSE", "page:", request.page, "trending:", getTrending)

                                self.loadingEmptyContentState.accept(false)
                                self.feedsDataSource.accept(feeds)
                            }
                        }
                        //*/

                    } else {
                        if self.identifier == .donation {
                            self.loadingEmptyContentState.accept(result.data?.content?.isEmpty ?? true)
                            self.feedsDataSource.accept(result.data?.content ?? [])
                        } else {
                            if let feeds = result.data?.content {
                                self.loadingEmptyContentState.accept(false)
                                self.feedsDataSource.accept(feeds)
                            }
                        }

                    }
                    doneFetch()
                } else {
                    print(self.getLog(),"====getNetworkFeed1 \(self.identifier.rawValue) FAILED : request.page \(request.page), requestedPage: \(self.requestedPage)")
                    isNetworkError?("Unstable Network. (\(result.code ?? "-3")")
                    doneFetch()
                }
            case .failure(let error):
                
                self.loadingState.accept(false)
                
                let error = error as? NSError
                
                if !ReachabilityNetwork.isConnectedToNetwork() {
                    print(self.getLog(), "No Internet Connection")
                    isNetworkError?("Unstable Network. (-1)")
                    doneFetch()
                    return
                }

                print(self.getLog() ,"====getNetworkFeed2 \(self.identifier.rawValue) FAILURE : page \(self.requestedPage),", "error:", error, "[error.code]", error?.code ?? 0, error?.userInfo)

                if error?.code == 401 {
                    self.tokenExpired.accept(true)
                }
                else if error?.code == 4865 {
                    // 4865 == Error JSON, response Null
                    self.loadingEmptyContentState.accept(true)
                }
                else {
                    self._errorMessage.accept(error?.localizedDescription)

                    isNetworkError?("Unstable Network. (-2)")
                    //                    self.loadingEmptyContentState.accept(true)
                }
                doneFetch()
            }
        }
    }

    func isUnique(feed: Feed) -> Bool {
        let feeds = self.feedsDataSource.value
        return !feeds.contains(feed)
    }
    
    func prefetchImages(_ feeds: [Feed]) {
        var urlMedias = [String]()
        
        for validData_ in feeds {
            //            print("azmi: \(self.identifier) \(validData_.account?.name ?? "") media count \(validData_.post?.medias?.count ?? 0)")
            validData_.post?.medias?.forEach({ media in
                let urlMediaPost = media.thumbnail?.large ?? "urlMediaPost-nil"
                
                var urlValidBlur = ""
                
                if(urlMediaPost.containsIgnoringCase(find: ossPerformance) == false ) {
//                    urlValidBlur = urlMediaPost + ossPerformance + "120" + "/blur,r_8,s_8"
                    urlValidBlur = urlMediaPost + ossPerformance + "200" + "/blur,r_50,s_35"
                }

                urlMedias.append(urlValidBlur)
                
                var urlValid = ""
                
                
                if(urlMediaPost.containsIgnoringCase(find: ossPerformance) == false ){
                    urlValid = urlMediaPost + ossPerformance + OSSSizeImage.w720.rawValue
                    //urlValid += "/bright,23/sharpen,100"
//                    urlValid += "/bright,8/contrast,11"
                }
                
                //print("**===tprefetch urlMediaPost", urlValid)
                
                urlMedias.append(urlValid)
            })
            
            if let urlAccount = validData_.account?.photo, !urlAccount.isEmpty {
                let urlAccountOss = urlAccount + ossPerformance + OSSSizeImage.w80.rawValue
                urlMedias.append(urlAccountOss)
            }
        }
        //print("sssssss \(urlMedias)")
        
//        urlMedias.forEach { urlMedia in
//            print("**===tprefetch urlMedia", urlMedia)
//        }
        
        let urls = urlMedias.map { URL(string: $0)! }
        
        let prefetcher = ImagePrefetcher(urls: urls) {
            skippedResources, failedResources, completedResources in
        }
        prefetcher.start()
    }
    
    func updateFeedAlreadySeen(feedId: String, isSuccessUpdate: @escaping (Bool) -> ()) {

        let request = SeenFeedCleepsRequest(feedID: feedId)
        loader.seen(request: request) { [weak self ] result in
            guard let self = self else { return }
            switch result {
            case let .success(response):
                if response.code == "1000" {
                    isSuccessUpdate(true)
                    return
                }
                isSuccessUpdate(false)
            case let .failure(error):
                self._errorMessage.accept(error.localizedDescription)
                isSuccessUpdate(false)
            }
        }
    }
    
    //    func checkDataIsInQueue() -> Bool {
    //        return ProxyServer.shared.checkIfThereIsStillHaveDataInQueue(for: identifier.rawValue)
    //    }
    
    func getMyLatestFeed() {
        usecase.getLatestFeedNetwork(userId: param.userID)
            .subscribeOn(self.concurrentBackground)
            .observeOn(MainScheduler.instance)
            .subscribe{ [weak self] result in
                guard let self = self else { return }
                guard let validData = result.data?.content else { return }
                if self.identifier == .feed {
                    self.feedsDataSource.accept(validData)
                }
            } onError: { [weak self] err in
                guard let self = self else { return }
                self._errorMessage.accept(err.localizedDescription)
            } onCompleted: {
            }.disposed(by: disposeBag)
    }

    
    func updateLikeFeed(_ feed: Feed, _ refresh: @escaping ()->()) {
        loadingState.accept(true)
        usecase.likeFeedRemote(feed: feed)
            .subscribeOn(self.concurrentBackground)
            .observeOn(MainScheduler.instance)
            .subscribe{ result in
                //TODO : SHOULD BE ENUM
                if (result.code == "1000") {
                    self.loadingState.accept(false)
                }
            } onError: { err in
                self._errorMessage.accept(err.localizedDescription)
            } onCompleted: {
                refresh()
            }.disposed(by: disposeBag)
    }
    
    func updateFeedComment(comments: Int, index: Int) {
        var feed = self.feedsDataSource.value[index]
        feed.comments = (feed.comments ?? 0) + comments
    }
    
    func updateFeedLike(likes: Int, index: Int) {
        var feed = self.feedsDataSource.value[index]
        feed.likes = (feed.likes ?? 0) + likes
    }
    
    func detail(_ text: String) {
        let profileNetwork = ProfileNetworkModel()
        profileNetwork.profileUsername(baseURL: self.param.baseURL,
                                       token: self.param.token ?? "",
                                       username: text) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case let .success(result):
                self.mentionAccount.accept(result.data)
            case let .failure(error):
                print(error)
                self.mentionAccount.accept(nil)
            }
        }
    }
    
    func isCleeps() -> Bool {
        switch identifier {
        case .cleeps(_), .donation:
            return true
        default:
            return false
        }
    }
    
    func isFeedProduct(feed: Feed) -> Bool{
        return feed.post?.product != nil
    }

    func isFeedImage(feed: Feed) -> Bool {
        return feed.post?.medias?.first?.type == "image"
    }
    
    
    func isFeedVideoHLS(feed: Feed) -> Bool {
        if(feed.post?.medias?.first?.hlsUrl != nil){
            if(feed.post?.medias?.first?.hlsUrl != ""){
                return true
            }
        }
        
        return false
    }

    func clearCache() {
        print("MEMIssue", "FeedCleepsPresenter", self.identifier)
        KingfisherManager.shared.cache.clearMemoryCache()
        KingfisherManager.shared.cache.clearDiskCache()
        KingfisherManager.shared.cache.cleanExpiredDiskCache()
        KKTencentVideoPlayerPreload.instance.clear()
    }
}

// MARK: - Cache
extension FeedCleepsPresenter {
    func getKeyLastReadyFeed() -> String {
        var userId = self.userId
        if userId.isEmpty {
            userId = "anonim"
        }
        userId = userId.replacingOccurrences(of: " ", with: "")
        return "\(userId)-lastReadyFeed-\(self.identifier.rawValue)"
    }
    
    func addLastReadyFeed(feed: Feed, withTrendingFilter: Bool = false){
        if withTrendingFilter {
            let isTrending = feed.trendingAt != nil
            let hashtagTrending = ["viral", "trending", "hottopic"]
            var containHashtag = false
            
            for hashtag in (feed.post?.hashtags ?? []) {
                if hashtagTrending.contains(where: { $0 == hashtag.value}) {
                    containHashtag = true
                    break
                }
            }
            
            guard isTrending || containHashtag else {
                print("10167 - skip save feed", feed.post?.postDescription?.prefix(10), isTrending, containHashtag)
                return
            }
        }
        print("10167 - add feed to cache", feed.post?.postDescription?.prefix(10))
        do {
            try DataCache.instance.write(codable: feed, forKey: self.getKeyLastReadyFeed())
        } catch {
            print(self.LOG_ID, "addLastReadyFeed", "Write error \(error.localizedDescription)")
        }
    }

    func getLastReadyFeed() -> Feed? {
        do {
            if let feed: Feed = try DataCache.instance.readCodable(forKey: self.getKeyLastReadyFeed()) {
                return feed
            }
        } catch {
            print(self.LOG_ID, "getLastReadyFeed", "Read error \(error.localizedDescription)")
        }
        
        return nil
    }

    
    func reservedResourceVideo(feed: Feed) {
//        KKResourceLoader.instance.pauseExcept(urlString: feed.post?.medias?.first?.url ?? "")
//        KKResourceLoader.instance.resume(urlString: feed.post?.medias?.first?.url ?? "")
        if let videoId = feed.post?.medias?.first?.vodUrl {
            //print("==KKTencentVideoPlayerPreload preload canceled by presenter", KKVideoId().getId(urlString: videoId))
            KKTencentVideoPlayerPreload.instance.cancelPreload(video: videoId, queueId: self.identifier.rawValue, reason: "presenter")
        }
    }
}

extension BehaviorRelay where Element: RangeReplaceableCollection {

    func append(_ subElement: Element.Element) {
        var newValue = value
        newValue.append(subElement)
        accept(newValue)
    }

    func append(contentsOf: [Element.Element]) {
        var newValue = value
        newValue.append(contentsOf: contentsOf)
        accept(newValue)
    }

    public func remove(at index: Element.Index) {
        var newValue = value
        newValue.remove(at: index)
        accept(newValue)
    }

    public func removeAll() {
        var newValue = value
        newValue.removeAll()
        accept(newValue)
    }

}

//MARK: - Handler NetworkSpeedMonitor
extension FeedCleepsPresenter {
    func startSpeedMonitoring(){
        NetworkSpeedMonitor.instance.start()
    }
    
    func stopSpeedMonitoring(){
        NetworkSpeedMonitor.instance.stop()
    }
}

//MARK: - NetworkSpeedMonitorDelegate
extension FeedCleepsPresenter: NetworkSpeedMonitorDelegate {
    public func speedDidChange(speed: NetworkSpeedMonitorStatus) {
        if self.networkStatus.value != speed {
            self.networkStatus.accept(speed)
            print("PE10943", "Presenter - Speed Test Status:", self.networkStatus.value)
        }
        
        //self.networkStatus.accept(speed)
    }
}
