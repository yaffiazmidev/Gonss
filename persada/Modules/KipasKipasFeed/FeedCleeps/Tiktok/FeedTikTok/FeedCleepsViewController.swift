//
//  FeedCleepsViewController.swift
//  KipasKipas
//
//  Created by Muhammad Noor on 20/05/22.
//  Copyright © 2022 Koanba. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

public protocol FeedCleepsViewControllerDelegate: AnyObject {
    func updateUserFollowStatus(feedId: String, accountId: String, isFollow: Bool, name: String, photo: String)
}

public class FeedCleepsViewController: UIViewController {
    
    public var showLiveStreamingList: (() -> Void)?
    
    private var data = [Feed]()
    private var dataUnready = [Feed]()
    private var seenFeeds = [FeedId]()
    private let mainView: FeedCleepsView
    public var router: FeedCleepsRouter?
    private let disposeBag = DisposeBag()
    private let cleepsCountry: CleepsCountry
    private var uniqueFeedToAppends = [Feed]()
    public let presenter: FeedCleepsPresenter!
    private let tiktokCache = TiktokCache.instance
    private var lastActiveCells:[TiktokPostViewCell] = []
    private var autoCloseProductCountdown: ICountdownManager?
    public weak var delegate: FeedCleepsViewControllerDelegate?
    private var userSuggestItems: [FollowingSuggestionContent] = []
    public var topViewController: UIViewController?

    private let handleReportFeed = Notification.Name(rawValue: "com.kipaskipas.reportFeed")
    private let handleDeleteFeed = Notification.Name(rawValue: "com.kipaskipas.deleteFeed")
    private let updateMyLatestFeed = Notification.Name(rawValue: "com.kipaskipas.updateMyLatestFeed")
    private let refreshForDonation = Notification.Name(rawValue: "com.kipaskipas.refreshDonation")
    private let refreshControl = UIRefreshControl()
    private let scrollView = UIScrollView()
    private var panGest: UIPanGestureRecognizer!
    
    private var KEY_LAST_OPEN_CLEEP = "KEY_LAST_OPEN_CLEEP"
    private var LOG_ID = "***FeedController "
    
    private let isProfile: Bool
    private let isHome: Bool
    private var isLogin: Bool {
        return HelperSingleton.shared.token.isEmpty == false
    }
    private let enableRefresh: Bool
    private var isFeed: Bool = true
    private var isReset: Bool = true
    private var isRefresh: Bool = false
    private var hasDeleted: Bool = false
    private var isFirstLoad: Bool = true
    private var isDragging: Bool = false
    private var isDidAppear: Bool = false
    private var getTrending: Bool = false
    private var isFirstReload: Bool = true
    private var isAlreadyOpen: Bool = true
    private var displaySingle: Bool = false
    private var isFirstOpenPage: Bool = true

    private let LOG_MEDIA_NAME: Bool = false

    private var isTabFollowing: Bool = false
    private var isFinishRefresh: Bool = false
    private var isLoadingPaging: Bool = false
    private var isShowLoadError: Bool = false
    public var uploadPostContent: Bool = false
    private var isGettingNextPage: Bool = false
    private var isShowTiktokEmptyView: Bool = false
    private var commentSheetDisplayed: Bool = false
    private var autoScrollToFirstIndex: Bool = false
    private var showBottomCommentSectionView: Bool = false
    private var isProcessingShowOfflineFeeds: Bool = false
    
    private var currentIndex: Int = 0
    private var INDEX_ROW_SHOWING: Int = 0
    private var tryCountToAutoPlay: Int = 0
    private var startItemFromIndex: Int = 0
//    private let MAX_PAGE_TO_LOOKUP: Int = 3
    private let MAX_QUEUE_APPEAR: Int = 100
    private let MAX_QUEUE_DISAPPEAR: Int = 2
    private let MAX_MARGIN_SHOW_CLEEPS: Int = 9
    private let MAX_MARGIN_SHOW_OTHER_PROFILE: Int = 2
    
    private let resetFilterCache: () -> Void
    
    public init(
        cleepsCountry: CleepsCountry? = .indo,
        mainView: FeedCleepsView,
        feed: [Feed],
        presenter: FeedCleepsPresenter,
        hasDeleted: Bool = false,
        displaySingle: Bool = false,
        showBottomCommentSectionView: Bool = false,
        enableRefresh: Bool = true,
        isFeed: Bool = true,
        isHome: Bool,
        isProfile: Bool = false,
        resetFilterCache: @escaping () -> Void = {}
    ) {
        //KKTencentVideoPlayerPreload.instance.clear()
        
        self.isHome = isHome
        self.isFeed = isFeed
        self.isProfile = isProfile
        self.cleepsCountry = cleepsCountry ?? .indo
        self.mainView = mainView
        self.presenter = presenter
        self.enableRefresh = enableRefresh
        self.showBottomCommentSectionView = showBottomCommentSectionView
        self.resetFilterCache = resetFilterCache
        
        super.init(nibName: nil, bundle: SharedBundle.shared.bundle)
        
        LOG_ID = LOG_ID + self.presenter.identifier.rawValue
        KEY_LAST_OPEN_CLEEP = KEY_LAST_OPEN_CLEEP + presenter.identifier.rawValue
        self.hasDeleted = hasDeleted
        self.displaySingle = displaySingle
        self.seenFeeds = FeedSeenCache.instance.getSeenFeeds(forKey: self.presenter.identifier.rawValue)
        
        if displaySingle {
            self.prefetchGivenFeeds(feeds: feed)
        } else {
            self.data = feed
        }
        
        self.isTabFollowing = presenter.identifier == .following
        self.autoCloseProductCountdown = CountdownManager(notificationCenter: NotificationCenter.default, willResignActive: UIApplication.willResignActiveNotification, willEnterForeground: UIApplication.willEnterForegroundNotification)
    }
    
    public override var prefersStatusBarHidden: Bool {
        return true
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        handleViewDidLoad()
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        handleViewDidAppear()
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        handleViewWillDisappear()
    }
    
    public override func loadView() {
        view = mainView
        view.backgroundColor = .black
        mainView.backgroundColor = .black
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        handleViewWillAppear()
    }
    
    public override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        handleViewDidDisappear()
    }
    
    public override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        print("MEMIssue", "FeedCleepsController", self.presenter.identifier)
        self.presenter.clearCache()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented, You should't initialize the ViewController through Storyboards")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    public func filterBy(provinceId: String?) {
        presenter.filterByCurrentLocation = nil
        presenter.filterByProvinceId = provinceId
        autoScrollToFirstIndex = true
        mainView.bottomLoading.startAnimating()
        refresh()
    }
    
    public func filterByCoordinate(longitude: Double?, latitude: Double?) {
        presenter.filterByProvinceId = nil
        presenter.filterByCurrentLocation = (longitude, latitude)
        autoScrollToFirstIndex = true
        mainView.bottomLoading.startAnimating()
        refresh()
    }
    
    public func filterByAllLocation() {
        presenter.filterByProvinceId = nil
        presenter.filterByCurrentLocation = nil
        autoScrollToFirstIndex = true
        mainView.bottomLoading.startAnimating()
        refresh()
    }
}

