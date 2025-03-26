//
//  HotRoomViewController.swift
//  FeedCleeps
//
//  Created by Administer on 2024/7/2.
//

import UIKit
import KipasKipasShared
import TUIPlayerShortVideo

public class HotRoomViewController: UIViewController, NavigationAppearance {
    private var pauseByCall: Bool = false
    override public func didReceiveMemoryWarning() {
        print("***** HotRoomViewController, didReceiveMemoryWarning")
        KKLogFile.instance.log(label:"HotRoomViewController \(feedType)", message: "didReceiveMemoryWarning", level: .error)
        
    }
    
    let LOG_ID = "** HotNewsController"
    
    //MARK: View
    private var viewType: HotNewsViewType = .loading {
        didSet { updateView() }
    }
    private var showView = UIView()
    lazy var mainView: IHotView = {
        let view = HotRoomView()
        view.tuiView.delegate = view
        view.delegate = self
        view.eventDelegate = self
        return view
    }()
    
    private lazy var followingView: FollowingView = {
        let view = FollowingView()
        view.delegate = self
        return view
    }()
    
    private lazy var errorView: HotNewsErrorView = {
        let view = HotNewsErrorView()
        view.delegate = self
        return view
    }()
    
    private lazy var loadingView: HotNewsLoadingView = {
        let view = HotNewsLoadingView()
        return view
    }()
    
    private lazy var donationEmptyView: DonationEmptyView = {
        let view = DonationEmptyView()
        view.delegate = self
        return view
    }()
    
    var interactor: IHotNewsInteractor!
    public var router: IHotNewsRouter!
    
    private let feedType: FeedType
    private var feeds: [FeedItem] = [] {
        didSet {
            feeds.forEach { it in
                print("feURL didSetFeeds \(it.videoUrl)")
            }
            handleGetFeedForStories?(feeds)
        }
    }
    
    public var handleGetFeedForStories: (([FeedItem]) -> Void)?
    
    private var isRefresh: Bool = false {
        didSet {
            mainView.kkRefreshControl.endRefreshing()
        }
    }
    
    private let handleReportFeed = Notification.Name(rawValue: "com.kipaskipas.reportFeed")
    private let handleDeleteFeed = Notification.Name(rawValue: "com.kipaskipas.deleteFeed")
    
    private var loadDataScheduler: Timer?
    private var isLoadingData: Bool = false
    private var loadDataTryCount: Int = 0
    
    private let format = DateFormatter()
    public var handleUpdateLikes: ((FeedItem?) -> Void)?
    public var handleLoadMyCurrency: (() -> Void)?
    public var handleUpdateFeeds: (([FeedItem]) -> Void)?
    
    //let MAX_TRY_COUNT = 60
    let MAX_TRY_COUNT = 6
    let MIN_DATA_SHOW = 5
    
    var lastResolution = ""
    
    var followingHasData = false
    
    let reachability =  Reachability()
    
    public init(feedType: FeedType) {
        self.feedType = feedType
        super.init(nibName: nil, bundle: nil)
    }
    public var isFromPushFeed = false
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        setViewIfNeeded(mainView)
        view.backgroundColor = .black
        navigationController?.interactivePopGestureRecognizer?.delegate = self
        
//        let cacheCount = KKFeedCache.instance.initCache()
//        print("\(LOG_ID) \(feedType) cacheCount: \(cacheCount)")
//        KKLogFile.instance.log(label:"HotRoomViewController \(feedType)", message: "cacheCount: \(cacheCount)")
        
        format.dateFormat = "HH:mm:ss.SSS"

        if(isFromPushFeed){
            mainView.setupTUIView(cell: FeedType.profile.controllCell, feedType: .profile)
        }else{
            mainView.setupTUIView(cell: feedType.controllCell, feedType: feedType)
        }
        configTUI(speedInKb: 10_000)
        
        isRefresh = true
        if isFromPushFeed {
            interactor.requestFeed(by: interactor.selectedFeedId)
        }else{
            interactor.requestFeeds(reset: true)
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(destroyObserver), name: .destroyObserver, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(enterBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleDelete(notification:)), name: handleDeleteFeed, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(shouldRefreshData), name: .clearFeedCleepsData, object: nil)
        
