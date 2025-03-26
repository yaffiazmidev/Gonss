import UIKit
import KipasKipasShared
import KipasKipasNetworking
import KipasKipasStoryiOS

protocol IHotNewsInteractor: AnyObject {
    /**This is the current page, not the page that will be loaded*/
    var page: Int { get set }
    var totalPage: Int { get set }
    var categoryId: String { get set }
    var isLogin: Bool { get set }
    var provinceId: String { get set }
    var longitude: Double { get set }
    var latitude: Double { get set }
    var profileId: String { get set }
    var selectedFeedId: String { get set }
    var alreadyLoadFeeds: [FeedItem] { get set }
    var trendingCache: HotNewsInteractorTrendingCache { get }
    var mediaType: FeedMediaType? { get set }
    var channelId: String { get set }
    var isForSingleFeed: Bool { get set }
    var storyPage: Int { get set }

    
    func requestFeeds(reset: Bool)
    func guestSeenFeed(id: String)
    func seenFeed(id: String, accountId: String)
    func updateLike(id: String, isLike: Bool)
    func requestMentionUser(by username: String)
    func updateFollow(by id: String)
    func requestUserProfile()
    func requestFeed(by id: String)
    func requestFollowing()
    func isDonationFilterActive() -> Bool
    func requestStories(reset: Bool)
    
    func requestPushFeeds(reset: Bool)
}

extension IHotNewsInteractor {
    func requestFeeds(reset page: Bool = false) {
        requestFeeds(reset: page)
    }
}

class HotNewsInteractor: IHotNewsInteractor {
    let LOG_ID = "** HotNewsInteractor"
    let CHANNEL_CODE = "tiktok"
    
    let trendingCache: HotNewsInteractorTrendingCache
    private let loader: HotnewsLoader
    private let storyListLoader: StoryListInteractorAdapter?
    private let presenter: IHotNewsPresenter
    private let network: DataTransferService
    private let feedType: FeedType
    var mediaType: FeedMediaType?
    
    /**This is the current page, not the page that will be loaded*/
    var page: Int = 0
    var totalPage: Int = 0
    var categoryId: String = ""
    var isLogin: Bool
    var provinceId: String = ""
    var longitude: Double = 0.0
    var latitude: Double = 0.0
    var profileId: String = ""
    var selectedFeedId: String = ""
    var alreadyLoadFeeds: [FeedItem] = [] {
        didSet {
            updateCoverLoadedFeeds()
        }
    }
    var channelId: String = ""
    var searchKeyword: String = ""
    var isForSingleFeed: Bool = false
    var storyPage: Int = 0
      
    private let totalFollowing: Int
    public var isFromPushFeed = false
    init(
        loader: HotnewsLoader,
        storyListLoader: StoryListInteractorAdapter? = nil,
        presenter: IHotNewsPresenter,
        network: DataTransferService,
        feedType: FeedType,
        isLogin: Bool,
        mediaType: FeedMediaType? = nil,
        totalFollowing: Int
    ) {
        self.loader = loader
        self.storyListLoader = storyListLoader
        self.presenter = presenter
        self.network = network
        self.feedType = feedType
        self.isLogin = isLogin
        self.mediaType = mediaType
        self.totalFollowing = totalFollowing
        trendingCache = HotNewsInteractorTrendingCache(presenter: presenter)
    }
    
    func updateLike(id: String, isLike: Bool) {
        loader.likePost(byId: id, isLiking: isLike) { [weak self] error in
            self?.presenter.presentUpdateLike(with: error)
        }
    }
    