extension FeedCleepsViewController: UICollectionViewDataSource {
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 {
            return data.count
        } else if isShowTiktokEmptyView && userSuggestItems.isEmpty && section == 1 {
            return 1
        } else if isShowTiktokEmptyView && isTabFollowing && data.isEmpty && section == 2 {
            return 1
        } else if isShowLoadError && section == 3 {
            return 1
        } else {
            return 0
        }
    }
    
    public func numberOfSections(in collectionView: UICollectionView) -> Int { 4 }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TiktokPostViewCell", for: indexPath) as! TiktokPostViewCell
        cell.commentSectionView.isHidden = !showBottomCommentSectionView
        if indexPath.section == 0 {
            if(indexPath.item < data.count) {
                cell.weakParent = self
                cell.isLogin = self.isLogin
                var feed = data[indexPath.item]
                
                if presenter.identifier == .donation || feed.typePost ?? "" == "donation" {
                    let filterOnlyVideo = feed.post?.medias?.filter({ $0.type == "video" })
                    feed.post?.medias = filterOnlyVideo
                }
                
                if feed.typePost ?? "" == "donation" {
                    switch presenter.identifier {
                    case .donation, .profile(isSelf: true), .profile(isSelf: false):
                        cell.donationContainerStackView.isHidden = false
                        cell.donationCategoryContainetView.isHidden = false
                        cell.donationCategoryLabel.isHidden = false
                    default:
                        cell.donationContainerStackView.isHidden = true
                        cell.donationCategoryContainetView.isHidden = true
                        cell.donationCategoryLabel.isHidden = true
                    }
                } else {
                    cell.donationContainerStackView.isHidden = true
                    cell.donationCategoryContainetView.isHidden = true
                    cell.donationCategoryLabel.isHidden = true
                }
                
                cell.feed = feed
                cell.userID = presenter.userId
                cell.setupRecomendation(feed: feed)
                var limitTextCaption: Int? = nil
                if self.presenter.identifier == .donation || feed.typePost == "donation" {
                    limitTextCaption = 33
                }
                cell.setupViewWithFeed(isCleeps: presenter.isCleeps(), limitTextCaption: limitTextCaption)
                cell.showOrHideNewsExternal(with: presenter.identifier)
                cell.shortcutLiveStreaming.isHidden = !isLogin
                cell.shortcutLiveStreaming.onTap { [weak self] in
                    self?.showLiveStreamingList?()
                }
                
                if feed.trendingAt ?? 0 == 0 {
                    cell.bottomConstraintLiveStreaming = cell.shortcutLiveStreaming.anchors.bottom.equal(cell.profileView.anchors.top, constant: -16)
                } else {
                    cell.bottomConstraintLiveStreaming = cell.shortcutLiveStreaming.anchors.bottom.equal(cell.trendingAtContainerStackView.anchors.top, constant: -16)
                }
                self.preloadEach(startIndex: 0)
                
                switch presenter.identifier {
                case .feed, .explore, .channelContents, .search, .hashtag(_), .cleeps(_):
                    cell.postedDateLabel.isHidden = true
//                    cell.paidMessageContainerStackView.isHidden = feed.account?.id ?? "" == presenter.userId ? true : feed.account?.isVerified == true ? false : true
                case .profile(isSelf: false):
                    let isDonation = feed.typePost == "donation"
                    cell.postedDateLabel.isHidden = false
//                    cell.paidMessageContainerStackView.isHidden = feed.account?.id ?? "" == presenter.userId ? true : feed.account?.isVerified == true ? isDonation : true
                case .donation:
                    cell.postedDateLabel.isHidden = true
                    cell.paidMessageContainerStackView.isHidden = true
                default:
                    cell.paidMessageContainerStackView.isHidden = true
                }
                
                cellHandlers(cell, indexPath, collectionView)
                
//                cell.newsExternal.delegate = self
//                cell.newsExternal.dataSource = self
                
                if(isDidAppear == true){
                    if(startItemFromIndex > 0 && isFirstLoad) {
                        isFirstLoad = false
                        DispatchQueue.main.async { [weak self] in
                            guard let self = self else { return }
                            if let cell = self.mainView.collectionView.cellForItem(at: IndexPath(item: self.startItemFromIndex, section: 0)) as? TiktokPostViewCell {
                                self.resetFeedbar()
                                self.lastActiveCells.append(cell)
                                self.setupCellBar()
                                cell.feed = feed
                            }
                        }
                    } else {
                        if(indexPath.item == 0){
                            DispatchQueue.main.async { [weak self] in
                                guard let self = self else { return }
                                
                                if(indexPath.item == 0){
                                    self.resetFeedbar()
                                    self.setupCellBar()
                                    cell.feed = feed
                                    self.preloadEach(startIndex: 1)
                                    cell.getMediaCell{ [weak self] mediaCell in
                                        guard let self = self else { return }
                                        if(self.LOG_MEDIA_NAME){
                                            //cell.usernameLabel.text = mediaCell.getMediaNameMP4()
                                            cell.usernameLabel.text = KKVideoId().getId(urlString: mediaCell.getMediaNameMP4())
                                        }
                                        
                                        DispatchQueue.main.async {
//                                            cell.checkAutoplay(fromBegining: !self.isSameVideo(with: mediaCell))
                                            self.playVisibleCell(preferIndex: indexPath)
                                        }
                                    }
                                    
                                    DispatchQueue.main.async {
                                        self.presenter.isCleeps() ? cell.stopTimer() : cell.startTimer()
                                    }
                                    
                                    if let feed = cell.feed {
                                        self.setSeen(feed: feed)
                                    }
                                    
                                    self.forceAppendDataUnready()
                                }
                            }
                        }
                    }
                }
            }
            return cell
        } else if indexPath.section == 1 {
            
            if presenter.identifier == .donation {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DonationFilterEmptyCollectionViewCell", for: indexPath) as! DonationFilterEmptyCollectionViewCell
                
                mainView.bottomLoading.stopAnimating()
                cell.emptyDonationContainerStackView.isHidden = !self.presenter.donationCategoryId.isEmpty
                cell.emptyFilterDonationContainerStackView.isHidden = self.presenter.donationCategoryId.isEmpty
                
                cell.handleReloadData = { [weak self] in
                    guard let self = self else { return }
                    self.isShowTiktokEmptyView = false
                    
                    print("**** cellForItemAt \(self.presenter.identifier.rawValue) refresh()")
                    self.resetFilterCache()
                    self.filterByAllLocation()
                }
                
                cell.handleTapFilterButton = { [weak self] in
                    guard let self = self else { return }
                    
                    self.router?.onClickDonationCategory(categoryId: self.presenter.donationCategoryId, completion: { [weak self] (categoryId) in
                        guard let self = self else { return }
                        self.presenter.donationCategoryId = categoryId
                        self.autoScrollToFirstIndex = true
                        self.mainView.bottomLoading.startAnimating()
                        self.refresh()
                    })
                }
                return cell
            }
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TiktokContentEmptyCollectionViewCell", for: indexPath) as! TiktokContentEmptyCollectionViewCell
            mainView.bottomLoading.stopAnimating()
            cell.onRefresh = { [weak self] in
                guard let self = self else { return }
                self.isShowTiktokEmptyView = false
                self.refresh()
                self.mainView.bottomLoading.startAnimating()
            }
            return cell
            
        } else if indexPath.section == 2 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TiktokFollowingCleepsCell", for: indexPath) as! TiktokFollowingCleepsCell
            cell.users = userSuggestItems
            cell.handleTapUserProfile = { [weak self] id in
                guard let self = self else { return }
                self.router?.onClickProfile(id: id, type: "", { [weak self] isFollowing in
                    guard let self = self else { return }
                    guard let index = self.userSuggestItems.firstIndex(where: { $0.account?.id ?? "" == id }) else {
                        return
                    }
                    
                    self.userSuggestItems[index].account?.isFollow = isFollowing
                    cell.users = self.userSuggestItems
                })
            }
            
            cell.handleTapUserPostImage = { [weak self] id, feed in
                guard let self = self else { return }
                guard let feed = feed else { return }
                self.router?.detailPost(userId: id, item: feed)
            }
            
            cell.handleFollowButton = { [weak self] userId, isFollow in
                guard let self = self else { return }
                self.presenter.updateFollowUser(id: userId, isFollow: isFollow)
            }
            
            cell.handleShowSuggest = { [weak self] in
                guard let self = self else { return }
                self.refresh()
            }
            
            cell.handleLoadmore = { [weak self] in
                guard let self = self else { return }
                if self.presenter.userSuggestPage < self.presenter.userSuggestTotalPage {
                    self.presenter.userSuggestPage += 1
                    self.presenter.requestFollowingSuggestion()
                    return
                }
                cell.pagerView.isInfinite = true
            }
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CleepsLoadErrorCell", for: indexPath) as! CleepsLoadErrorCell
            self.mainView.bottomLoading.stopAnimating()
            cell.onRefresh = { [weak self] in
                guard let self = self else { return }
                self.isShowLoadError = false
                self.refresh()
                self.mainView.bottomLoading.startAnimating()
            }
            return cell
        }
    }
    
    fileprivate func cellHandlers(_ cell: TiktokPostViewCell, _ indexPath: IndexPath, _ collectionView: UICollectionView) {
        cell.likeFeed = { [weak self] feed in
            guard let self = self else { return }
            
            guard self.isLogin else {
                self.isDidAppear = false
                self.pauseVisibleCell()
                self.router?.onShowAuthPopUp(){ [weak self] in
                    guard let self = self else { return }
                    self.isDidAppear = true
                    self.playVisibleCell()
                }
                return
            }
            
            guard ReachabilityNetwork.isConnectedToNetwork() else {
                DispatchQueue.main.async { Toast.share.show(message: .get(.noInternetConnection)) }
                return
            }
            
            self.presenter.updateLikeFeed(feed) { [weak self] in
                guard let self = self else { return }
                guard !self.data.isEmpty, self.data.count > indexPath.item else { return }
                self.data[indexPath.item] = feed
            }
            self.router?.onClickLike(item: feed)
        }
        
        cell.commentHandler = { [weak self] (item, autoFocus) in
            guard let self = self else { return }
            guard let id = item.id else { return }
            
            guard self.isLogin else {
                self.isDidAppear = false
                self.pauseVisibleCell()
                self.router?.onShowAuthPopUp(){ [weak self] in
                    guard let self = self else { return }
                    self.isDidAppear = true
                    self.playVisibleCell()
                }
                return
            }
            
            self.commentSheetDisplayed = true
            self.presenter.selectedCommentIndex = indexPath.item
            self.router?.onClickComment(id: id, item: item, indexPath: indexPath, autoFocusToField: autoFocus, identifier: self.presenter.identifier.rawValue)
        }
        
        cell.backHandler = { [weak self] in
            guard let self = self else { return }
            self.navigationController?.popViewController(animated: true)
        }
        
        cell.profileHandler = { [weak self] id, type in
            guard let self = self else { return }
            guard self.isLogin else {
                self.isDidAppear = false
                self.pauseVisibleCell()
                self.router?.onShowAuthPopUp(){ [weak self] in
                    guard let self = self else { return }
                    self.isDidAppear = true
                    self.playVisibleCell()
                }
                return
            }
            
            self.router?.onClickProfile(id: id, type: type, { [weak self] isFollow in
                guard let self = self else { return }
                cell.followIconImageView.isHidden = isFollow
                self.data[indexPath.item].account?.isFollow = isFollow
                let feed = self.data[indexPath.item]
                self.delegate?.updateUserFollowStatus(feedId: feed.id ?? "", accountId: feed.account?.id ?? "", isFollow: isFollow, name: feed.account?.name ?? "", photo: feed.account?.photo ?? "")
            })
        }
        
        cell.userNameHandler = { [weak self] id, type in
            guard let self = self else { return }
            guard self.isLogin else {
                self.isDidAppear = false
                self.pauseVisibleCell()
                self.router?.onShowAuthPopUp(){  [weak self] in
                    guard let self = self else { return }
                    self.isDidAppear = true
                    self.playVisibleCell()
                }
                return
            }
            
            self.router?.onClickProfile(id: id, type: type, { [weak self] isFollow in
                guard let self = self else { return }
                cell.followIconImageView.isHidden = isFollow
                self.data[indexPath.item].account?.isFollow = isFollow
                let feed = self.data[indexPath.item]
                self.delegate?.updateUserFollowStatus(feedId: feed.id ?? "", accountId: feed.account?.id ?? "", isFollow: isFollow, name: feed.account?.name ?? "", photo: feed.account?.photo ?? "")
            })
        }
        
        cell.shareHandler = {  [weak self] in
            guard let self = self else { return }
            self.router?.onClickShare(item: self.data[indexPath.item])
        }
        
        cell.mentionHandler = { [weak self] mention in
            guard let self = self else { return }
            guard self.isLogin else {
                self.isDidAppear = false
                self.pauseVisibleCell()
                self.router?.onShowAuthPopUp(){ [weak self] in
                    guard let self = self else { return }
                    self.isDidAppear = true
                    self.playVisibleCell()
                }
                return
            }
            
            self.presenter.detail(mention)
        }
        
        cell.hashtagHandler = { [weak self] hashtag in
            guard let self = self else { return }
            guard self.isLogin else {
                self.isDidAppear = false
                self.pauseVisibleCell()
                self.router?.onShowAuthPopUp(){ [weak self] in
                    guard let self = self else { return }
                    self.isDidAppear = true
                    self.playVisibleCell()
                }
                return
            }
            
            self.router?.onClickHashtag(hashtag: hashtag)
        }
        
        cell.productBeliOnClick = { [weak self] (productId, product, feed) in
            guard let self = self else { return }
            self.router?.onClickProductDetail(id: productId, product: product, item: feed)
        }
        
        cell.productBgOnClick = { [weak self] (feed) in
            guard let self = self else { return }
            self.router?.onClickProductBg(item: feed)
        }
        
        cell.followIconOnClick = { [weak self] feed in
            guard let self = self else { return }
            
            guard self.isLogin else {
                self.isDidAppear = false
                self.pauseVisibleCell()
                self.router?.onShowAuthPopUp(){ [weak self] in
                    guard let self = self else { return }
                    self.isDidAppear = true
                    self.playVisibleCell()
                }
                return
            }
            
            DispatchQueue.main.async {
                Toast.share.show(duration: 1.5, message: .get(.followed), .left)
            }
            self.presenter.updateFollowUser(id: feed.account?.id ?? "", isFollow: feed.account?.isFollow ?? false)
            self.data[indexPath.item].account?.isFollow = true
            self.data[indexPath.item].isFollow = true
            cell.followIconImageView.isHidden = true
            self.delegate?.updateUserFollowStatus(feedId: feed.id ?? "", accountId: feed.account?.id ?? "", isFollow: feed.account?.isFollow ?? false, name: feed.account?.name ?? "", photo: feed.account?.photo ?? "")
        }
        
        cell.donationCategoryOnClick = { [weak self] feed in
            guard let self = self else { return }
            self.router?.onClickDonationCategory(categoryId: self.presenter.donationCategoryId, completion: { [weak self] (categoryId) in
                guard let self = self else { return }
                self.presenter.donationCategoryId = categoryId
                self.autoScrollToFirstIndex = true
                self.refresh()
            })
        }
        
        cell.donationCardOnClick = { [weak self] feed in
            guard let self = self else { return }
            self.router?.onClickDonationCard(item: feed)
        }
        
        cell.floatingLinkOnClick = { [weak self] feed in
            guard let self = self, let url = feed.post?.floatingLink else { return }
            self.router?.onClickFloatingLink(url: url)
        }
        
        cell.cnnHandler = { [weak self] in
            guard let self = self else { return }
            self.pauseVisibleCell()
            self.router?.onClickNewsPortal(url: "https://www.cnnindonesia.com/") { [weak self] in
                guard let self = self else { return }
                self.playVisibleCell()
            }
        }

        cell.detikHandler = { [weak self] in
            guard let self = self else { return }
            self.pauseVisibleCell()
            self.router?.onClickNewsPortal(url: "https://www.detik.com/") { [weak self] in
                guard let self = self else { return }
                self.playVisibleCell()
            }
        }

        cell.kompasHandler = { [weak self] in
            guard let self = self else { return }
            self.pauseVisibleCell()
            self.router?.onClickNewsPortal(url: "https://www.kompas.com") { [weak self] in
                guard let self = self else { return }
                self.playVisibleCell()
            }
        }

        cell.suaraHandler = { [weak self] in
            guard let self = self else { return }
            self.pauseVisibleCell()
            self.router?.onClickNewsPortal(url: "https://www.suara.com/") { [weak self] in
                guard let self = self else { return }
                self.playVisibleCell()
            }
        }

        cell.cumicumiHandler = { [weak self] in
            guard let self = self else { return }
            self.pauseVisibleCell()
            self.router?.onClickNewsPortal(url: "https://www.cumicumi.com/") { [weak self] in
                guard let self = self else { return }
                self.playVisibleCell()
            }
        }
        
        cell.startPaidMessageHandler = { [weak self] feed in
            guard let self = self else { return }
            
            guard self.isLogin else {
                self.isDidAppear = false
                self.pauseVisibleCell()
                self.router?.onShowAuthPopUp(){ [weak self] in
                    guard let self = self else { return }
                    self.isDidAppear = true
                    self.playVisibleCell()
                }
                return
            }
            
            self.pauseVisibleCell()
            self.router?.onStartPaidMessage(userId: feed.account?.id, name: feed.account?.name, avatar: feed.account?.photo, isVerified: feed.account?.isVerified)
        }
    }
}