        // handle when notification center is show
        NotificationCenter.default.addObserver(self, selector: #selector(resigningActive), name: UIApplication.willResignActiveNotification, object: nil)
        
        // handle when notification center is un-show
        NotificationCenter.default.addObserver(self, selector: #selector(becomeActive), name: UIApplication.didBecomeActiveNotification,object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(internetChanged), name: Notification.Name.reachabilityChanged , object: reachability)
        startReachability()
        bindCallObserver()
    }
    
    private func startReachability() {
        do {
            try reachability?.startNotifier()
        } catch {
            print("Could not start notifier")
        }
    }
    
    @objc fileprivate func resigningActive() {
        pause()
    }
    
    @objc fileprivate func becomeActive() {
        if mainView.isAppear && isOnTopController() {
            resume()
        }
    }
    
    @objc func internetChanged(note:Notification) {
        if let reachability = note.object as? Reachability {
            if reachability.connection != .none {
                if(mainView.tuiView.videos.count == 0){
                    pullToRefresh()
                }
            }
        }
    }
    
    
    @objc func destroyObserver() {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func enterBackground(){
        //print("*** refreshIfDataIsOld. enterBackground...")
        pause()
        setLastAppear()
    }
    
    @objc public func applicationDidBecomeActive() {
        refreshIfDataIsOld()
    }
    
    @objc private func shouldResumePlayer() {
        mainView.disablePlay = false
        if mainView.tuiView.isPlaying { return }
        if isRefresh { return }
        let status = mainView.tuiView.currentPlayerStatus
        if status == .prepared || status == .paused {
            if isTheShowController() {
                resume()
            }
        }
    }
    
    @objc private func shouldPausePlayer() {
        mainView.disablePlay = true
        if !mainView.tuiView.isPlaying { return }
        pause()
    }
    
    public func updateDonationCampaign() {
        guard !interactor.isForSingleFeed else { return }
        interactor.requestFeed(by: interactor.selectedFeedId)
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(shouldResumePlayer), name: .shouldResumePlayer, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(shouldPausePlayer), name: .shouldPausePlayer, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleReport(notification:)), name: handleReportFeed, object: nil)
        
        overrideUserInterfaceStyle = .dark
        mainView.isAppear = true
        navigationController?.setNavigationBarHidden(false, animated: false)
        setupNavigationBar(color: .clear, isTransparent: true)
        configureTabBar()
        handleLoadMyCurrency?()
        shouldResumePlayer()
        disablePlayWhenOnCall()
        let status = mainView.tuiView.currentPlayerStatus
        if status == .prepared || status == .paused {
            print("showPlayingType true")
            showPlayingType(force: true)
        }
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        mainView.setupRefreshControl()
        mainView.isAppear = true
//        if !isRefresh { // reload item from back/pop event
//            interactor.requestFeed(by: interactor.selectedFeedId)
//        }
        resume()
        resumePreload()
         
         
        if let had = UserDefaults.standard.object(forKey: "hadPushHotRoom"), had as! Bool == true {
            pullToRefresh()
            UserDefaults.standard.set(false, forKey: "hadPushHotRoom")
        }
        
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        mainView.isAppear = false
        //print(feedType, "\(LOG_ID) viewWillDisappear, mainView.isAppear:", mainView.isAppear)
    }
    
    public override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        /// Commenting this code below, because it introduces a bug.
        /// Please refer to PE-13653 on Jira
        // NotificationCenter.default.removeObserver(self)
        mainView.isAppear = false
        pause()
        
        // stopTimer()
        //print(feedType, "\(LOG_ID) viewDidDisappear, mainView.isAppear:", mainView.isAppear)
        handleUpdateFeeds?(feeds)
        pausePreload()
        if isFromPushFeed {
//            NotificationCenter.default.post(name: .clearFeedCleepsData, object: nil, userInfo: [:])
            UserDefaults.standard.set(true, forKey: "hadPushHotRoom")
        }
    }
    
    public required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        // stopTimer()
    }
    
    private func configureTabBar() {
        tabBarController?.tabBar.isHidden = false
    }
    
    private func showNetworkErrorDialog(title: String = "", onRetry: (() -> Void)? = nil, onCancel: (() -> Void)? = nil) {
        showToast(with: "Network Error \(title)", backgroundColor: .redError, textColor: .white)
    }
    
    private func showDataEmptyDialog(onOK: (() -> Void)? = nil, onRetry: (() -> Void)? = nil, title: String = "") {
        
        var titleDialog = title == "" ? "Data Sudah Habis" : title
        
        let alert = UIAlertController(title: titleDialog, message: "", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Retry", style: .default , handler:{ [weak self] (UIAlertAction) in
            guard self != nil else { return }
            onRetry?()
        }))
        
        alert.addAction(UIAlertAction(title: "OK", style: .default , handler:{ [weak self] (UIAlertAction) in
            guard self != nil else { return }
            onOK?()
        }))
        
        self.present(alert, animated: true)
    }
    
    @objc private func shouldRefreshData() {
//        feeds.removeAll()
//        mainView.tuiView.removeAllVideoModels()
//        viewType = .loading
//        //        self.interactor.page = 0
//        self.interactor.requestFeeds(reset: true)
        pullToRefresh()
    }
    
    @objc func handleDelete(notification: NSNotification){
        if let index = indexFeedByIdFromNotification(notification) {
            feeds.remove(at: index)
        }
    }
    
    @objc func handleReport(notification: NSNotification){
        if let index = indexFeedByIdFromNotification(notification) {
            // ngeremove index 0 sampai index yang di report
            feeds.removeSubrange(0...index)
            setShortVideoModels(feeds)

            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                let tuiCountVideos = self.mainView.tuiView.videos.count
                if tuiCountVideos > 0 {
                    self.mainView.tuiView.didScrollToCell(with: 0, animated: false)
                    self.resume()
                }
            }
        }
    }
    
    private func cell(at index: Int) -> TUIShortVideoItemView? {
        return mainView.tuiView.tuiCellForItem(at: index)
    }
    
    private func indexFeedByIdFromNotification(_ notification: NSNotification) -> Int? {
        if let dict = notification.userInfo as NSDictionary? {
            if let id = dict["id"] as? String{
                var idx: Int?
                for feed in feeds {
                    if feed.id == id {
                        idx = feeds.firstIndex(of: feed)
                        break
                    }
                }
                return idx
            }
        }
        return nil
    }
    
    @objc func handleWhenClickCommentOnHotNews(_ notification: Notification) {
        
        let feed = notification.object as? FeedItem
        router.presentComment(feed: feed)
    }
    
    @objc func handleWhenClickShareOnHotNews(_ notification: Notification) {
        
        let feed = notification.object as? FeedItem
        router.presentShare(feed: feed)
    }
    
    @objc func handleWhenClickProfileOnHotNews(_ notification: Notification) {
        
        let feed = notification.object as? FeedItem
        router.presentProfile(feed: feed)
    }
    
    public func requestUpdateIsFollow(accountId: String, isFollow: Bool) {
        interactor.updateFollow(by: accountId)
        var hasFound = false
        feeds.enumerated().forEach { index, element in
            if element.account?.id == accountId {
                element.account?.isFollow = isFollow
                hasFound = true
            }
        }
        if hasFound {
            let data: [String : Any] = ["accountId" : accountId, "isFollow": isFollow]
            NotificationCenter.default.post(name: .updateIsFollowFromFolowingFolower, object: nil, userInfo: data)
        }
    }
    
    public func updateIsFollow(accountId: String, isFollow: Bool) {
        var hasFound = false
        feeds.enumerated().forEach { index, element in
            if element.account?.id == accountId {
                element.account?.isFollow = isFollow
//                mainView.feeds[index].account?.isFollow = isFollow
                hasFound = true
            }
        }
        if hasFound {
            let data: [String : Any] = ["accountId" : accountId, "isFollow": isFollow]
            NotificationCenter.default.post(name: .updateIsFollowFromFolowingFolower, object: nil, userInfo: data)
        }
    }
    
    private func goResumeVideo() {
        if !feeds.isEmpty && isTheShowController() {
            mainView.tuiView.resume()
        }
    }
    
    public func resume() {
        
        if !mainView.tuiView.isPlaying {
            print("***** resume NOT Playing", feedType, "status:",mainView.tuiView.currentPlayerStatus.rawValue)
            switch mainView.tuiView.currentPlayerStatus {
            case .ended: // kasus donasi [PE-11965], tidak playing, isPlaying = false, status = ended (5)
                print("***** resume NOT Playing - ended", feedType)
            case .error:
                print("***** resume NOT Playing - error", feedType)
            case .loading:
                print("***** resume NOT Playing - loading", feedType)
            case .paused:
                print("***** resume NOT Playing - paused", feedType)
                //                    mainView.tuiView.resume()
                self.goResumeVideo()
            case .playing: // kasus gk ngeplay [PE-12132], isPlaying = false, status = playing
                print("***** resume NOT Playing - playing", feedType)
                self.goResumeVideo()
                
            case .prepared:
                self.goResumeVideo()
                print("***** resume NOT Playing - prepared", feedType)
            case .unload:
                print("***** resume NOT Playing - unload", feedType)
                self.goResumeVideo()
            default: break
            }
        } else {
            print("***** resume isPlaying", feedType)
        }
    }
    
    public func pause() {
        mainView.tuiView.pause()
    }
    
    public func pausePreload() {
        mainView.tuiView.pausePreload()
    }
    
    public func resumePreload() {
        mainView.tuiView.resumePreload()
    }
    
    public func pauseIfNeeded() {
        if mainView.tuiView.isPlaying {
            pause()
        }
    }
    
    public func resumeIfNeeded() {
        if !mainView.tuiView.isPlaying {
            self.resume()
        }
    }
    
    public func refreshDonation(categoryId: String) {
        interactor.categoryId = categoryId
        pullToRefresh()
    }
    
    public func disablePlayWhenOnCall() {
        if FeedCallStateManager.shared.state == .notOnCall {
            mainView.disablePlay = false
            pauseByCall = false
//            pause()
//            resume()
        } else {
            mainView.disablePlay = true
            pauseByCall = true
            pause()
        }
    }
}