    func requestFeeds(reset: Bool) {
        guard !isForSingleFeed else { return }
        let loadingPage = reset ? 0 : (page + 1)
        KKLogFile.instance.log(label:"\(LOG_ID) \(feedType) page:\(loadingPage)", message: "Get loadingPage:\(loadingPage), page:\(page) ,reset:\(reset)")
        
        // PE-13955
        if (feedType == .following && !isLogin) {
            return
        }
        
        loader.getFeedVideo(with: makeFeedEndpoint(by: feedType, with: loadingPage)) { [weak self] result in
            guard let self = self else { return }
            
            var totalDataResult = -1
            
            if case .success(let response) = result {
                self.page = loadingPage
                self.totalPage = (response.totalPages ?? 0) - 1
                
                let ignoringType: [FeedType] = [.profile, .explore, .channel, .searchTop]
                
                if !ignoringType.contains(self.feedType) {
                    self.selectedFeedId = response.content?.first?.id ?? ""
                }
                
                totalDataResult = response.content?.count ?? 0
            }

            if(feedType == .following && totalDataResult == 0 ){
                // Hasn't Follow or Followed account has no Feed data
                if(loadingPage == 0){
                    // PE-13955
                    if isLogin {
                        self.requestFollowingSuggest()
                    }
                    return
                } else {
                    // reach end page following
                }
            }
            
            let uniqueFeedTypes:[FeedType] = [.hotNews, .feed]
            guard uniqueFeedTypes.contains(self.feedType) else {
                KKLogFile.instance.log(label:"\(LOG_ID) \(feedType) page:\(loadingPage)", message: "Success Get Unique Data")
                self.presenter.presentFeeds(with: result, feedType: feedType, isLogin: isLogin, feedMediaType: self.mediaType)
                return
            }
            
            switch result {
            case let .success(response):
                
                response.content?.forEach({ [weak self] feed in
                    guard let feedId = feed.id else { return }
                    guard let self = self else { return }
                    // check if feed already Seen before ?
                    if(self.feedType != .hotNews && !KKFeedCache.instance.isUniqueFeed(id: feedId)){
                        // if already seen, could be Backend update problem, force re-seen
                        print("\(self.LOG_ID) *** uniqueFeed Re-SEEN", feed.account?.username ?? "", " - ", feedId)
                        self.seenFeed(id: feedId, accountId: feed.account?.id ?? "")
                    }
                })
                
                print("\(LOG_ID) *** uniqueFeed requestFeeds \(self.feedType) page: \(page) success, ", response.content?.count ?? 0, " data")

                KKLogFile.instance.log(label:"\(LOG_ID) \(feedType) page:\(loadingPage)", message: "Success Get \(response.content?.count ?? 0) Data")
                
                self.presenter.presentFeeds(with: .success(response), feedType: feedType, isLogin: isLogin, feedMediaType: self.mediaType)

            case let .failure(error):
                if let error = error as? KKNetworkError, case let .responseFailure(response) = error {
                    let errorMessage = "Message: \(response.message) - Code:\(response.code)"

                    print("\(LOG_ID) requestFeeds \(feedType) page:\(page) Error \(errorMessage)")

                    KKLogFile.instance.log(label:"\(LOG_ID) \(feedType) page:\(page)"
                                           , message: errorMessage
                                           , level: .error)
                    self.presenter.presentFeeds(with: .failure(error), feedType: feedType, isLogin: isLogin, feedMediaType: self.mediaType)
                    if !errorMessage.lowercased().contains("time out") {
                        KKLogger.instance.send(
                            title: "HotNewsInteractor Error Load:",
                            message: errorMessage
                        )
                    }
                    return
                }
                
                self.presenter.presentFeeds(with: .failure(error), feedType: feedType, isLogin: isLogin, feedMediaType: self.mediaType)
            }
        }
    }
    