extension FeedCleepsViewController: UICollectionViewDelegateFlowLayout {
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size = UIScreen.main.bounds.size
        var height = size.height
        let window = UIApplication.shared.windows.first
        if isHome {
            height -= (tabBarController?.tabBar.frame.height ?? 83)
        }else{
            height -=  (window?.safeAreaInsets.bottom ?? 34)
        }
        return CGSize(width: size.width, height: height)
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat { 0 }
}

extension FeedCleepsViewController: UICollectionViewDelegate {
    
    public func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let cell = mainView.collectionView.visibleCells.first as? TiktokPostViewCell
        
        if indexPath.section == 0 {
            INDEX_ROW_SHOWING = indexPath.item
            
            if(indexPath.item % 2 == 0){
                syncFeedSeenFailed()
            }
            
            if let cell = cell {
                cell.getMediaCell{ [weak self] mediaCell in
                    guard self != nil else { return }
                    
                    mediaCell.playImageView.isHidden = true
                    cell.isVideoPlaying = { isPlaying in
                        if !isPlaying {
                            mediaCell.showCover()
                        }
                    }
                    
                    if(self!.LOG_MEDIA_NAME){
                        //cell.usernameLabel.text = mediaCell.getMediaNameMP4()
                        cell.usernameLabel.text = KKVideoId().getId(urlString: mediaCell.getMediaNameMP4())
                    }
                }
                
                if let feed = cell.feed {
                    self.setSeen(feed: feed)
                }
            }
        }
    }
    
    public func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            if let cell = cell as? TiktokPostViewCell {
                if(indexPath.item > 0 ){
                    cell.getMediaCell { [weak self] mediaCell in
                        guard self != nil else { return }
                        let url = cell.feed?.post?.medias?.first?.url ?? ""
                        //KKPreload.instance.removeUrlPreload(url: url, code: (self?.presenter.identifier.rawValue)!)
                        if let feed = cell.feed {
                            self?.presenter.reservedResourceVideo(feed: feed)
                        }
                        
                    }
                    
                    let firstIndex = self.MAX_MARGIN_SHOW_CLEEPS + indexPath.item
                    var lastIndex = self.MAX_MARGIN_SHOW_CLEEPS + indexPath.item
                    
                }
                
                cell.didEndDisplaying(fromComment: commentSheetDisplayed,
                                      cleepsCountry: cleepsCountry,
                                      isCleeps: presenter.isCleeps())
                cell.onPause()
                let fullyVisibleIndexPaths = collectionView.indexPathsForFullyVisibleItems()
                fullyVisibleIndexPaths.forEach{ visibleIndexPath in
                    if(visibleIndexPath.item == indexPath.item) {
                        cell.onPause()
                    }
                }
            }
        }
    }
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        var visibleRect = CGRect()
        
        visibleRect.origin = mainView.collectionView.contentOffset
        visibleRect.size = mainView.collectionView.bounds.size
        let visiblePoint = CGPoint(x: visibleRect.midX, y: visibleRect.midY)
        guard let indexPath = mainView.collectionView.indexPathForItem(at: visiblePoint) else { return }
        if let cell = mainView.collectionView.cellForItem(at: indexPath) as? TiktokPostViewCell {
            cell.newsExternal.close()
            cell.getMediaCell { itemCell in
                if itemCell.filteredImageView.layer.name != UserDefaults.standard.string(forKey: "last_video_play_id") {
                    if !isReset {
                        KKVideoManager.instance.player.pause()
                    }
                }
            }
        }
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        var visibleRect = CGRect()
        visibleRect.origin = mainView.collectionView.contentOffset
        visibleRect.size = mainView.collectionView.bounds.size
        let visiblePoint = CGPoint(x: visibleRect.midX, y: visibleRect.midY)
        guard let indexPath = mainView.collectionView.indexPathForItem(at: visiblePoint) else { return }
        
        if(isShowTiktokEmptyView){
            mainView.collectionView.customReloadSections(IndexSet(integer: 1))
        }
        
        if visibleRect.origin.y.truncatingRemainder(dividingBy: visibleRect.size.height) != 0 {
            self.mainView.collectionView.scrollToItem(at: indexPath, at: .centeredVertically, animated: true)
        }
        
        self.getNextPage()
                
        //PE-10436, ignore check if this last feed
        if(!self.isLastFeed()){
            guard indexPath.item != self.currentIndex else { return }
        }
        print(self.LOG_ID, "scrollViewDidEndDecelerating ", "continue")
        
        self.currentIndex = indexPath.item
        
        self.setupDataToPreload()
        
        if KKVideoManager.instance.type == .tencent{
            KKTencentVideoPlayerPreload.instance.currentIndex = self.currentIndex
        }

        if let cell = mainView.collectionView.cellForItem(at: indexPath) as? TiktokPostViewCell {
            if(!lastActiveCells.contains(cell)) {
                resetFeedbar()
            }
            
            lastActiveCells.append(cell)
            pauseVisibleCell()
            cell.removeFeedbar()
            cell.setupFeedbar()
            cell.feedbarController?.animate()
            cell.checkAutoplay()
            
            if let feed = cell.feed {
                                
                self.setSeen(feed: feed)
                
                if(self.isLastFeed()){
                    DispatchQueue.main.async {
                        self.forceAppendDataUnready()
                    }
                }
                
                cell.getMediaCell { [weak self] mediaCell in
                    guard self != nil else { return }
                    
                    if(mediaCell.getMediaNameMP4() != ""){
                        self?.presenter.reservedResourceVideo(feed: feed)
                    }
                    
                    if(self!.LOG_MEDIA_NAME){
                        //cell.usernameLabel.text = mediaCell.getMediaNameMP4()
                        cell.usernameLabel.text = KKVideoId().getId(urlString: mediaCell.getMediaNameMP4())
                    }
                    
                    if !mediaCell.isImage {
                        self?.playVisibleCell(preferIndex: indexPath)
                    }
                }
            }
            
            presenter.isCleeps() ? cell.stopTimer() : cell.startTimer()
            
            if cell.feed?.post?.product != nil {
                autoCloseProductCountdown?.stopTimer()
                autoCloseProductCountdown?.startTimer(timeLeft: 4)
            } else {
                autoCloseProductCountdown?.stopTimer()
            }
            
            return
        } else {
            KKVideoManager.instance.player.pause()
        }
    }
}

extension FeedCleepsViewController {
    private func handleViewDidLoad() {
        setCleepsNavigationbarTransparent()
        enableNavigationBackGesture()
        //enableTimerPrintLogDataUnread()
        //KKPreload.instance.timerProcess()
        autoCloseProductCountdown?.setupObserver()
        autoCloseProductCountdown?.didFinishCountdown = { [weak self] in
            guard let self = self else { return }
            if let cell = self.mainView.collectionView.visibleCells.first as? TiktokPostViewCell {
                cell.closeProductCard()
            }
        }
        
        setKeyLastOpen()
        configureCollectionViewAndRefreshControl()
        bindObserver()

        if isLogin && data.isEmpty {
            mainView.bottomLoading.startAnimating()
        }
        
        if hasDeleted {
            mainView.loading.stopAnimating()
            mainView.changeCollectionViewBackgroundToDeletedPost()
            return
        }
        
        mainView.collectionView.bounces = isHome
        mainView.collectionView.isPagingEnabled = true
        mainView.collectionView.scrollsToTop = false
        isFinishRefresh = true
        isFirstOpenPage = true
        isGettingNextPage = false
        
        if data.isEmpty {
            refresh()
        }
    }
    
    private func handleViewDidAppear() {
        isDidAppear = true
        setCleepsNavigationbarTransparent()
        //KKPreload.instance.activeCode = presenter.identifier.rawValue
        //KKPreload.instance.timerProcess()
        refreshIfDataIsOld()
        
        if isAlreadyOpen {
            mainView.collectionView.reloadData()
            
            if data.isEmpty {
                isFirstReload = true
            }

            isAlreadyOpen = false
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(enterForegroundPlayVideo), name: .notifyWillEnterForeground, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
        setupCellBar()
        
        if isDidAppear {
            //KKResourceLoader.instance.currentPresenterId = self.presenter.identifier.rawValue
            playVisibleCell()
        }
        
        UIApplication.shared.statusBarStyle = .lightContent
    }
    
    private func handleViewWillDisappear() {
        self.isDidAppear = false
        autoCloseProductCountdown?.removeObserver()
        KKVideoManager.instance.player.pause()
    }
    
    private func handleViewWillAppear() {
        self.isDidAppear = true
        setCleepsNavigationbarTransparent()
        setupCellBar()
        resumeAllThisCode()
    }
    
    private func handleViewDidDisappear() {
        self.isDidAppear = false
        
        KKVideoManager.instance.player.pause()
        
        KKTencentVideoPlayerPreload.instance.removeAllQueue(queueId: self.presenter.identifier.rawValue)
        
        navigationController?.navigationBar.backgroundColor = .clear
        presenter.worker?.cancel()
        resetFeedbar(stopPlayer: true)
        pauseAllThisCode()
        NotificationCenter.default.removeObserver(self, name: .notifyWillEnterForeground, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIApplication.didBecomeActiveNotification, object: nil)
        setKeyLastOpen()

        if let cell = mainView.collectionView.visibleCells.first as? TiktokPostViewCell {
            cell.getMediaCell{ [weak self] mediaCell in
                guard self != nil else { return }
                mediaCell.playerLayerAlpha.set(item: nil)
            }
            cell.stopTimer()
            cell.sendAnalyticsToFirebase(cleepsCountry: cleepsCountry, isCleeps: presenter.isCleeps())
            cell.setupDescription()
        }
        UIApplication.shared.statusBarStyle = .darkContent
    }
}

extension FeedCleepsViewController {
    
    @objc func willResignActive(_ notification: Notification) {
        self.isDidAppear = false
        pauseVisibleCell()
        setKeyLastOpen()
    }
    
    func resumeAllThisCode(){
        self.dataUnready.forEach { feed in
            let urlMedia = feed.post?.medias?.first?.url ?? ""
            //KKResourceLoader.instance.resume(urlString: urlMedia)
        }
    }
    
    func pauseAllThisCode(){
        self.dataUnready.forEach { feed in
            let urlMedia = feed.post?.medias?.first?.url ?? ""
            //KKResourceLoader.instance.pause(urlString: urlMedia)
        }
    }
    