extension HotRoomViewController: HotNewsDelegate {
    func getMediaType() -> FeedMediaType? {
        interactor.mediaType
    }
    
    func getFeeds() -> [FeedItem] {
        feeds
    }
    
    func showPlayingType() {
        print("showPlayingType")
        showPlayingType(force: true)
    }
    
    
    private func isTheShowController() -> Bool {
        if let window = UIApplication.shared.windows.first(where: { $0.isKeyWindow }) {
            let relativeFrame = view.convert(view.bounds, to: window)
            let leadingPoint = relativeFrame.origin.x
            let trailingPoint = relativeFrame.origin.x + relativeFrame.size.width
            let screenTrailingPoint = view.bounds.width
            let isOnLeft = leadingPoint >= 0 && leadingPoint < screenTrailingPoint
            let isOnRight = trailingPoint > 0 && trailingPoint <= screenTrailingPoint
            let address = Unmanaged.passUnretained(self).toOpaque()
            print("pointpoint le \(address) = \(leadingPoint), tr = \(trailingPoint), isL = \(isOnLeft), isR = \(isOnRight), type = \(feedType), isInView = \(view.superview != nil), isPass = \((isOnLeft || isOnRight) && view.superview != nil)")
            if (isOnLeft || isOnRight) && view.superview != nil {
                return true
            }
        }
        return false
    }
    
    func showPlayingType(force: Bool = false) {
        let isTop = isTheShowController()
        print("isTop = \(isTop) type = \(feedType)")
        guard isTop else {
            pause()
            return
        }
        if !force {
            let status = mainView.tuiView.currentPlayerStatus
            print("statusstatus = \(status)")
            if status != .prepared { return }
        }
        if feeds.isEmpty { return }
        print("showPlayingType video")
        viewType = .video
//        isRefresh = false
//        DispatchQueue.main.async {
//            self.pause()
//            self.resume()
//        }
    }
    
    func showAlert(text: String) {
        showToast(with: "\(text)", backgroundColor: .redError, textColor: .white)
    }
    
    func isOnTopController() -> Bool {
        return topMostViewController() == self
    }
    