    //    MARK: -  push append List
    func requestPushFeeds(reset: Bool) {
        let loadingPage = reset ? 0 : (page + 1)
        var feedType =  FeedType.hotNews 
        KKLogFile.instance.log(label:"\(LOG_ID) \(feedType) page:\(loadingPage)", message: "Get loadingPage:\(loadingPage), page:\(page) ,reset:\(reset)")
        
        
        loader.getFeedVideo(with: makeFeedEndpoint(by: feedType, with: loadingPage)) { [weak self] result in
            guard let self = self else { return }
              
            if case .success(let response) = result {
                self.page = loadingPage
                self.totalPage = (response.totalPages ?? 0) - 1
            }
              
            switch result {
            case let .success(response):
                
                response.content?.forEach({ feed in
                    guard let feedId = feed.id else { return }
                    
                    // check if feed already Seen before ?
                    if( !KKFeedCache.instance.isUniqueFeed(id: feedId)){
                        // if already seen, could be Backend update problem, force re-seen
                        print("\(self.LOG_ID) *** uniqueFeed Re-SEEN", feed.account?.username ?? "", " - ", feedId)
                        self.seenFeed(id: feedId, accountId: feed.account?.id ?? "")
                    }
                    //KKFeedCache.instance.isUniqueFeed(id: feedId) ? resposeUniqueFeeds.append(feed) : self.seenFeed(id: feedId)
                })
                
                print("\(LOG_ID) *** uniqueFeed requestFeeds \(self.feedType) page: \(page) success, ", response.content?.count ?? 0, " data")

                KKLogFile.instance.log(label:"\(LOG_ID) \(feedType) page:\(loadingPage)", message: "Success Get \(response.content?.count ?? 0) Data")
                 
                self.presenter.presentPushFeeds(with: .success(response), feedType: feedType, isLogin: isLogin, feedMediaType: self.mediaType)

            case let .failure(error):
                if let error = error as? KKNetworkError, case let .responseFailure(response) = error {
                    let errorMessage = "Message: \(response.message) - Code:\(response.code)"

                    print("\(LOG_ID) requestFeeds \(feedType) page:\(page) Error \(errorMessage)")

                    KKLogFile.instance.log(label:"\(LOG_ID) \(feedType) page:\(page)"
                                           , message: errorMessage
                                           , level: .error)
                    self.presenter.presentFeeds(with: .failure(error), feedType: feedType, isLogin: isLogin, feedMediaType: self.mediaType)
                    if !errorMessage.lowercased().contains("time out") {
                        KKLogger.instance.send(
                            title: "HotNewsInteractor Error Load:",
                            message: errorMessage
                        )
                    }
                    return
                }
                
                self.presenter.presentFeeds(with: .failure(error), feedType: feedType, isLogin: isLogin, feedMediaType: self.mediaType)
            }
        }
    }
    
    private func getToken()  -> String? {
        let KEY_AUTH_TOKEN = "KEY_AUTH_TOKEN"
        
        if let token = DataCache.instance.readString(forKey: KEY_AUTH_TOKEN) {
            return token
        }

        return nil
    }
    
    private func makeFeedEndpoint(by feedType: FeedType, with page: Int) -> PagedFeedVideoLoaderRequest {
        
        if let token = getToken() {
            if(token != ""){
                isLogin = true
            }
        }

        switch feedType {
        case .donation:
            return .init(
                page: page,
                categoryId: categoryId,
                provinceId: provinceId,
                longitude: longitude,
                latitude: latitude,
                isPublic: !isLogin,
                feedType: .donation
            )
            
        case .following:
            return .init(
                page: page,
                isPublic: false,
                feedType: .following
            )

        case .hotNews:
            let deviceId = !isLogin ? UIDevice.current.identifierForVendor?.uuidString : nil

            return .init(
                page: page,
                isPublic: !isLogin,
                feedType: .hotNews,
                deviceId: deviceId
            )

        case .feed:
            return .init(
                page: page,
                isPublic: !isLogin,
                feedType: .feed,
                mediaType: mediaType
            )

        case .profile:
            return .init(
                page: page,
                isPublic: !isLogin,
                feedType: .profile,
                profileId: profileId
            )

        case .otherProfile:
            return .init(
                page: page,
                isPublic: !isLogin,
                feedType: .otherProfile
            )
        case .explore:
            return .init(
                page: page,
                isPublic: !isLogin,
                feedType: .explore
            )
        case .channel:
            return .init(
                page: page,
                isPublic: !isLogin,
                feedType: .channel,
                channelId: channelId
            )
        case .searchTop:
            return .init(
                page: page,
                isPublic: !isLogin,
                feedType: .searchTop,
                searchKeyword: searchKeyword
            )
        case .deletePush:
            return .init(page: page,
                         isPublic: !isLogin,
                         feedType: .deletePush)
        }
    }
    