    private func configureCollectionViewAndRefreshControl(){
        view.layoutIfNeeded()
        mainView.collectionView.register(UINib(nibName: "TiktokEmptyPostCell", bundle: SharedBundle.shared.bundle), forCellWithReuseIdentifier: "TiktokEmptyPostCell")
        mainView.collectionView.register(UINib(nibName: "CleepsLoadErrorCell", bundle: SharedBundle.shared.bundle), forCellWithReuseIdentifier: "CleepsLoadErrorCell")
        mainView.collectionView.register(UINib(nibName: "TiktokFollowingCleepsCell", bundle: SharedBundle.shared.bundle), forCellWithReuseIdentifier: "TiktokFollowingCleepsCell")
        mainView.collectionView.register(UINib(nibName: "TiktokContentEmptyCollectionViewCell", bundle: SharedBundle.shared.bundle), forCellWithReuseIdentifier: "TiktokContentEmptyCollectionViewCell")
        mainView.collectionView.register(UINib(nibName: "DonationFilterEmptyCollectionViewCell", bundle: SharedBundle.shared.bundle), forCellWithReuseIdentifier: "DonationFilterEmptyCollectionViewCell")
        
        mainView.collectionView.contentInsetAdjustmentBehavior = .never
        mainView.collectionView.delegate = self
        mainView.collectionView.dataSource = self
        mainView.collectionView.allowsSelection = true
        
        if enableRefresh {
            mainView.collectionView.addSubview(refreshControl)
            mainView.collectionView.bringSubviewToFront(refreshControl)
            mainView.collectionView.refreshControl = refreshControl
            refreshControl.tintColor = .primaryPink
            refreshControl.anchorFeedCleeps(top: mainView.topAnchor,  paddingTop: 150)
            refreshControl.centerXAnchor.constraint(equalTo: mainView.collectionView.centerXAnchor).isActive = true
            refreshControl.addTarget(self, action: #selector(pullToRefresh), for: .valueChanged)
            refreshControl.alpha = 0.0
            mainView.reloadButton.addTarget(self, action: #selector(refresh), for: .touchUpInside)
        }
        
        mainView.handleLogin = { [weak self] in
            self?.router?.onClickLogin()
        }
    }
    
    @objc private func pullToRefresh() {
        autoScrollToFirstIndex = true
        refresh()
    }
    
    func enableTimerPrintLogDataUnread(){
        Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { [weak self] timer in
            guard let self = self else { return }

            if(self.isDidAppear){
                print(self.LOG_ID, "KKPreloadReady dataUnready count:......", self.dataUnready.count)
            }
        }
    }

    
    @objc func swipeUpBackGesture(gesture: UISwipeGestureRecognizer) {
        customDismissAnimation()
        navigationController?.dismiss(animated: true)
    }
    
    private func customDismissAnimation() {
        let transition: CATransition = CATransition()
        transition.duration = 0.5
        transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        transition.type = CATransitionType.push
        transition.subtype = CATransitionSubtype.fromTop
        view.window!.layer.add(transition, forKey: nil)
        dismiss(animated: false) {
            self.navigationItem.rightBarButtonItem = nil
        }
    }
    
    public func updateFeedAccountIsFollow(feedId: String, accountId: String, isFollow: Bool, name: String, photo: String) {
        FollowingUsers.shared.save(id: accountId, isFollow: isFollow, name: name, photo: photo)
        for (index, element) in data.enumerated() {
            if element.account?.id ?? "" == accountId && element.id ?? "" != feedId {
                data[index].account?.isFollow = isFollow
                data[index].isFollow = isFollow
                
                DispatchQueue.main.async {
                    self.mainView.collectionView.customReloadItems(at: [IndexPath(item: index, section: 0)])
                }
            }
        }
    }
    
    func prefetchGivenFeeds(feeds: [Feed]) {
        if !feeds.isEmpty {
            presenter.prefetchImages(feeds)
            DispatchQueue.main.async {
                if self.data.isEmpty {
                    self.updateFirstIndexFeed(feed: feeds.first)
                }
                self.mainView.loading.stopAnimating()
            }
        }
    }

    func updateFirstIndexFeed(feed: Feed?) {
        guard let firstFeed = feed else { return }
        data.insert(firstFeed, at: 0)
        mainView.collectionView.customReloadSections([0])
        uploadPostContent = false
    }
    
    func setKeyLastOpen() {
        let currentTimeStamp = Date().timeIntervalSince1970
        let currentTimeStampString = String(format: "%f", currentTimeStamp)
        DataCache.instance.write(string: currentTimeStampString, forKey: KEY_LAST_OPEN_CLEEP)
    }

    func syncFeedSeenFailed() {
        
        return
        
        let feedSeenFaileds = FeedSeenFailedCache.instance.getAll(id: presenter.identifier.rawValue)
        if(feedSeenFaileds.count > 0){
            feedSeenFaileds.forEach{ feedSeenFailed in
                
                print(self.LOG_ID, "---seen syncFeedSeenFailed", feedSeenFailed )
                presenter.updateFeedAlreadySeen(feedId: feedSeenFailed) { [weak self] success in
                    guard let self = self else { return }
                    if success {
                        FeedSeenFailedCache.instance.remove(id: self.presenter.identifier.rawValue, feedId: FeedId(id: feedSeenFailed))
                    } else {
                        FeedSeenFailedCache.instance.add(id: self.presenter.identifier.rawValue, feedId: FeedId(id: feedSeenFailed))
                    }
                }
            }
        }
    }
    
    func populateDataUnready() {
        if(self.uniqueFeedToAppends.count > 0) {
            if(self.data.count == 0){
                if let firstUnique = self.uniqueFeedToAppends.first {
                    print(LOG_ID, "Force-1", firstUnique.post?.medias?.first?.url ?? "")
                    self.data.append(firstUnique)
                    self.mainView.collectionView.reloadData()
                    self.uniqueFeedToAppends.removeAll(where: { $0.id == firstUnique.id })
                }
            } else {

                // only force append when data is "fresh" (fix: PE-10092)
                if(self.currentIndex == 0){
                    if let firstUnique = self.uniqueFeedToAppends.first {

                        print(LOG_ID, "Force-2", firstUnique.post?.medias?.first?.url ?? "")
                        self.updateCollectionViewDataSingle(with: firstUnique)
                    }
                }
            }

            self.uniqueFeedToAppends.forEach({ feed  in
                let existingDataUnready = self.dataUnready.filter{ $0.id == feed.id }.first
                
                if(existingDataUnready == nil){
                    self.dataUnready.append(feed)
                }
            })
        }

        if self.mainView.collectionView.indexPathsForVisibleItems.contains(where: { $0.item == 0}) {
            self.forceAppendDataUnready()
        }

        self.setupDataToPreload()
    }
    
    func isLastFeed() -> Bool {

        if(self.data.count == self.currentIndex + 1){
            return true
        }

        return false
    }

    func isMP4(feed: Feed)->Bool{
        if let vodUrl = feed.post?.medias?.first?.vodUrl {
            if vodUrl.lowercased().contains(".mp4") {
                return true
            }
        }
        
        return false
    }
    
    func isVideo(feed: Feed)->Bool{
        if let vodUrl = feed.post?.medias?.first?.vodUrl {
            if vodUrl.lowercased().contains(".mp4") {
                return true
            }
            if vodUrl.lowercased().contains(".m3u8") {
                return true
            }
        }
        
        return false
    }

    
    fileprivate func populateFeedQueue(_ dataNew: [Feed], _ self: FeedCleepsViewController) {
        print(LOG_ID, "POPULATE INIT")
        var dataToAppends = [Feed]()
        var dataNewCount = 0
        dataNew.forEach({ feed  in

            //ignore MP4
            //if !self.isMP4(feed: feed) {
                if self.isUniqueFeed(feed: feed) {
                    dataNewCount = dataNewCount + 1
                    dataToAppends.append(feed)
                    print(LOG_ID,"== trend__ A.PROCESS==",
                          KKVideoId().getId(urlString: feed.post?.medias?.first?.playURL ?? ""),feed.account?.username ?? "")
                } else {
                    //print(LOG_ID,"== trend__ A.IGNORE==", feed.post?.medias?.first?.url?.suffix(18) ?? "",feed.account?.username ?? "")
                }
            //}
        })
        
        var feedSets = Set<Feed>()
        // remove duplicate feed id in one Page
        dataToAppends = dataToAppends.lazy.filter { (data) -> Bool in
            if !feedSets.contains(data){
                feedSets.insert(data)
                return true
            }
            return false
        }
        
        dataToAppends.forEach{ feed in
            self.uniqueFeedToAppends.append(feed)
            print(LOG_ID,"== trend__ X  ", KKVideoId().getId(urlString: feed.post?.medias?.first?.vodUrl),
                  feed.account?.username ?? "")
        }
        
//        let MIN_DATA_TO_SHOW = 5
//        if uniqueFeedToAppends.count < MIN_DATA_TO_SHOW && isReset {
//            self.presenter.totalPageLookup += 1
//            getNextPage()
//            if(presenter.requestedPage > MAX_PAGE_TO_LOOKUP){
//                isReset = false
//                presenter.requestedPage = 0
//                getNetworkFeed(isTrending: true)
//            } else {
//                if(presenter.totalPageLookup < MAX_PAGE_TO_LOOKUP){

//                }
//            }
//        } else if !isFirstReload {
//            isReset = true
//        }
        
//        if uniqueFeedToAppends.count > MIN_DATA_TO_SHOW {
//
//            print(LOG_ID, "getNextPage line:535 MUTATE-totalPageLookup ", presenter.requestedPage)
//            self.presenter.totalPageLookup = 0
//        }
        
        // rule : if Cleeps NOT Appear, then only ALLOW queue Video lower than MAX_QUEUE
        // so it doesnt disturb Appeared Cleeps
        let MAX_QUEUE = isDidAppear ? MAX_QUEUE_APPEAR : MAX_QUEUE_DISAPPEAR

        if(uniqueFeedToAppends.count > 0){
            uniqueFeedToAppends.forEach({ uniqueFeed  in
                print(LOG_ID, "uniqueFeedToAppends ",  KKVideoId().getId(feed: uniqueFeed), " - ",uniqueFeed.account?.username ?? "")
                
                var feed = uniqueFeed
                if FollowingUsers.shared.getUsers().contains(where: { $0["id"] as? String == feed.account?.id }) {
                    feed.account?.isFollow = true
                    feed.isFollow = true
                }
            })
            
            print(LOG_ID, "uniqueFeedToAppends......... ")
        }

        print("PE-10545 - populateFeedQueue", self.isRefresh, self.isFirstLoad, self.data.isEmpty, uniqueFeedToAppends.count, self.presenter.requestedPage, self.presenter.identifier.rawValue, UserDefaults.standard.string(forKey: "lastOpenedFeedCleepsView"))

        if self.isFirstLoad && self.data.isEmpty && self.uniqueFeedToAppends.isEmpty {
            self.isShowTiktokEmptyView = true
            self.mainView.collectionView.customReloadSections(IndexSet(integer: 1))
            print("PE-10545 - populateFeedQueue masuk empty")
        }
//        PE-10545 - uniq false true true 0 0 CLEEPS_INDO Optional("FEED")
//        PE-10545 - uniq false true true 0 0 FEED Optional("FEED")
//        PE-10545 - uniq false true true 8 1 FEED Optional("CLEEPS_INDO")
//        PE-10545 - uniq false true false 0 1 FEED Optional("CLEEPS_INDO")
//        PE-10545 - uniq false true true 10 1 CLEEPS_INDO Optional("CLEEPS_INDO")
//        PE-10545 - uniq false true false 0 1 CLEEPS_INDO Optional("CLEEPS_INDO")


        print(LOG_ID, "POPULATE, getNetworkFeed uniqueFeedToAppends", uniqueFeedToAppends.count)

        if(self.isRefresh){
            self.autoScrollToFirstIndex = true
            //print(LOG_ID, "POPULATE, REFRESH AFTER preloadAddAll uniqueFeedToAppends:", self.uniqueFeedToAppends.count)
            self.populateDataUnready()
            self.endRefresh()
            //print(LOG_ID, "POPULATE, REFRESH Add preloadAddAll, self.data.count:", self.data.count)
            self.preloadAddAll()
        } else {
            //self.processDataAfterNextPage()
            self.populateDataUnready()
            self.preloadAddAll()
        }
        
        uniqueFeedToAppends = []
    }
    
    @objc public func applicationDidBecomeActive() {
        if self.presenter.identifier.rawValue == UserDefaults.standard.string(forKey: "lastOpenedFeedCleepsView") {
            self.enterForegroundPlayVideo()
        }
    }
    
    func bindObserver(){
        if #available(iOS 13.0, *) {
            NotificationCenter.default.addObserver(self, selector: #selector(willResignActive), name: UIScene.willDeactivateNotification, object: nil)
        } else {
            NotificationCenter.default.addObserver(self, selector: #selector(willResignActive), name: UIApplication.willResignActiveNotification, object: nil)
        }

        NotificationCenter.default.addObserver(self, selector: #selector(handleReport(notification:)), name: handleReportFeed, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleDelete(notification:)), name: handleDeleteFeed, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(getMyLatestMyFeed), name: updateMyLatestFeed, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(clearFeedCleepsData), name: .clearFeedCleepsData, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(refreshDonation(notification:)), name: refreshForDonation, object: nil)
        
        presenter.networkStatus.bind { [weak self] (status) in
            guard self != nil else { return }
            print("PE10943", "Controller - Speed Test Status:", status, "isBuffering:", KKVideoManager.instance.player.isBuffering, "isBufferEnough:", KKVideoManager.instance.player.isBufferEnough)
            if KKVideoManager.instance.player.isBufferEnough {
                print("PE10943 - preload resuming", "Speed Test Status:", status, "isBuffering:", KKVideoManager.instance.player.isBuffering, "isBufferEnough:", KKVideoManager.instance.player.isBufferEnough)
                //KKTencentVideoPlayerPreload.instance.isPaused = false
                
            } else { // No Internet or on slow network
                print("PE10943 - preload pausing", "Speed Test Status:", status, "isBuffering:", KKVideoManager.instance.player.isBuffering, "isBufferEnough:", KKVideoManager.instance.player.isBufferEnough)
                //KKTencentVideoPlayerPreload.instance.isPaused = true
                
            }
        }.disposed(by: disposeBag)

        presenter.loadingState.bind { [weak self] isLoading in
            self?.isLoadingPaging = isLoading
        }.disposed(by: disposeBag)
        
        presenter.loadingEmptyContentState.bind { [weak self] isEmpty in
            guard let self = self else { return }
            
            if isEmpty {
                guard !self.presenter.isProfile && !self.displaySingle else { return }
                print(self.LOG_ID, "**** loadingEmptyContentState isEmpty YES, 1")
                
                if self.isTabFollowing && self.data.isEmpty && self.userSuggestItems.isEmpty {
                    self.presenter.requestFollowingSuggestion()
                    return
                }
                
                if self.dataUnready.count > 0 {
                    return
                }
                
                self.isShowTiktokEmptyView = true
                self.isShowLoadError = false
                
                if(self.isDidAppear){
                    if let cell = self.mainView.collectionView.visibleCells.first as? TiktokPostViewCell, let section = self.mainView.collectionView.indexPath(for: cell)?.section {
                        if !(section != 0) {
                            KKVideoManager.instance.player.pause()
                        }
                    }else {
                        KKVideoManager.instance.player.pause()
                    }
                }
                
                
                DispatchQueue.main.async {

                    if(self.data.count == 0){
                        self.endRefresh()
                        self.mainView.collectionView.customReloadSections(IndexSet(integer: 1))
                        self.autoScrollToFirstIndex = false
                        self.isFinishRefresh = true
                        self.mainView.loading.stopAnimating()

                    }
                }
            } else {
                self.isShowTiktokEmptyView = false
                self.isFinishRefresh = true
            }
        }.disposed(by: disposeBag)
        
        presenter.tokenExpired.bind { [weak self] isExpired in
            guard let self = self else { return }
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                if self.presenter.identifier == .donation || self.presenter.identifier == .cleeps(country: .indo) {
                    DispatchQueue.main.async {
                        self.mainView.loading.stopAnimating()
                    }
                    return
                }
                
                if isExpired {
                    self.data = []
                    self.mainView.changeCollectionViewBackgroundToLogin()
                    DispatchQueue.main.async {
                        self.mainView.loading.stopAnimating()
                    }
                    if self.presenter.isCleeps() {
                        self.data = []
                        self.mainView.changeCollectionViewBackgroundToLogin()
                    }
                }
            }
        }.disposed(by: disposeBag)
        
        presenter.userSuggestItems
            .asObservable()
//            .skip(1)
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] userSugest in
            guard let self = self else { return }
                
                if self.presenter.userSuggestPage != 0 {
                    self.userSuggestItems.append(contentsOf: userSugest)
                    DispatchQueue.main.async {
                        self.mainView.loading.stopAnimating()
                        self.mainView.bottomLoading.stopAnimating()
                        self.mainView.collectionView.visibleCells.forEach { cell in
                            if let cell = cell as? TiktokFollowingCleepsCell {
                                cell.users = self.userSuggestItems
                            }
                        }
                    }
                    return
                }
                
                self.userSuggestItems = userSugest
                self.isShowTiktokEmptyView = true
                self.isShowLoadError = false
                
                DispatchQueue.main.async {
                    self.endRefresh()
                    self.mainView.collectionView.customReloadSections(IndexSet(integer: 1))
                    
                    print("** scrollToItem", self.presenter.identifier.rawValue, "6")
                    self.autoScrollToFirstIndex = false
                    self.isFinishRefresh = true
                    self.mainView.loading.stopAnimating()
                    self.mainView.bottomLoading.stopAnimating()
                }
                
        }).disposed(by: disposeBag)
        
        
        if !self.displaySingle {
            presenter.feedsDataSource
                .asObservable()
//                .skip(1)
                .observeOn(MainScheduler.instance)
                .subscribe(onNext: { [weak self] dataNew in
                    guard let self = self else { return }
                    
                    if self.isTabFollowing && dataNew.isEmpty && self.userSuggestItems.isEmpty {
                        self.presenter.requestFollowingSuggestion()
                        return
                    }
                     
                    if self.uploadPostContent {
                        print(self.LOG_ID, "refresh observer A <<<==== problem")
                        self.updateFirstIndexFeed(feed: dataNew.first)
                        return
                    }
                    
                    self.endAllLoading()
                    
                    if self.isFeed {
                        self.populateFeedQueue(dataNew, self)
                    } else {
                        print("10245 - data baru", self.presenter.requestedPage, dataNew.count)
                        dataNew.forEach({ dataToAppend  in
                            var feed = dataToAppend
                            if FollowingUsers.shared.getUsers().contains(where: { $0["id"] as? String == dataToAppend.account?.id }) {
                                print("@@@@ user \(feed.account?.name ?? "") udah di follow, id = \(feed.account?.id ?? "")")
                                feed.account?.isFollow = true
                                feed.isFollow = true
                            }
                            
                            if !self.data.contains(where: { $0.id == feed.id} ){
                                self.updateCollectionViewDataSingle(with: feed)
                            }else {
                                print("10245 - data duplicated for id", feed.id, "onPage", self.presenter.requestedPage)
                            }
                        })
                    }

                    if !self.data.isEmpty {
                        self.isFirstOpenPage = false
                    }
                    
                    if self.isFirstReload {
                        self.isFirstReload = false
                    }
                    
                    if self.isRefresh {
                        print(self.LOG_ID, "refresh observer E")
                    }
                }).disposed(by: disposeBag)
        }
        
        presenter.openProfile
            .asObservable()
            .observeOn(MainScheduler.instance)
            .subscribe { [weak self] account in
                guard let id = account?.id, let userType = account?.accountType, let self = self  else { return }
                self.router?.onClickProfile(id: id, type: userType, nil)
            } onError: { [weak self] error in
                guard let self = self else { return }
                self.router?.onClickEmptyProfile()
            } onCompleted: {
            }.disposed(by: disposeBag)
        
            
        presenter.mentionAccount.asObservable().skip(1).observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] account in
                guard let self = self else { return }
                