    func configTUI(speedInKb: Int) {
        let model = TUIPlayerVodStrategyModel()
        model.isLastPrePlay = true
        model.mRenderMode = .RENDER_MODE_FILL_SCREEN
        model.enableAutoBitrate = false
        //        model.mIsPreVideoResume = true
        model.mResumeModel = .RESUM_MODEL_NONE
        //model.mIsPreVideoResume = false
        
        let SPEED_MAX_MEDIUM = 8_000
        let SPEED_MAX_LOW = 3_000
        
        //        let SPEED_MAX_MEDIUM = 5_000
        //        let SPEED_MAX_LOW = 1_000
        
        //        let SPEED_MAX_MEDIUM = 1_500
        //        let SPEED_MAX_LOW = 500
        
        //middle
        var preloadCount = 3
        var bufferInMB = 0.5
        var resolution = 720 * 1280
        
        var resolutionLevel = "MED"
        
        if(speedInKb > SPEED_MAX_MEDIUM){
            // high
            resolutionLevel = "HIGH"
            //preloadCount = 5
            //bufferInMB = 0.8
            bufferInMB = 0.5
            resolution = 1080 * 1920
        }
        else if(speedInKb < SPEED_MAX_LOW){
            // low
            resolutionLevel = "LOW"
            //            preloadCount = 2
            //            resolution = 480 * 852
        }
        
        if lastResolution == "" {
            lastResolution = resolutionLevel
        } else {
            if lastResolution == resolutionLevel {
                print(self.LOG_ID, "configTUI", "NO Change, still \(resolutionLevel), Speed: \(speedInKb)")
                KKLogFile.instance.log(label:"configTUI", message: "NO Change, still \(resolutionLevel), Speed: \(speedInKb)")
                
                return
            }
        }
        
        self.lastResolution = resolutionLevel
        
        print(self.LOG_ID, "**preload configTUI \(feedType)", "Change to \(resolutionLevel), Speed: \(speedInKb)")
        KKLogFile.instance.log(label:"configTUI", message: "Change to \(resolutionLevel), Speed: \(speedInKb)")
        
        model.mPreloadConcurrentCount = preloadCount
        model.mPreloadBufferSizeInMB = Float(bufferInMB)
        model.mPreferredResolution = resolution
        
        mainView.tuiView.setShortVideoStrategyModel(model)
    }
    
    func scrolled(to index: Int, with item: FeedItem) {
        NotificationCenter.default.post(name: NSNotification.Name("handleHiddenShortcutSosmed"), object: nil)
        interactor.selectedFeedId = item.id ?? ""
        
//        if !interactor.isForSingleFeed {
//            interactor.requestFeed(by: item.id ?? "")
//        }
        
//        saveCache(current: index) // Ketika scrolling
        disablePlayWhenOnCall()
    }
    
    func handleSeenBy(id: String, accountId: String) {
        setLastAppear()
        if !interactor.isLogin {
            interactor.guestSeenFeed(id: id)
            return
        }
        interactor.seenFeed(id: id, accountId: accountId)
    }
    
    
    public func pullToRefresh() {
        guard !interactor.isForSingleFeed else {
            mainView.kkRefreshControl.endRefreshing()
            return
        }
        guard !isRefresh else { return }
        self.isRefresh = true
        isLoadingData = false
        refreshing()
    }
    
    
    func refreshing() {
        guard !isLoadingData else { return }
        
        isLoadingData = true
        viewType = .loading
        
        if(isRefresh){
            feeds.removeAll()
            removeAllVideoModels()
            self.interactor.requestFeeds(reset: true)
            
        }
    }
    
    func handleOnLicenceLoaded(_ result: Int32, reason: String) {
        guard result == 0 else { return }
        DispatchQueue.main.async {
            self.feeds.removeAll()
            self.removeAllVideoModels()
        }
    }
    
    func handleRetry() {
        isLoadingData = true
        //interactor.page += 1
        interactor.requestFeeds()
    }
    
    func handleLoadMore() {
        guard !isLoadingData else {
            return
        }
        isLoadingData = true
        if isFromPushFeed {
            interactor.requestPushFeeds(reset: false)
        }else{
            interactor.requestFeeds()
        }
    }
    
    public func requestDonationByProvince(id: String?) {
        interactor.provinceId = id ?? ""
        interactor.latitude = 0.0
        interactor.longitude = 0.0
        pullToRefresh()
    }
    
    public func requestDonationBylocation(latitude: Double?, longitude: Double?) {
        interactor.latitude = latitude ?? 0.0
        interactor.longitude = longitude ?? 0.0
        interactor.provinceId = ""
        pullToRefresh()
    }
    
    public func requestDonationAll() {
        interactor.latitude = 0.0
        interactor.longitude = 0.0
        interactor.provinceId = ""
        pullToRefresh()
    }
}

extension HotRoomViewController: IHotNewsViewController {
    public func expandStoryListView() {
        
    }
    
    public func collapseStoryListView() {
        
    }
    
    public func setRouter(router: IHotNewsRouter) {
        self.router = router
    }
    public var viewsFeeds: [FeedItem] {
        feeds
    }
    