    func seenFeed(id: String, accountId: String) {
        
        // [PE-13623] this cause "berulang" because content uploaded by this user "not seen", and "stay" on Feed view
        //guard KKCache.credentials.readString(key: .userId) != accountId else { return } //Another User Post

        guard isLogin else { return }
        
        saveSeenCache(id: id)
        KKFeedCache.instance.seenFeed(by: id)

        loader.seenPost(byId: id) { result in
            switch result {
            case .failure(let error):
                if let error = error as? KKNetworkError, case let .responseFailure(response) = error {
                    let message = "\(error.localizedDescription), \(response.message)"
                    
                    print("azmi-- failed seen", id)
                    
                    if !message.lowercased().contains("time out") {
                        KKLogger.instance.send(title: "HotNewsInteractor Error Seen:", message: message)
                    }
                }

            case .success(_):
                print("azmi-- success seen", id)
            }
        }
    }
    
    func guestSeenFeed(id: String) {
        loader.guestSeenPost(byId: id) { result in
            switch result {
            case .failure(let error): 
                break
            case .success(_):
                print("azmi-- success seen", id)
            }
        }
    }
    
    func saveSeenCache(id: String){
        if(id == "" || feedType == .hotNews) { return }
        KKFeedCache.instance.addSeen(feedId: id, channelCode: self.CHANNEL_CODE)
    }
    
    func requestMentionUser(by username: String) {
        loader.getUserProfile(byUsername: username) { [weak self] in
            self?.presenter.presentMentionUserByUsername(with: $0)
        }
    }
    
    func updateFollow(by id: String) {
        loader.followUser(byId: id) { [weak self] error in
            self?.presenter.presentUpdateFollowAccount(with: error, accountId: id)
        }
    }

    func requestUserProfile() {
        loader.getUserProfile(byId: profileId) { [weak self] in
            self?.presenter.presentUserProfile(with: $0)
        }
    }
    //    MARK: -  request by id

    func requestFeed(by id: String) { 
        guard id.isEmpty == false else { return } 
        loader.getFeed(byId: id,isLogin: isLogin) { [weak self] in
            guard let self = self else { return }
            self.presenter.presentFeed(with: $0, feedType: self.feedType)
        }
    }
    func isDonationFilterActive() -> Bool {
        return latitude != 0.0 || longitude != 0.0 || !provinceId.isEmpty || !categoryId.isEmpty
    }
}

// MARK: - Following
extension HotNewsInteractor {
    func requestFollowing() {
        
//        guard totalFollowing > 0 else {
//            print("*** following B requestFollowingSuggest")
//            self.requestFollowingSuggest()
//            return
//        }

        self.requestFeeds(reset: true)
    }
    
    private func requestFollowingSuggest() {
        loader.getFollowingSuggest(page: page, size: 10) { [weak self] result in
            guard let self = self else { return }
            self.presenter.presentFollowingSuggest(with: result)
        }
    }
}

// MARK: - Story
extension HotNewsInteractor {
    func requestStories(reset: Bool) {
        let loadPage = reset ? 0 : storyPage + 1
        storyListLoader?.load(.init(page: loadPage)) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(_): self.storyPage = loadPage
            default: break
            }
            
            self.presenter.presentStories(with: result)
        }
    }
}