                guard let accountId = account?.id, let accountType = account?.accountType else {
                    self.router?.onClickEmptyProfile()
                    return
                }
                
                self.router?.onClickProfile(id: accountId, type: accountType, nil)
            }).disposed(by: disposeBag)

    }

    private func isUniqueFeed(feed: Feed, acceptHasSeenOnceTime: Bool = false) -> Bool {
        
        if(!self.isFeed){
            return true
        }
        
        if(self.data.contains(where: { $0.id == feed.id })){
            print(self.LOG_ID, "PE-10545 - reject data from function isUniqueFeed", KKVideoId().getId(feed: feed), "because", "duplicate: self.data")
            return false
        }
        
        if(self.dataUnready.contains(where: { $0.id == feed.id })){
            print(self.LOG_ID, "PE-10545 - reject data from function isUniqueFeed", KKVideoId().getId(feed: feed) ,"because", "duplicate: self.dataUnready")
            return false
        }

        if(self.seenFeeds.contains(where: { $0.id == feed.id })){
            if acceptHasSeenOnceTime {
                let index = self.seenFeeds.firstIndex(where: { $0.id == feed.id }) ?? -1
                if index < 0 {
                    return false
                }
                
                if self.seenFeeds[index].seenCount < 2 {
                    print(self.LOG_ID, "10167 - accept feed has seen with feed", feed.post?.postDescription?.prefix(10), ", seen", self.seenFeeds[index].seenCount, "times")
                    return true
                }
            }
            
            // Force seen, maybe BE telat Coret
            // PE-11247
            self.setSeen(feed: feed)
            print(self.LOG_ID, "PE-10545 - reject data from function isUniqueFeed", KKVideoId().getId(feed: feed) ,"because", "duplicate: self.seenFeeds")

            return false
        }
        
        return true
    }
    
    private func endRefresh() {
        isRefresh = false
        isFinishRefresh = true

        print(LOG_ID, "refresh END")
        
        if refreshControl.isRefreshing {
            refreshControl.endRefreshing()
        }
        
        if mainView.topLoading.isAnimating {
            mainView.topLoading.stopAnimating()
        }
        
        if mainView.bottomLoading.isAnimating {
            mainView.bottomLoading.stopAnimating()
        }
        
        if !self.data.isEmpty && self.autoScrollToFirstIndex && self.isDidAppear {
            DispatchQueue.main.async {
                self.mainView.collectionView.reloadData()
                if self.INDEX_ROW_SHOWING != 0 {
                    self.mainView.collectionView.scrollToItem(at: IndexPath(item: 0, section: 0), at: .top, animated: false)
                }
            }
            print(self.LOG_ID, "AFTER APPEND ENDREFRESH")
            INDEX_ROW_SHOWING = 0
            autoScrollToFirstIndex = false
        }
    }

    private func endAllLoading() {
        if refreshControl.isRefreshing {
            refreshControl.endRefreshing()
        }
        
        if mainView.topLoading.isAnimating {
            mainView.topLoading.stopAnimating()
        }
        
        if mainView.bottomLoading.isAnimating {
            mainView.bottomLoading.stopAnimating()
        }

        if mainView.loading.isAnimating{
            mainView.loading.stopAnimating()
        }
    }

    @objc func getMyLatestMyFeed() {
        presenter.getMyLatestFeed()
        
        DispatchQueue.main.async {
            self.mainView.collectionView.reloadData()
            print(self.LOG_ID, "reloadData 3")
        }
    }
    
    @objc func clearFeedCleepsData() {
        refresh()
    }

    private func setCleepsNavigationbarTransparent(){
        navigationController?.navigationBar.backgroundColor = .clear
        
        let coloredAppearance = UINavigationBarAppearance()
        coloredAppearance.configureWithOpaqueBackground()
        coloredAppearance.backgroundColor = .clear
        coloredAppearance.titleTextAttributes = [.foregroundColor: UIColor.black]
        coloredAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.black]
        
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.standardAppearance = coloredAppearance
        navigationController?.navigationBar.scrollEdgeAppearance = coloredAppearance
        navigationController?.navigationBar.backgroundColor = .clear
    }
    
    func updateCollectionViewDataSingle(with feed: Feed, file: String = #file, function: String = #function, line: Int = #line, column: Int = #column){
        var index = self.data.count
        if index < 0 {
            mainView.collectionView.notifSentry("updateCollectionViewDataSingle for index \(index) with data count \(data.count)")
            index = 0
        }

        addFeed(feed, at: index)
    }
    
    @objc func handleReport(notification: NSNotification){
        if let id = indexFeedByIdFromNotification(notification) {
            data.removeAll(where: { $0.id == id })
            mainView.collectionView.reloadData()
            // removeFeedAt(index)
        }
    }
    
    @objc func handleDelete(notification: NSNotification){
        if let id = indexFeedByIdFromNotification(notification) {
           // removeFeedAt(index)
            data.removeAll(where: { $0.id == id })
            mainView.collectionView.reloadData()
            
            NotificationCenter.default.post(name: .init("exploreDeleteContent"), object: id)
            
            if isProfile {
                navigationController?.popToRootViewController(animated: true)
            } else {
                navigationController?.popViewController(animated: true)
            }
        }
    }
    
    private func indexFeedByIdFromNotification(_ notification: NSNotification) -> String? {
        if let dict = notification.userInfo as NSDictionary? {
            return dict["id"] as? String
        }
        return nil
    }
    
    private func addFeed(_ feed: Feed, at index: Int, onCompleted: (() -> Void?)? = nil){
        let indexPath = IndexPath(item: index, section: 0)
        
        if data.contains(where: { $0.id == feed.id }){
            print(self.LOG_ID, "PE-10494 - reject data because duplicate")
            print(self.LOG_ID, "PE-10545 - reject data from function", "addFeed", "because", "duplicate")
            return
        }
        
        print("PE-10494 - window not visible", self.mainView.collectionView.window == nil, "addFeed", indexPath, UserDefaults.standard.string(forKey: "lastOpenedFeedCleepsView"), self.presenter.identifier.rawValue)
        
        self.data.insert(feed, at: index)
        self.mainView.collectionView.safeInsertItems(at: [indexPath])
    }
    
    private func removeFeedAt(_ index: Int, onCompleted: (() -> Void?)? = nil){
        let indexPath = IndexPath(item: index, section: 0)
        data.remove(at: index)
        
        self.mainView.collectionView.safeDeleteItems(at: [indexPath]) { [weak self] _ in
            guard let self = self else { return }
            self.mainView.collectionView.customReloadItems(at: self.mainView.collectionView.indexPathsForVisibleItems)
            self.playVisibleCell(preferIndex:  indexPath)
            onCompleted?()
        }
    }
    
    private func showAuthPopUp(){
        pauseVisibleCell()
        router?.onShowAuthPopUp() { [weak self] in
            guard let self = self else { return }
            self.playVisibleCell()
        }
    }
    
    public func handleUpdateSelectedFeedLike(at indexPath: IndexPath, isLike: Bool, count: Int) {
        data[indexPath.item].likes = count
        data[indexPath.item].isLike = isLike
        DispatchQueue.main.async {
            self.mainView.collectionView.customReloadItems(at: [indexPath])
        }
    }
    
    public func handleUpdateSelectedFeedComment(at indexPath: IndexPath, count: Int) {
        data[indexPath.item].comments = count
        DispatchQueue.main.async {
            let cell = self.mainView.collectionView.cellForItem(at: indexPath) as? TiktokPostViewCell
            cell?.commentCounterLabel.text = count.countFormat()
        }
    }
    
    public func handleDeleteSelectedFeed(at indexPath: IndexPath) {
        data.remove(at: indexPath.item)
        DispatchQueue.main.async {
            self.mainView.collectionView.customReloadItems(at: [indexPath])
        }
    }
    
    private func enableNavigationBackGesture() {
        navigationController?.interactivePopGestureRecognizer?.delegate = self
    }
    
    public func showButtonClose() {
        let buttonClose = UIBarButtonItem(customView: self.mainView.buttonClose)
        navigationItem.rightBarButtonItem = buttonClose
        mainView.showCloseButton()
        mainView.onCloseButtonPressed = { [weak self] in
            self?.customDismissAnimation()
        }
        
        addSwipeUpGesture()
    }
    
    
    private func addSwipeUpGesture() {
        navigationController?.interactivePopGestureRecognizer?.delegate = nil
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false

        let gesture = UISwipeGestureRecognizer(target: self, action: #selector(swipeUpBackGesture(gesture:)))
        gesture.direction = .up
        gesture.delegate = self
        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(gesture)
    }
    
    
    private func setupCellBar(){
        if let cell = mainView.collectionView.visibleCells.first as? TiktokPostViewCell {
            cell.commentSectionView.isHidden = !showBottomCommentSectionView
            lastActiveCells.append(cell)
            var isPlaying = [Bool]()
            cell.getMediaCell { [weak self] cell in
                guard self != nil else { return }
                isPlaying.append(cell.isImage ? false : cell.isPlaying)
            }
            
            if isPlaying.contains(where: { $0 != true } ){
                cell.setupFeedbar()
                cell.feedbarController?.animate(to: 0)
            }
        }
    }
        
    @objc func enterForegroundPlayVideo(){
        self.isDidAppear = true
        resetFeedbar()
        refreshIfDataIsOld()
        playVisibleCell()
        setupCellBar()
    }

    public func pauseVisibleCell() {
        if let cell = mainView.collectionView.visibleCells.first as? TiktokPostViewCell {
            if !isFirstReload {
                KKVideoManager.instance.player.pause()
                cell.pause()
                cell.feedbarController?.stop()
            }
        }
    }
    
    func pauseCellForIndex(at index: Int) {
        let index: IndexPath = IndexPath(item: index, section: 0)
        if let cell = mainView.collectionView.cellForItem(at: index) as? TiktokPostViewCell {
            if !isFirstReload {
                cell.feedbarController?.stop()
            }
            cell.getMediaCell{ [weak self] mediaCell in
                guard self != nil else { return }
                mediaCell.pause()
            }
        }
    }
    
    private func isSameVideo(with cell: TiktokPostMediaViewCell) -> Bool {
        var cellUrl: Substring?
        var currentVideoPlayer: Substring?
        
        if KKVideoManager.instance.type == .versa {
            cellUrl = cell.getMediaNameMP4().split(separator: "/").last
            currentVideoPlayer = KKVideoManager.instance.player.currentVideoUrl.split(separator: "/").last
        }
        
        if KKVideoManager.instance.type == .tencent {
            cellUrl = KKTencentVideoPlayerHelper.instance.videoId(from: cell.getMediaNameMP4())
            currentVideoPlayer = KKTencentVideoPlayerHelper.instance.videoId(from: KKVideoManager.instance.player.currentVideoUrl)
        }
        
        var isSameVideo = cellUrl == currentVideoPlayer

        //        if KKVideoManager.instance.player.currentVideoUrl.split(separator: "/").last == nil && !KKVideoManager.instance.player.isPaused {
        if currentVideoPlayer == nil && !KKVideoManager.instance.player.isPaused {
            isSameVideo = true
        }
        
        return isSameVideo
    }
    
    public func playVisibleCell(preferIndex: IndexPath? = nil, function: String = #function, line : Int = #line){
                        
        if(!self.isDidAppear) { return }

        
        let isVisible = mainView.collectionView.window != nil
        let isOnTopView = UIApplication.shared.topMostViewController() == (self.topViewController ?? self)
        print("PE-10839 part 1", self.currentIndex, preferIndex?.item, function, line, !isVisible, !isOnTopView, !self.isDidAppear, self.isShowLoadError, self.isShowTiktokEmptyView, !isVisible || !isOnTopView || !self.isDidAppear || self.isShowLoadError || self.isShowTiktokEmptyView)

//        guard isVisible && isOnTopView && self.isDidAppear && !isShowLoadError && !isShowTiktokEmptyView && isVisible else {
//            KKVideoPlayer.instance.pause()
//            return
//        }
//        if !(isVisible && isOnTopView && self.isDidAppear && (!isShowLoadError || !isShowTiktokEmptyView)) {
        if !isVisible || !isOnTopView || !self.isDidAppear || self.isShowLoadError || self.isShowTiktokEmptyView {
//            KKVideoManager.instance.player.pause(file: "Controller", function: function, line: line)
            self.pauseVisibleCell()
        }

        if let cell = mainView.collectionView.visibleCells.first as? TiktokPostViewCell {
            var index: IndexPath? = nil
            if preferIndex != nil {
                for indexPath in mainView.collectionView.indexPathsForVisibleItems {
                    if indexPath == preferIndex {
                        index = indexPath
                        break
                    }
                }
            }
            
            print("PE-10839 part 2", self.currentIndex, preferIndex?.item, index?.item, function, line)
            
            var preferCell: TiktokPostViewCell = cell
            if let index = index {
                preferCell = (mainView.collectionView.cellForItem(at: index) as? TiktokPostViewCell) ?? cell
            }
            
            if preferCell != cell {
                print("10216 - harusnya gak ke play dan index selanjutnya bocor")
            }
            
            tryCountToAutoPlay = 0
            preferCell.getMediaCell{ [weak self] mediaCell in
                guard let self = self else { return }
                guard !mediaCell.isImage else { return }
                
                DispatchQueue.main.async {
                    mediaCell.prepareKKPlayer(withThumbnail: !self.isSameVideo(with: mediaCell))
                    KKVideoManager.instance.player.play(fromBegining: !self.isSameVideo(with: mediaCell), file: "Controller", function: function, line: line)
//                    self.addVideoPlayerTiktokObserver(preferCell)
                }
            }

            DispatchQueue.main.async {
                self.presenter.isCleeps() ? preferCell.stopTimer() : preferCell.startTimer()
            }
        } else {
            if tryCountToAutoPlay < 10 {
                tryCountToAutoPlay += 1
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1){
                    guard self.isDidAppear else { return }
                    self.playVisibleCell(preferIndex: preferIndex, function: function, line: line)
                }
            }
        }
    }
    
    func playVisibleFromBG() {
        if let cell = mainView.collectionView.visibleCells.first as? TiktokPostViewCell {
            cell.getMediaCell{ [weak self] mediaCell in
                guard let self = self else { return }
                self.lastActiveCells.append(cell)
            }
        } else {
            print("**** playVisibleFromBG \(presenter.identifier.rawValue) refresh()")
            refresh()
        }
    }
    
    func resetFeedbar(stopPlayer: Bool = false) {
        for (_, activeCell) in lastActiveCells.enumerated() {
            activeCell.resetFeedbar()
            if stopPlayer {
                activeCell.getMediaCell { [weak self] cell in
                    guard self != nil else { return }
                    cell.didEndDisplaying()
                }
            }
            activeCell.clean()
        }
        lastActiveCells = []
    }

    func getNetworkFeed(isTrending: Bool, force: Bool = false, function: String, line: Int = #line) {
        let requestedPage = presenter.requestedPage
        
        print("PE-10545 - getNetworkFeed", requestedPage, presenter.identifier, function, line)
        if(self.isLoadingPaging && !force){
            print(LOG_ID, "getNetworkFeed IGNORE, isLoadingPaging: TRUE", "requestedPage:", requestedPage, "isTrending:", isTrending, "self.presenter.requestedPage:", self.presenter.requestedPage)
            return
        }

        presenter.getNetworkFeed(getTrending: isTrending) { [weak self] in
            guard let self = self else { return }
            print(self.LOG_ID, "getNetworkFeed SUCCESS", requestedPage, "isTrending:", isTrending)
            DispatchQueue.main.async {
                self.isShowLoadError = false
                self.endRefresh()
                if self.presenter.identifier.rawValue == UserDefaults.standard.string(forKey: "lastOpenedFeedCleepsView") && KKVideoManager.instance.player.isPaused {
                    self.playVisibleCell(preferIndex: IndexPath(item: 0, section: 0))
                }
            }
            
        } isNetworkError: { [weak self] message in
            guard let self = self else { return }
            print(self.LOG_ID, "getNetworkFeed FAILED", requestedPage, "isTrending:", isTrending, "message:", message)
            DispatchQueue.main.async {
                if self.data.isEmpty {
                    self.handleLoadErrorSection()
                } else {
                    Toast.share.show(message: message)
                }
            }
        }
    }
    
    @objc public func refresh(force: Bool = false, function: String = #function){
        guard !isRefresh && isFinishRefresh else { return }
        guard ReachabilityNetwork.isConnectedToNetwork() else {
            DispatchQueue.main.async {
                self.clearAndShowCache()
                self.handleLoadErrorSection()
            }
            return
        }
        
        syncFeedSeenFailed()
        startRefresh(force: force,function: function)
    }
        
    @objc func refreshDonation(notification: NSNotification) {
        if let dict = notification.userInfo as NSDictionary? {
            if let location = dict["categoryId"] as? String {
               print("terserah \(location)")
            }
        }
    }

    private func startRefresh(force: Bool = false, function: String) {
        print(LOG_ID, "refresh START A <<====== ")
        
        KKTencentVideoPlayerPreload.instance.removeAllQueue(queueId: self.presenter.identifier.rawValue)
        
        isReset = true
        isShowLoadError = false
        isShowTiktokEmptyView = false
        isFinishRefresh = false
        isRefresh = true
        presenter.requestedPage = 0
        presenter.userSuggestPage = 0
        presenter.userSuggestTotalPage = 0
        presenter.totalPageLookup = 0
        userSuggestItems = []
        presenter.dataIsEmpty = false
        pauseVisibleCell()
        self.clearAndShowCache()

        if presenter.isCleeps() {
            getTrending = true
        }
        self.getNetworkFeed(isTrending: false, force: force, function: function)
    }

    private func clearAndShowCache() {
        data.removeAll()
        clearDataUnready()
        currentIndex = 0
        showLastReadyFeed(){
            UIView.performWithoutAnimation {
                self.mainView.collectionView.customReloadSections(IndexSet(integer: 0))
            }
            self.playVisibleCell()
        } whenSkip: {
            self.mainView.collectionView.reloadData()
        }
        presenter.lastPrepareIndex = 0
        INDEX_ROW_SHOWING = 0
    }

    func showLastReadyFeed(completion: (() -> Void)? = nil, whenSkip: (() -> Void)? = nil, file: String = #file, function: String = #function, line: Int = #line, column: Int = #column){
        if let lastFeed = self.presenter.getLastReadyFeed(){
            if(self.isUniqueFeed(feed: lastFeed, acceptHasSeenOnceTime: true)){
                print("10167 - showing last feed from cache", lastFeed.post?.postDescription?.prefix(10))
                print(LOG_ID, "Force-3", lastFeed.post?.medias?.first?.url ?? "")
                self.data.append(lastFeed)
                completion?()
                return
            }
        }
        whenSkip?()
    }
    
    private func clearDataUnready(){
        self.dataUnready.forEach { feed in
            print(self.LOG_ID, "clearDataUnready ", feed.post?.medias?.first?.url?.suffix(23) ?? "")
            //KKPreload.instance.removeUrlPreload(url: feed.post?.medias?.first?.url ?? "", code: self.presenter.identifier.rawValue)
        }
        
        self.dataUnready = []
    }
    
    private func handleLoadErrorSection() {
        self.isShowLoadError = true
        self.isShowTiktokEmptyView = false
        DispatchQueue.main.async {
            if self.mainView.collectionView.window == nil || self.presenter.identifier.rawValue != UserDefaults.standard.string(forKey: "lastOpenedFeedCleepsView"){
                print("PE-10890 - harusnya FC", self.mainView.collectionView.window == nil, self.presenter.identifier.rawValue, UserDefaults.standard.string(forKey: "lastOpenedFeedCleepsView"))
                self.mainView.collectionView.customReloadSections(IndexSet(integer: 3))
            } else {
                self.mainView.collectionView.reloadSections(IndexSet(integer: 3))
            }
            self.playVisibleCell()
            if self.data.isEmpty && self.presenter.identifier.rawValue == UserDefaults.standard.string(forKey: "lastOpenedFeedCleepsView") {
                self.tryCountToAutoPlay = 10
                KKVideoManager.instance.player.pause()
            }
            print(self.LOG_ID, "reloadData 4")
            print(self.LOG_ID,"handleLoadErrorSection")
            self.endRefresh()
        }
    }
    
    public func setupItems(feed: Feed) {
        isFirstReload = false
        print(LOG_ID, "Force-4", feed.post?.medias?.first?.url ?? "")
        data.append(feed)
    }

    public func showFromStartIndex(startIndex: Int) {
        print(LOG_ID, "showFromStartIndex", startIndex, "data.count:", self.data.count)
        mainView.collectionView.isHidden = true
        self.mainView.collectionView.reloadData()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.startItemFromIndex = startIndex
            let totalDataCount = self.data.count - 1
            let maxIndexToAdd = startIndex + 5
            let lastIndexToAdd = maxIndexToAdd > totalDataCount ? totalDataCount : maxIndexToAdd
            self.addQueueByRange(startIndex, lastIndexToAdd)
            self.mainView.collectionView.scrollToItem(at: IndexPath(item: startIndex, section: 0), at: .centeredHorizontally, animated: false)
            self.mainView.collectionView.isHidden = false
        }
    }
    
    func addQueueByRange(_ startIndex: Int, _ finishIndex: Int) {
        
        if(startIndex > finishIndex){
            print(LOG_ID, "Proc will addQueueByRange IGNORE 'startIndex > finishIndex' ", startIndex, "finish:", finishIndex)
            return
        }
        
        if(presenter.identifier.isLinearFromZero){
            self.queueCleeps(startIndex: startIndex, finishIndex: finishIndex)
        } else {
            self.queueProfileOther(startIndex: startIndex, finishIndex: finishIndex)
        }
    }
    
    func queueCleeps(startIndex:Int, finishIndex:Int){
        var finishIndex_ = 0
        finishIndex_ = startIndex + 5
        
        if(finishIndex_ >= self.dataUnready.count){
            finishIndex_ = self.dataUnready.count - 1
            print(LOG_ID, "queueCleeps IGNORE 'finishIndex >= self.dataUnready.count' ", finishIndex, ">", self.dataUnready.count)
        }
        
        print(LOG_ID, "queueCleeps start :", startIndex, "finishIndex_:", finishIndex_, "dataUnready.count",self.dataUnready.count)

        if(startIndex > finishIndex_){
            finishIndex_ = startIndex
        }
        
        let rangeToPreloaded: CountableClosedRange = startIndex...finishIndex_
        //TODO: ini
        self.dataUnready[rangeToPreloaded].forEach{ feed in
            presenter.prefetchImages([feed])
            
            if KKVideoManager.instance.type == .versa {
                if let mediaUrl = feed.post?.medias?.first?.url  {
                    if(mediaUrl != ""){
//                        print(LOG_ID, "addQueue- ", mediaUrl.suffix(18))
//                        KKPreload.instance.add Queue(urls: [mediaUrl], code: self.presenter.identifier.rawValue)
                    }
                }
            }
            
            if KKVideoManager.instance.type == .tencent {
                if let url = feed.post?.medias?.first?.vodUrl  {
                    if(url != ""){
                        //presenter.prefetchImages([feed])
                        //KKTencentVideoPlayerPreload.instance.add Queue(video: url, description: "\(feed.account?.username?.prefix(6) ?? "") - \(feed.post?.postDescription?.prefix(6) ?? "")")
                        return
                    }
                }

                if let url = feed.post?.medias?.first?.url  {
                    if(url != ""){
//                        KKTencentVideoPlayerPreload.instance.add Queue(video: url, description: "\(feed.account?.username?.prefix(6) ?? "") - \(feed.post?.postDescription?.prefix(6) ?? "")")
                    }
                }
            }
        }
    }
    
    func queueProfileOther(startIndex:Int, finishIndex:Int){
        
        if(self.data.count == 0){
            print(LOG_ID, "queueProfileOther Proc will addQueueByRange IGNORE, self.data.count EMPTY")
            return
        }
        
        if(finishIndex >= self.data.count){
            print(LOG_ID, "queueProfileOther Proc will addQueueByRange IGNORE 'finishIndex >= self.data.count' ", finishIndex, ">", self.data.count)
            return
        }
        
        print(LOG_ID, "queueProfileOther Proc will addQueueByRange start :", startIndex, "finish:", finishIndex)
        
        let finishIndexProfileOther = self.data.count - 1
        let rangeToPreloaded: CountableClosedRange = startIndex...finishIndexProfileOther
        if KKVideoManager.instance.type == .versa {
            self.data[rangeToPreloaded].forEach{ feed in
                if let mediaUrl = feed.post?.medias?.first?.url  {
                    if(mediaUrl != ""){
//                        print(LOG_ID, "queueProfileOther Add QueueByRange", mediaUrl.suffix(18))
//                        KKPreload.instance.add Queue(urls: [mediaUrl], code: self.presenter.identifier.rawValue)
                    }
                }
            }
        }

        if KKVideoManager.instance.type == .tencent {
            self.data[rangeToPreloaded].forEach{ feed in
                if let url = feed.post?.medias?.first?.vodUrl  {
                    if(url != ""){
//                        KKTencentVideoPlayerPreload.instance.add Queue(video: url, description: "\(feed.account?.username?.prefix(6) ?? "") - \(feed.post?.postDescription?.prefix(6) ?? "")")
//                        return
                    }
                }

                if let url = feed.post?.medias?.first?.url  {
                    if(url != ""){
//                        KKTencentVideoPlayerPreload.instance.add Queue(video: url, description: "\(feed.account?.username?.prefix(6) ?? "") - \(feed.post?.postDescription?.prefix(6) ?? "")")
                    }
                }
            }
        }
    }
    
    public func preloadEach(startIndex: Int){
        if(self.dataUnready.count > 0){
            var finishIndex = startIndex + 1
            if(finishIndex >= self.dataUnready.count) {
                finishIndex = self.dataUnready.count - 1
            }
                        
            //print(LOG_ID, "Proc Preload Each start=", startIndex, "finish=", finishIndex, "data.count", self.dataUnready.count)
            self.addQueueByRange(startIndex, finishIndex)
        }
    }

    
    public func preloadAddAll(){
        if(self.dataUnready.count > 0){
            let startIndex = 0
            var finishIndex = self.INDEX_ROW_SHOWING + 2
            
            if(!isDidAppear){
                finishIndex = 1
            }
            
            if(presenter.identifier.rawValue == "PROFILE_OTHER"){
                print(self.LOG_ID, "INDEX_ROW_SHOWING:", self.INDEX_ROW_SHOWING)
                let MAX_QUEUE = 3
                
                if(self.dataUnready.count > MAX_QUEUE){
                    finishIndex = MAX_QUEUE - 1
                } else {
                    finishIndex = self.dataUnready.count
                }
            }
                        
            //print(LOG_ID, "Proc Add preloadAddAll start=", startIndex, "finish=", finishIndex, "dataUnready.count", self.dataUnready.count)
            self.addQueueByRange(startIndex, finishIndex)
        }
    }

    private func isNeedShowOffline(totalData: Int) -> Bool {
        let MARGIN_SHOW_OFFLINE = 4
        let currentMargin = totalData - INDEX_ROW_SHOWING
        return currentMargin <= MARGIN_SHOW_OFFLINE
    }

    
    private func seenMinimumOfflineStock(totalData: Int, currentIndex: Int) -> Bool {
        let MARGIN_GET_NETWORK = 9
        let currentMargin = totalData - currentIndex
        return currentMargin <= MARGIN_GET_NETWORK
    }
    
    private func getNextPage(resetPage: Bool = false, isNetworkError: (() -> ())? = nil, file: String = #file, function: String = #function, line: Int = #line) {
        let MIN_DATA_UNREADY = 8

        if(self.dataUnready.count >= MIN_DATA_UNREADY){
            print("10167 - harusnya stuck", self.dataUnready.count, self.data.count)
            print(LOG_ID, "getNextPage IGNORE ", "self.dataUnready.count:",self.dataUnready.count, "still much" )
            self.dataUnready.forEach { feed in
                //print(LOG_ID, "residue dataUnready:", feed.post?.medias?.first?.url?.suffix(18) ?? "")
            }
            //print(LOG_ID, "residue dataUnready.....")

//            return
        }
        
        // minimum data available is set to 2 because the forceAppendDataUnready function is executed when the number of data remains 1 in the scrollViewDidEndDecelerating function. This is done so that there are no "concern" scrolling issues, except when the user is scrolling fast
        // Updated to 4, because data donation contains duplicate (get page 0 twice). This for fixing "concern" issues
        if self.dataUnready.count >= MIN_DATA_UNREADY || (self.data.count - self.currentIndex) > 4 {
            print("10167 - kena guard", self.dataUnready.count, self.data.count, self.currentIndex)
            return
        }
        
        print("10245 - page:", self.presenter.requestedPage, "of", self.presenter.totalPage, "in", self.presenter.identifier.rawValue, "sum data:", self.data.count, "currentIndex:", self.currentIndex, "sisa data:", self.data.count - self.currentIndex, "masuk ke if", resetPage, "from", file.split(separator: "/").last, function, line)

        print("PE-10545 - getNextPage", presenter.requestedPage, self.presenter.totalPage, self.data.count, self.currentIndex, file.split(separator: "/").last, function, line)
        //        if (resetPage)  {
        //            presenter.requestedPage = 0
        //            print(LOG_ID, "getNextPage TRY ", "page:",presenter.requestedPage, "resetPage")
        ////            getNetworkFeed(isTrending: true)
        ////            presenter.requestedPage = 0
        //            print(LOG_ID, "getNextPage MUTATE-ReqPage ", "page:",presenter.requestedPage)
        //        } else {
        //            print(LOG_ID, "getNextPage TRY ", "page:",presenter.requestedPage, "isTrending: false")
        //            if presenter.requestedPage < presenter.totalPage + 3{
        getNetworkFeed(isTrending: false, function: function, line: line)
        //            }
        //        }
    }
    
    func showAlert(title: String, message: String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        present(alert, animated: true, completion: nil)
    }

    func forceAppendDataUnready(file: String = #file, function: String = #function, line: Int = #line, column: Int = #column){
        if let firstDataUnready = self.dataUnready.first {
            
            self.setupDataToPreload()

            let url = firstDataUnready.post?.medias?.first?.url ?? ""
            print(self.LOG_ID, "forceAppendDataUnready", url.suffix(18))
            
            if let mediaUrl = firstDataUnready.post?.medias?.first?.url  {
                if(mediaUrl.lowercased().contains(".mp4")){
                }
            }
            
            self.presenter.addLastReadyFeed(feed: firstDataUnready, withTrendingFilter: true)
            self.dataUnready.removeFirst()
            
            if(self.data.contains(where: { $0.id == firstDataUnready.id })){
                self.forceAppendDataUnready(file: file, function: function, line: line, column: column)
            } else {
                self.updateCollectionViewDataSingle(with: firstDataUnready)
            }
        } else {
            print(self.LOG_ID, "forceAppendDataUnready failed, dataUnready Not Enough :", self.dataUnready.count)
        }
    }
    
    func setupDataToPreload(isAppend: Bool = false){
        //TODO
        if(self.isDidAppear) {
            var mp4Urls:[String] = []
            var feeds:[Feed] = []

            //let start = self.currentIndex
            let start = 0
            let end = self.dataUnready.count
            let MAX_QUEUE = 3
            //print(self.LOG_ID, "setupDataToPreload", start, "~" ,end )

            //let startDataTable = self.currentIndex + 1
            let startDataTable = self.currentIndex
            let endDataTable = self.data.count

            print(self.LOG_ID, "startDataTable === ", startDataTable)
            if(endDataTable > startDataTable) {
                for i in startDataTable..<endDataTable {
                    let feed = self.data[i]
                    //let url = feed.post?.medias?.first?.url ?? ""
                    var url = ""
                    if KKVideoManager.instance.type == .tencent {
                        url = feed.post?.medias?.first?.playURL ?? ""
                    }
                    if KKVideoManager.instance.type == .versa {
                        url = feed.post?.medias?.first?.url ?? ""
                    }

                    feeds.append(feed)
                    //if(url.contains(".mp4")) {
                    if(url.lowercased().contains(".mp4") || url.lowercased().contains(".m3u8")) {
                        if(mp4Urls.count <= MAX_QUEUE){
                            mp4Urls.append(url)
                        }

                        //print(self.LOG_ID, "player-preload init table: ", KKVideoId().getId(urlString: url) )
                    }
                }

            }
            
            if(end > start) {
                for i in start..<end {
                    let feed = self.dataUnready[i]
                    //let url = feed.post?.medias?.first?.url ?? ""
                    
                    var url = ""
                    if KKVideoManager.instance.type == .tencent {
                        url = feed.post?.medias?.first?.playURL ?? ""
                    }
                    if KKVideoManager.instance.type == .versa {
                        url = feed.post?.medias?.first?.url ?? ""
                    }

                    feeds.append(feed)
                    if(url.lowercased().contains(".mp4") || url.lowercased().contains(".m3u8")) {
                        if(mp4Urls.count <= MAX_QUEUE){
                            mp4Urls.append(url)
                        }

                        //mp4Urls.append(url)
                        //print(self.LOG_ID, "player-preload init unready: ", KKVideoId().getId(urlString: url) )
                    }
                }
                
                //print(self.LOG_ID, "setupDataToPreload", start, "~" ,end )
                //KKPreload.instance.setup(urls: mp4Urls, country: self.presenter.identifier.rawValue)

                presenter.prefetchImages(feeds)
                
                if(startDataTable == 0 && mp4Urls.count > 0){
                    mp4Urls.remove(at: 0)
                    
                    if(mp4Urls.count > 0){
                        //mp4Urls.remove(at: 0) // remove "top" twice
                    }
                    
                }
                
                if KKVideoManager.instance.type == .tencent {
                    //print("KKTencentPreloadOperation startDataTable", startDataTable)
//                    KKTencentVideoPlayerPreload.instance.addQueue(videos: mp4Urls, queueId: self.presenter.identifier.rawValue)
                }
                
                if KKVideoManager.instance.type == .versa {
                    KKPreload.instance.setup(urls: mp4Urls, country: self.presenter.identifier.rawValue)
                }
                
            }
        }
    }

    func refreshIfDataIsOld(){
        let lastOpenTimeStampString = Double(DataCache.instance.readString(forKey: KEY_LAST_OPEN_CLEEP) ?? "0") ?? 0.0
        let currentTimeStamp = Date().timeIntervalSince1970
        let deviationLastOpen = currentTimeStamp - lastOpenTimeStampString
        var EXPIRED_TIME = 30 * 60
//        EXPIRED_TIME = 5
        print(self.LOG_ID, "**** refreshIfDataIsOld lastOpenTimeStampString: \(lastOpenTimeStampString), deviationLastOpen:", deviationLastOpen, "s", "OLD_DAYS:\(EXPIRED_TIME)")
        
        if(Int(deviationLastOpen) > EXPIRED_TIME){
            print("**** refreshIfDataIsOld \(presenter.identifier.rawValue) refresh()")
            refresh()
            presenter.requestedPage = 0
            print(LOG_ID, "getNextPage refreshIfDataIsOld MUTATE-ReqPage ",presenter.requestedPage)
        }
    }
    
    func setSeen(feed: Feed) {
        if let id = feed.id, ((feed.id?.isEmpty) != nil) {
            let hlsUrl = feed.post?.medias?.first?.hlsUrl
            
//            if(hlsUrl != nil){
//                KKVideoManager.shared.remove(url: hlsUrl!)
//            }
            
            if(id != ""){
                KKFeedOffline.instance.remove(id: presenter.identifier.rawValue, feedId: FeedId(id: id))
            }

            saveSeenToCache(feed: feed)
            FeedSeenFailedCache.instance.add(id: presenter.identifier.rawValue, feedId: FeedId(id: id))
            
            print(self.LOG_ID, "---seen",feed.account?.username ?? ""  )
            
            presenter.updateFeedAlreadySeen(feedId: id) { [weak self] success in
                guard let self = self else { return }
                if success {
                    FeedSeenFailedCache.instance.remove(id: self.presenter.identifier.rawValue, feedId: FeedId(id: id))
                } else {
                    FeedSeenFailedCache.instance.add(id: self.presenter.identifier.rawValue, feedId: FeedId(id: id))
                }
            }
        }
    }
    
    func saveSeenToCache(feed: Feed) {
        var feedId = FeedId(id: feed.id)

        let isTrending = feed.trendingAt != nil
        let hashtagTrending = ["viral", "trending", "hottopic"]
        var containHashtag = false

        for hashtag in (feed.post?.hashtags ?? []) {
            if hashtagTrending.contains(where: { $0 == hashtag.value}) {
                containHashtag = true
                break
            }
        }

        let includedCriteria = isTrending || containHashtag
        if !includedCriteria {
            feedId.seenCount = 2
        }

        if seenFeeds.contains(where: { $0.id == feedId.id }){
            if feedId.seenCount < 2 {
                feedId.seenCount+=1

                let index = self.seenFeeds.firstIndex(where: { $0.id == feed.id }) ?? -1
                if index >= 0 {
                    self.seenFeeds[index] = feedId
                }

                FeedSeenCache.instance.saveSeenFeed(feedId: feedId, forKey: presenter.identifier.rawValue)
            }
        } else {
            seenFeeds.append(feedId)
            FeedSeenCache.instance.saveSeenFeed(feedId: feedId, forKey: presenter.identifier.rawValue)
        }
    }
    