    public func displayErrorSingleFeed(with message: String) {
        loadingView.stopLoading()
        if interactor.isForSingleFeed {
            if isFromPushFeed {
                let item = FeedItem()
                item.feedType = .deletePush
                feeds.append(contentsOf: [item])
                setShortVideoModels(feeds)
                
                interactor.alreadyLoadFeeds = [item]
                interactor.requestPushFeeds(reset: true)
                
            }else{
                viewType = .notFound(message: "Data tidak tersedia")
            }
        }
    }
    //    MARK: -  update single
    public func displayUpdateSingleFeed(with item: FeedItem) {
        guard !interactor.isForSingleFeed else {
            handleLoadMyCurrency?()
            isLoadingData = false
            feeds = [item]
            setShortVideoModels(feeds)
            if isFromPushFeed {
                interactor.alreadyLoadFeeds = feeds
                interactor.requestPushFeeds(reset: true)
            }
            firstStartPlay()
            return
        }
        guard let index = feeds.getIndex(byId: item.id) else { return }
        if feeds[index].comments != item.comments {
            feeds[index].comments = item.comments
            NotificationCenter.default.post(name: .handleUpdateFeedHotNewsCell, object: item)
        }
        
        if feeds[index].likes != item.likes {
            feeds[index].likes = item.likes
            NotificationCenter.default.post(name: .handleUpdateFeedHotNewsCell, object: item)
        }
        
        if feeds[index].post?.amountCollected != item.post?.amountCollected {
            NotificationCenter.default.post(name: .handleUpdateFeedHotNewsCell, object: item)
        }
    }
    
    
    public func firstStartPlay(){
        DispatchQueue.main.async {
            let tuiCountVideos = self.mainView.tuiView.videos.count
            if tuiCountVideos > 0 {
                KKLogFile.instance.log(label:"HotRoomViewController \(self.feedType)", message: "didScrollToCell default")
                self.mainView.tuiView.didScrollToCell(with: 0, animated: false)
                self.resume()
                self.resumePreload()
            }
        }
    }
    
    public func displayFeedTrendingCache(with item: FeedItem) {
        print("***preload CACHE \(LOG_ID) \(feedType) ")
        let uniqueItems = [item]
        print("PE-12388 append trending cache?", !uniqueItems.isEmpty)
        feeds.append(contentsOf: uniqueItems)
//        mainView.feeds.append(contentsOf: feeds)
        mainView.tuiView.appendShortVideoModels(feeds)

        DispatchQueue.main.async {
            self.resumePreload()
            self.updateEmptyState(items: uniqueItems)
        }
    }
    
    public func displayUpdateFollowAccount(id: String) {
    }
    
    public func displayMentionUserByUsername(id: String?, type: String?) {
        DispatchQueue.main.async { KKDefaultLoading.shared.hide()
        }
        router.presentMention(id: id, type: type)
    }
    
    public func displayErrorUpdateLike(with message: String) {
        print(message)
    }
    
    public func displayUpdateLike() {
        
    }
    
    public func displayErrorGetFeeds(with message: String) {
        print("*** \(feedType) - displayErrorGetFeeds ", message, "interactor.page:",interactor.page)
        
        isLoadingData = false
        
        followingHasData = false
        
        
        //else {
        var title = message
        print("*** showNetworkErrorDialog - C", message)
        if(message.lowercased().description.contains("token")){
            title = "(ERR:TOKEN)"
        } else if(message.description.contains("405")){
            title = "(ERR:405)"
        } else if(message.description.contains("9999") || message.description.contains("500") || message.lowercased().description.contains("time out")){
            title = "Network Error"
        } else if(message.description.contains("4864")){
            title = "(ERR:PARSE)"
        } else if(message.description.lowercased().contains("unknown")) {
            title = "Network Error"
            if message.description.lowercased().contains("network") {
                title += "_"
            }
        }
        
        //specific error on PIK2
        if(message.lowercased().description.contains("No space left on device")){
            title = "(ERR:NOSPCE)"
        } else if(message.lowercased().description.contains("hostname could not be found")){
            title = "(ERR:NOHOST)"
        }
        
        if interactor.page == 0 {
            print("xxxxxx \(feedType) isRefresh5 = false")
            isRefresh = false
            
            viewType = .error(message: title)
            
        } else {
            if mainView.tuiView.currentVideoIndex >= (feeds.count - MIN_DATA_SHOW) {
                showNetworkErrorDialog(title: title)
            }
        }
        
        
        print("\(feedType) - displayErrorGetFeeds \(message)")
    }
    
    private func displayDonation() {
        if interactor.page == 0 {
            print("*** showNetworkErrorDialog - A")
            showNetworkErrorDialog(onRetry: handleLoadMore) { [weak self] in
                guard let self = self else { return }
                self.interactor.latitude = 0.0
                self.interactor.longitude = 0.0
                self.interactor.provinceId = ""
                self.interactor.categoryId = ""
                self.pullToRefresh()
            }
            return
        }
        
        if loadDataTryCount >= self.MAX_TRY_COUNT {
            showDataEmptyDialog(onRetry:  { [weak self] in
                guard let self = self else { return }
                
                self.interactor.latitude = 0.0
                self.interactor.longitude = 0.0
                self.interactor.provinceId = ""
                self.interactor.categoryId = ""
                self.pullToRefresh()
            }, title: "Data Donasi tidak tersedia")
        }
    }
    
    fileprivate func handleDonationEmpty() {
        if interactor.page == 0 {
            print("*** showNetworkErrorDialog - B")
            
            viewType = .error(message: "Data Donasi tidak tersedia")
            self.interactor.latitude = 0.0
            self.interactor.longitude = 0.0
            self.interactor.provinceId = ""
            self.interactor.categoryId = ""
            return
        }
        
        if loadDataTryCount >= self.MAX_TRY_COUNT {
            showDataEmptyDialog(onRetry:  { [weak self] in
                guard let self = self else { return }
                
                self.interactor.latitude = 0.0
                self.interactor.longitude = 0.0
                self.interactor.provinceId = ""
                self.interactor.categoryId = ""
                self.pullToRefresh()
            }, title: "Data Donasi tidak tersedia")
        }
    }
    
    /*
     items = Full item API, or "unique items" if .hotnews
     totalItems = total Full item from API, to determine if item empty is "from API" or after "filter unique"
     */
    fileprivate func refreshEmpty(_ items: [FeedItem], _ totalItems: Int, _ isLogin: Bool) {
        if(items.isEmpty){
            if(totalItems == 0){
                // No Data from API
                if(isLogin){
                    viewType = .error(message: "Data tidak tersedia")
                } else {
                    viewType = .error(message: "Data tidak tersedia, silahkan Login")
                    router.presentPublicEmptyPopup()
                }
            } else {
                // Data from API is available, but not unique
                if(isLogin){
                    viewType = .error(message: "Rekomendasi data tidak tersedia")
                } else {
                    viewType = .error(message: "Rekomendasi data tidak tersedia, silahkan Login")
                    router.presentPublicEmptyPopup()
                }
            }
        }
    }
    