private extension HotNewsInteractor {
    private func updateCoverLoadedFeeds() {
        alreadyLoadFeeds.forEach { item in
            let mediaWithVodUrl = item.post?.medias?.filter({ $0.vodUrl != nil }).first
            let mediaWithoutVodUrl = item.post?.medias?.filter({ $0.url?.hasPrefix(".mp4") == true || $0.url?.hasPrefix(".m3u8") == true }).first
            
            let media = item.post?.medias?.first
            
            if item.typePost == "donation" {
                item.videoUrl = mediaWithVodUrl?.playURL ?? ""
            } else {
                item.videoUrl = media?.playURL ?? ""
            }
            
            
            if let mediaThumbnail = media?.thumbnail?.large {
                var mediaType: HotnewsCoverMediaType
                if media?.type == "video" {
                    let isFill: Bool
                    
                    let width = Double(media?.metadata?.width ?? "550") ?? 550
                    let height =  Double(media?.metadata?.height ?? "550") ?? 550
                    
                    let ratio = height / width
                    if width >= height {
                        isFill = false
                    } else {
                        if(ratio < 1.5){
                            isFill = false
                        } else {
                            isFill = true
                        }
                    }
                    
                    mediaType = .video(isFill: isFill)
                } else {
                    mediaType = .photo
                }
                
                item.coverPictureUrl = HotnewsCoverManager.instance.url(from: mediaThumbnail, with: feedType , mediaType: mediaType)
            }
            
            if let media = item.post?.medias?.first, let mediaThumbnail = media.thumbnail?.large {
                var mediaType: HotnewsCoverMediaType
                if media.type == "video" {
                    let isFill: Bool
                    
                    let width = Double(media.metadata?.width ?? "550") ?? 550
                    let height =  Double(media.metadata?.height ?? "550") ?? 550
                    
                    let ratio = height / width
                    if width >= height {
                        isFill = false
                    } else {
                        if(ratio < 1.5){
                            isFill = false
                        } else {
                            isFill = true
                        }
                    }
                    
                    mediaType = .video(isFill: isFill)
                } else {
                    mediaType = .photo
                }
                
                var feedType = feedType
                if item.typePost == "donation" {
                    feedType = .donation
                }
                
                item.coverPictureUrl = HotnewsCoverManager.instance.url(from: mediaThumbnail, with: feedType, mediaType: mediaType)
            }
        }
        
        if let presenter = presenter as? HotNewsPresenter {
            presenter.prefetchCovers(feedItems: alreadyLoadFeeds, clearOlds: false)
        }
    }
}

// MARK: - Cahce
class HotNewsInteractorTrendingCache {
    private let key: KKCache.Key = .trendingCache
    private let presenter: IHotNewsPresenter

    init(presenter: IHotNewsPresenter) {
        self.presenter = presenter
    }

    func save(with item: FeedItem) {
        let hashtagTrending = ["viral", "trending", "hottopic"]
        let isTrending = item.trendingAt != nil
        let postHashtags = item.post?.hashtags?.map { $0.value ?? "" } ?? []
        let containHashtag = Set(postHashtags).isSubset(of: hashtagTrending)

        print("HotNewsInteractorTrendingCache", "username:", item.account?.username ?? "", "isTrending:", isTrending, "isContainHashtag:", containHashtag, "hashtags:", postHashtags)

        KKCache.common.remove(key: key)
        guard isTrending || containHashtag else {
            print("HotNewsInteractorTrendingCache", "username:", item.account?.username ?? "", "ignore save to", key.rawValue, "& clear", key.rawValue)
            return
        }

        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        guard let data = try? encoder.encode(item) else {
            print("HotNewsInteractorTrendingCache", "username:", item.account?.username ?? "", "failure convert item")
            return
        }

        print("HotNewsInteractorTrendingCache", "username:", item.account?.username ?? "", "saving to", key.rawValue)
        KKCache.common.save(data: data, key: key)
    }

    func load(type: FeedType) {
        let data = KKCache.common.readData(key: key)
        let item = try? JSONDecoder().decode(RemoteFeedItemContent.self, from: data ?? Data())

        if let username = item?.account?.username {
            print("HotNewsInteractorTrendingCache load", "username:", username)
        }

        KKCache.common.remove(key: key)
        presenter.presentFeedTrendingCache(with: item, feedType: type)
    }
}

fileprivate extension Set {
    func isSubset(of array: [Element]) -> Bool {
        if isEmpty { return false }
        return isSubset(of: Set(array))
    }
}