//    func addVideoPlayerTiktokObserver(_  cell: TiktokPostViewCell) {
//        cell.videoTiktokPlaying = { [weak self] in
//            guard let self = self else { return }
//            print("PE-10839 observer", self.mainView.collectionView.indexPathsForVisibleItems)
//            if self.mainView.collectionView.indexPathsForVisibleItems.first?.section != 0 || self.isShowLoadError || self.isShowTiktokEmptyView {
//                KKVideoManager.instance.player.pause()
//            }
////            let isVisible = self.mainView.collectionView.window != nil
////            let isOnTopView = UIApplication.shared.topMostViewController() == (self.topViewController ?? self)
////            print("PE-10839 observer", self.currentIndex, !isVisible, !isOnTopView, !self.isDidAppear, self.isShowLoadError, self.isShowTiktokEmptyView, !isVisible || !isOnTopView || !self.isDidAppear || self.isShowLoadError || self.isShowTiktokEmptyView)
////
////            if !isVisible || !isOnTopView || !self.isDidAppear || self.isShowLoadError || self.isShowTiktokEmptyView {
////                KKVideoManager.instance.player.pause()
////            }
//        }
//    }
}

extension FeedCleepsViewController {
    
    func calculate(comment value: Int) {
        presenter.updateFeedComment(comments: value, index: presenter.selectedCommentIndex)
        mainView.collectionView.performBatchUpdates { [weak self] in
            guard let self = self else { return }
            UIView.performWithoutAnimation {
                guard let _ = self.mainView.collectionView.cellForItem(at: IndexPath(item: presenter.selectedCommentIndex, section: 0)) as? TiktokPostViewCell else {return}
            }
        }
    }
    