    fileprivate func nextPageEmpty(_ items: [FeedItem], _ totalItems: Int, _ isLogin: Bool) {
        if(items.isEmpty){
            if(totalItems == 0){
                // No Data from API
                if isLogin {
                    viewType = .error(message: "Data tidak tersedia")
                } else {
                    viewType = .error(message: "Data tidak tersedia, silahkan Login")
                    router.presentPublicEmptyPopup()
                }
            } else {
                // Data from API is available, but not unique
                if isLogin {
                    viewType = .error(message: "Rekomendasi data tidak tersedia")
                } else {
                    viewType = .error(message: "Rekomendasi data tidak tersedia, silahkan Login")
                    router.presentPublicEmptyPopup()
                }
            }
        }
    }
    
    fileprivate func exceedMaxTryCount(_ items: [FeedItem], _ totalItems: Int, _ isLogin: Bool) {
        var labelEmpty = ""
        if(items.isEmpty){
            if(totalItems == 0){
                // No Data from API
                labelEmpty = "Data tidak tersedia"
            } else {
                // Data from API is available, but not unique
                labelEmpty = "Rekomendasi data tidak tersedia"
            }
            
            if(isLogin){
                showDataEmptyDialog(
                    onOK: {
                        self.loadDataTryCount = 1
                    }, onRetry: { [weak self] in
                        guard let self = self else { return }
                        self.handleRetry()
                    }, title: labelEmpty)
            } else {
                router.presentPublicEmptyPopup()
                DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
                    self.pullToRefresh()
                }
            }
        }
    }
    //    MARK: -   feeds list
    public func displayFeeds(with items: [FeedItem], totalItems:Int = 0, isLogin: Bool) {
        print(" *** uniqueFeed displayFeedss itemcount = \(items.count), totalItems = \(totalItems)")
        KKLogFile.instance.log(label:"displayFeeds \(feedType)", message: "items: \(items.count)   from: \(totalItems)")
        
        if(!mainView.isValidTUILicense()){
            DispatchQueue.main.async{ [weak self] in
                guard let self = self else { return }
                print("***** displayFeeds \(self.feedType) NOT Valid TUI")
                // TUI License not loaded, mainly because Network problem
                self.pullToRefresh()
            }
        }
        handleLoadMyCurrency?()
        isLoadingData = false
        
        
        for i in 0..<items.count {
            
            items[i].post?.floatingLink = nil
            items[i].post?.floatingLinkLabel = nil
            items[i].post?.siteName = nil
            items[i].post?.siteLogo = nil
            
            if i % 4 == 0 {
                items[i].post?.floatingLink = "https://youtu.be/tD68_o1GMg0?si=9xHJkTz1meFvCy51"
                items[i].post?.floatingLinkLabel = "Youtube"
                items[i].post?.siteName = "Youtube"
                items[i].post?.siteLogo = "https://koanba-storage-prod.oss-cn-hongkong.aliyuncs.com/assets_public/mobile/ios/floating_link/youtube.png"
            }
        }
        
        let uniqueItems = items
        print(" *** uniqueFeed displayFeeds \(self.feedType) items: ", items.count, "  uniqueItems: ", uniqueItems.count, "feeds: ", feeds.count)
        print(" *** uniqueFeed -------- isRefresh = \(isRefresh)")
        
        if isRefresh {
            if isFromPushFeed {
                self.appendPushMoreData(items: items)
                isRefresh = false
            } else {
                feeds.removeAll()
                print("*** uniqueFeed refresh 1", feedType)
                feeds.append(contentsOf: uniqueItems)
                setShortVideoModels(feeds)
                self.firstStartPlay()
            if(!mainView.isAppear){
                pausePreload()
            }
            if items.isEmpty {
                refreshEmpty(uniqueItems, totalItems, isLogin)
            }
            print("xxxxxx \(feedType) isRefresh7 = false")
            isRefresh = false
          }
        } else {
            if isFromPushFeed {
                self.appendPushMoreData(items: items)
            }else{
                if uniqueItems.isEmpty {
                    
                    if interactor.page == 0 {
                        nextPageEmpty(items, totalItems, isLogin)
                        return
                    }
                    if loadDataTryCount >= self.MAX_TRY_COUNT || totalItems == 0{
                        exceedMaxTryCount(items, totalItems, isLogin)
                    } else {
                        if(totalItems > 0){
                            loadDataTryCount += 1
                            handleLoadMore()
                        }
                    }
                    return
                } else {
                    loadDataTryCount = 0
                    feeds.append(contentsOf: uniqueItems)
                    mainView.tuiView.appendShortVideoModels(uniqueItems)
                }
            }
        }
        DispatchQueue.main.async {
            self.updateEmptyState(items: items)
        }
    }
    
    func appendPushMoreData(items:[FeedItem]){
        if items.count == 0 {
            self.showTipsMsg("No more data",position: .center)
            return
        }
        let pushItem = feeds.first
        let newItems = items.filter{$0.id != pushItem?.id}
        
        feeds.append(contentsOf: newItems)
        mainView.tuiView.appendShortVideoModels(newItems)
    }
    
    func refreshIfDataIsOld(){
        guard !interactor.isForSingleFeed else { return }
        var EXPIRED_TIME = 30 * 60
//        EXPIRED_TIME = 5
        let lastOpenTimeStampString = Double(DataCache.instance.readString(forKey: "KEY_LAST_OPEN_HOTNEWS") ?? "0") ?? 0.0
        let currentTimeStamp = Date().timeIntervalSince1970
        let deviationLastOpen = Int(currentTimeStamp - lastOpenTimeStampString)
        
        print("**** refreshIfDataIsOld.. check deviationLastOpen: ", deviationLastOpen, feedType)
        
        //guard deviationLastOpen > EXPIRED_TIME, !feeds.isEmpty else {
        guard deviationLastOpen > EXPIRED_TIME else {
            print("**** refreshIfDataIsOld.. ignore refresh")
            return
        }
        
        print("**** refreshIfDataIsOld.. start refreshing", feedType)
        
        //Data
//        feeds.removeAll()

        //        interactor.page = 0
//        shouldRefreshData()
        pullToRefresh()
    }
    
    func setLastAppear() {
        let currentTimeStamp = Date().timeIntervalSince1970
        let currentTimeStampString = String(format: "%f", currentTimeStamp)
        DataCache.instance.write(string: currentTimeStampString, forKey: "KEY_LAST_OPEN_HOTNEWS")
    }
    
    public func displayFollowingSuggest(with items: [RemoteFollowingSuggestItem]) {
        print("xxxxxx \(feedType) isRefresh8 = false")
        isRefresh = false
        isLoadingData = false
        viewType = .following(data: items)
        followingHasData = true
    }
}

// MARK: - Helper
private extension HotRoomViewController {
    func updateEmptyState(items: [FeedItem]) {
        let sequence: [FeedType] = [.donation, .feed, .following, .hotNews]
        guard sequence.contains(where: {$0 == feedType}) else { return }
        
        if mainView.tuiView.videos.count == 0 {
            print("PE-12552 showing empty feedType:", feedType)
                viewType = .error(message: "Data tidak tersedia")
        } else {
            print("PE-12552 hiding empty")
            if let item = mainView.tuiView.currentVideoModel as? FeedItem {
                let it = feeds.first(where: { i in
                    i.id == item.id
                })
                if let theItem = it {
//                    print("abc type = \(item.feedMediaType)")
                    if theItem.post?.medias?.first?.type == "image" {
                        print("showPlayingType video2")
                        self.viewType = .video
                    }
                }
            }
        }
    }
    
    private func removeAllVideoModels() {
        mainView.tuiView.removeAllVideoModels()
    }
    
    private func setShortVideoModels(_ list: [TUIPlayerDataModel]) {
        mainView.tuiView.setShortVideoModels(list)
        viewType = .loading
    }
    
    func reSetVideos() {
        let currIdx = mainView.tuiView.currentVideoIndex //keep the current index
        let items = mainView.tuiView.videos as? [FeedItem] ?? feeds
        guard items[safe: currIdx]?.post?.medias?.first?.type == "video" else { return }
        
        removeAllVideoModels()
        setShortVideoModels(items)
        scrollWithRetry(to: currIdx) // auto scroll to current index
    }
    
    func scrollWithRetry(to index: Int) {
        guard mainView.tuiView.currentVideoIndex != index else { return } // validate if current index = target index
        
        guard mainView.tuiView.videos.count > index else {
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.scrollWithRetry(to: index)
            }
            return
        }
        
        mainView.tuiView.didScrollToCell(with: index, animated: false)

        DispatchQueue.main.async { [weak self] in // delay for check target index from first code in this func
            guard let self = self else { return }
            self.scrollWithRetry(to: index)
        }
    }
}

// MARK: Call Handler for Play/Pause
private extension HotRoomViewController {
    func bindCallObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(callStateChagned), name: .init("callStateChanged"), object: nil)
    }
    
    @objc func callStateChagned(_ notif: Notification) {
        let state = (notif.userInfo!["state"] as? Int) ?? -1
        stopCall(state == 0 ? true : false)
        if state == 0 {
            mainView.disablePlay = false
            if pauseByCall {
                pauseByCall = false
                if UIApplication.shared.applicationState == .active {
                    resume()
                }
            }
        } else {
            mainView.disablePlay = true
            if mainView.tuiView.isPlaying {
                pauseByCall = true
                pause()
            }
        }
    }
    
    
    private func stopCall(_ stop: Bool) {
        if stop == true {
            do {
                try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .moviePlayback)
            }
        } else {
            do {
                try? AVAudioSession.sharedInstance().setCategory(.playAndRecord, mode: .videoChat)
            }
        }
    }
}

// MARK: - View Handler
private extension HotRoomViewController {
    
    private func setViewIfNeeded(_ newView: UIView) {
        if newView != showView {
            if newView == loadingView {
                newView.frame = mainView.tuiView.bounds
            } else {
                newView.frame = view.bounds
            }
            view.addSubview(newView)
            showView.removeFromSuperview()
            if showView == mainView {
                pause()
            }
            showView = newView
        }
    }
    
    private func cleanAllVideoData() {
        pause()
        mainView.tuiView.removeAllVideoModels()
        feeds.removeAll()
    }
    
    
    private func updateView() {
        errorView.button.isHidden = false
        print("showPlayingType video type = \(viewType)")
        switch viewType {
        case .video:
            setViewIfNeeded(mainView)
        case let .following(data):
            setViewIfNeeded(followingView)
            followingView.configure(with: data)
        case let .error(message):
            if(feeds.isEmpty){
                cleanAllVideoData()
                setViewIfNeeded(errorView)
                errorView.message = message
            }
        case .loading:
            setViewIfNeeded(loadingView)
        case let .notFound(message):
            cleanAllVideoData()
            setViewIfNeeded(errorView)
            errorView.message = message
            errorView.button.isHidden = true
        case let .donationEmpty(isFilterActive):
            donationEmptyView.isFilterActive = isFilterActive
            setViewIfNeeded(donationEmptyView)
        }
    }
}