    func calculateLike(like value: Int) {
        presenter.updateFeedLike(likes: value, index: presenter.selectedCommentIndex)
        mainView.collectionView.performBatchUpdates { [weak self] in
            guard let self = self else { return }
            UIView.performWithoutAnimation { [weak self] in
                guard let self = self else { return }
                guard let _ = self.mainView.collectionView.cellForItem(at: IndexPath(item: presenter.selectedCommentIndex, section: 0)) as? TiktokPostViewCell else {return}
            }
        }
    }
}

extension FeedCleepsViewController: UIGestureRecognizerDelegate {
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

//extension FeedCleepsViewController: KKFloatingActionButtonDelegate {
//    func floatingActionButton(_ floatingActionButton: KKFloatingActionButton, didSelectItemAtIndex index: Int) {
//        floatingActionButton.close()
//        var string = ""
//
//        if index == 0 {
//            string = "https://www.detik.com/"
//        } else if index == 1 {
//            string = "https://www.cnnindonesia.com/"
//        } else if index == 2 {
//            string = "https://www.kompas.com/"
//        }
//
//        let browserController = FeedCleepOpenBrowserController(url: string)
//        browserController.bindNavigationBar("", false, icon: .get(.iconClose))
//
//        let navigate = UINavigationController(rootViewController: browserController)
//        navigate.modalPresentationStyle = .fullScreen
//
//        self.present(navigate, animated: false)
//    }
//}

//extension FeedCleepsViewController: KKFloatingActionButtonDataSource {
//    func numberOfCells(_ floatingActionButton: KKFloatingActionButton) -> Int {
//        return 3
//    }
//
//    func cellForIndex(_ index: Int) -> KKFloatingActionButtonCell {
//        guard let cell = mainView.collectionView.visibleCells.first as? TiktokPostViewCell else {
//            return KKFloatingActionButtonCell()
//        }
//        return cell.cellShortCutExternal[index]
//    }
//}