extension HotRoomViewController: HotNewsViewEventDelegate {
    
    func profile(feed: FeedItem?) {
        guard feed?.feedType == feedType else { return }
        
        guard feedType == .feed else {
            router.presentProfile(feed: feed)
            return
        }
        
        if feed?.videoUrl.hasSuffix(".mp4") == true || feed?.videoUrl.hasSuffix(".m3u8") == true {
            guard interactor.mediaType == .video else { return }
            router.presentProfile(feed: feed)
        } else {
            guard interactor.mediaType == .image else { return }
            router.presentProfile(feed: feed)
        }
    }
    
    func like(feed: FeedItem?) {
        guard feed?.feedType == feedType else { return }
        guard interactor.isLogin else {
            router.presentLoginPopUp(onDismiss: nil)
            return
        }
        handleUpdateLikes?(feed)
        interactor.updateLike(id: feed?.id ?? "", isLike: feed?.isLike ?? false)
    }
    
    func share(feed: FeedItem?) {
        guard feed?.feedType == feedType else { return }
        router.presentShare(feed: feed)
    }
    
    func follow(feed: FeedItem?) {
        guard feed?.feedType == feedType else { return }
        guard interactor.isLogin else {
            router.presentLoginPopUp(onDismiss: nil)
            return
        }
        
        requestUpdateIsFollow(accountId: feed?.account?.id ?? "", isFollow: feed?.account?.isFollow ?? false)
    }
    
    func comment(feed: FeedItem?) {
        guard feed?.feedType == feedType else { return }
        router.presentComment(feed: feed)
    }
    
    func productDetail(feed: FeedItem?) {
        guard feed?.feedType == feedType else { return }
        router.presentProductDetail(feed: feed)
    }
    
    func donationDetail(feed: FeedItem?) {
        guard feed?.feedType == feedType else { return }
        router.presentDonationNow(feed: feed)
    }
    
    func shortcutStartPaidDM(feed: FeedItem?) {
        guard feed?.feedType == feedType else { return }
        router.presentShortcutStartPaidDM(feed: feed)
    }
    
    func hashtag(feed: FeedItem?, value: String) {
        guard feed?.feedType == feedType else { return }
        router.presentHashtag(feed: feed, value: value)
    }
    
    func donationFilterCategory(feed: FeedItem?) {
        guard feed?.feedType == feedType else { return }
        router.presentDonationFilterCategory(id: interactor.categoryId)
    }
    
    func mention(feed: FeedItem?, value: String) {
        guard feed?.feedType == feedType else { return }
        DispatchQueue.main.async {
            KKDefaultLoading.shared.show()
        }
        interactor.requestMentionUser(by: value)
    }
    
    func playPause(feed: FeedItem?, isPlay: Bool) {
        guard feed?.feedType == feedType else { return }
        isPlay == true ? resumeIfNeeded() : pauseIfNeeded()
    }
    
    func newsPortal(feed: FeedItem?, url: String) {
        guard feed?.feedType == feedType else { return }
        pause()
        router.presentNewsPortal(url: url)
    }
    
    func shortcutLiveStreaming(feed: FeedItem?) {
        router.gotoLiveStreamingList()
    }
    
    func floatingLink(feed: FeedItem?) {
        guard feed?.feedType == feedType else { return }
        guard let url = feed?.post?.floatingLink else { return }
        router.presentFloatingLink(url: url)
    }
    
    func contentSetting(feed: FeedItem?) {
        guard feed?.feedType == feedType else { return }
        router.presentContentSetting(feed: feed)
    }
    
    func bookmark(feed: FeedItem?) {
        guard feed?.feedType == feedType else { return }
        router.presentBookmark(feed: feed)
    }
    
    func donationCart(feed: FeedItem?) {
        guard feed?.feedType == feedType else { return }
        router.presentDonationCart(feed: feed)
    }
    
    func donateStuff(feed: FeedItem?) {
        guard feed?.feedType == feedType else { return }
        router.presentDonateStuff(feed: feed)
    }
}

// MARK: - Following View Delegate
extension HotRoomViewController: FollowingViewDelegate {
    func didRefresh() {
        pullToRefresh()
    }
    
    func didFollow(account id: String) {
        requestUpdateIsFollow(accountId: id, isFollow: true)
    }
    
    func didOpenProfile(for account: RemoteUserProfileData) {
        router.presentProfile(feed: FeedItem(account: account.feedAccount()))
    }
    
    func didOpenFeed(for id: String) {
        router.presentSingleFeed(feedId: id)
    }
}

// MARK: - Error View Delegate
extension HotRoomViewController: HotNewsErrorViewDelegate {
    func didTapButton() {
        if errorView.message.lowercased().contains("login") {
            router.presentPublicEmptyPopup()
            return
        }
        
        pullToRefresh()
    }
}

extension HotRoomViewController: DonationEmptyViewDelegate {
    func didChangeFilter() {
        router.presentDonationFilterCategory(id: interactor.categoryId)
    }
}

extension HotRoomViewController: UIGestureRecognizerDelegate {}

fileprivate extension RemoteUserProfileData {
    func feedAccount() -> FeedAccount {
        return FeedAccount(
            id: id,
            username: username,
            isVerified: isVerified,
            name: name,
            photo: photo,
            accountType: accountType,
            urlBadge: urlBadge,
            isShowBadge: isShowBadge,
            isFollow: isFollow,
            chatPrice: chatPrice
        )
    }
}
