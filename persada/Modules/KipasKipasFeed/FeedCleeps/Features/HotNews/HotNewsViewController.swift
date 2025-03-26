//
//  HotNewsViewController.swift
//  KipasKipasFeed
//
//  Created by DENAZMI on 04/10/23.
//

import UIKit
import TUIPlayerCore
import TUIPlayerShortVideo
import KipasKipasShared
import AVFoundation
import KipasKipasStory
import KipasKipasStoryiOS


enum HotNewsViewType {
    case video
    case following(data: [RemoteFollowingSuggestItem])
    case error(message: String)
    case loading
    case notFound(message: String)
    case donationEmpty(isFilterActive: Bool)
}

public class HotNewsViewController: UIViewController, NavigationAppearance {
    private var pauseByCall: Bool = false
    override public func didReceiveMemoryWarning() {
        print("***** HotNewsViewController, didReceiveMemoryWarning")
        KKLogFile.instance.log(label:"HotNewsViewController \(feedType)", message: "didReceiveMemoryWarning", level: .error)

    }
    
    let LOG_ID = "** HotNewsController"
    
    //MARK: View
    private var viewType: HotNewsViewType = .loading {
        didSet { updateView() }
    }
    private var showView = UIView()
    lazy var mainView: IHotNewsView = {
        let view = HotNewsView()
        view.tuiView.delegate = view
        view.delegate = self
        view.eventDelegate = self
        view.storyView.delegate = self
        view.storyView.listView.delegate = self
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
    
//    private var loadingView: HotNewsLoadingView = HotNewsLoadingView()
    
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
            handleGetFeedForStories?(feeds)
        }
    }
    private var storyData: StoryData?
    private var otherStories: [StoryFeed] = []
    
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
    
    public var isFromPushFeed = false

    //let MAX_TRY_COUNT = 60
    let MAX_TRY_COUNT = 6
    let MIN_DATA_SHOW = 5

    var lastResolution = ""

    var followingHasData = false
    
    let reachability = Reachability()
    
    public init(feedType: FeedType) {
        self.feedType = feedType
        super.init(nibName: nil, bundle: nil)
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        if feedType == .feed , interactor.mediaType == .image {
            loadingView =  HotNewsLoadingView(isBlackTitle: true)
        }else{
            loadingView   = HotNewsLoadingView()
        }
        
        setViewIfNeeded(mainView)
        view.backgroundColor = .black
        navigationController?.interactivePopGestureRecognizer?.delegate = self
        
        let cacheCount = KKFeedCache.instance.initCache()
        print("\(LOG_ID) \(feedType) cacheCount: \(cacheCount)")
        KKLogFile.instance.log(label:"HotNewsViewController \(feedType)", message: "cacheCount: \(cacheCount)")
        
        format.dateFormat = "HH:mm:ss.SSS" 
        if(isFromPushFeed){
            mainView.setupTUIView(cell: FeedType.profile.controllCell, feedType: .profile)
        }else{
            mainView.setupTUIView(cell: feedType.controllCell, feedType: feedType)
        }
       
        //mainView.setResolution(isFast: true)
        configTUI(speedInKb: 10_000)
        
        if feedType == .profile {
            print("xxxxxx \(feedType) isRefresh1 = true")
            isRefresh = true
            
            if interactor.isForSingleFeed {
                interactor.requestFeed(by: interactor.selectedFeedId)
            } else {
                interactor.requestFeeds(reset: interactor.alreadyLoadFeeds.isEmpty)
            }
        } else if feedType == .following {
            print("xxxxxx \(feedType) isRefresh2 = true")
            isRefresh = true
            interactor.requestFollowing()
            interactor.requestStories(reset: true)
            loadCache()
        } else {
            print("xxxxxx \(feedType) isRefresh3 = true")
            isRefresh = true
            interactor.requestFeeds(reset: true)
            loadCache()
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
        bindStoryObserver()

        //print(feedType, "\(LOG_ID) viewDidLoad, mainView.isAppear:", mainView.isAppear)
         
        
        
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
        if(mainView.isAppear) {
            resume()
        }
    }

    @objc func internetChanged(note:Notification)  {
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
        if mainView.tuiView.isPlaying { return }
        if isRefresh { return }
        let status = mainView.tuiView.currentPlayerStatus
        if status == .prepared || status == .paused {
            if isTheShowController() {
                self.resume()
            }
        }
    }
    
    @objc private func shouldPausePlayer() {
        mainView.disablePlay = true
        if mainView.tuiView.isPlaying {
            pause()
        }
    }
    
    public func updateDonationCampaign() {
        guard !interactor.isForSingleFeed else { return }
        interactor.requestFeed(by: interactor.selectedFeedId)
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        /// Commenting this code below, because it introduces a bug.
        /// Moved back as in the first palce to `viewDidLoad`
        /// Please refer to PE-13653 on Jira
        // NotificationCenter.default.addObserver(self, selector: #selector(handleTapActionOnHotNewsCell(_:)), name: .handleTapActionOnHotNewsCell, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(shouldResumePlayer), name: .shouldResumePlayer, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(shouldPausePlayer), name: .shouldPausePlayer, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleReport(notification:)), name: handleReportFeed, object: nil)
        
        overrideUserInterfaceStyle = .dark
        mainView.isAppear = true
        navigationController?.setNavigationBarHidden(false, animated: false)
        setupNavigationBar(color: .clear, isTransparent: true)
        configureTabBar(by: feedType)
        handleLoadMyCurrency?()
        shouldResumePlayer()
        disablePlayWhenOnCall()
        updateStory()
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if isFromPushFeed {
            mainView.tuiView.refreshControl = UIRefreshControl()
        }else{
            mainView.setupRefreshControl()
        }
        
        mainView.isAppear = true
        if !isRefresh, interactor.selectedFeedId.count > 0 { // reload item from back/pop event
            interactor.requestFeed(by: interactor.selectedFeedId)
        }
        resume()
       //  startTimer()
        
        // causing video leak in sdk 2.0.1.34
//        if !interactor.isForSingleFeed {
//            interactor.requestFeed(by: interactor.selectedFeedId)
//        }
        
        resumePreload()
        
        if(mainView.tuiView.videos.count == 0){
            if(feedType == .donation){
                pullToRefresh()
            }
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
    }
    
//    public override func loadView() {
////        view = mainView
//        view.addSubview(mainView)
//        mainView.frame = view.bounds
//        showView = mainView
//    }
    
    public required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
       // stopTimer()
    }
    
    private func configureTabBar(by feedType: FeedType) {
        switch feedType {
        case .profile, .explore, .channel, .searchTop:
            tabBarController?.tabBar.isHidden = true
        default:
            tabBarController?.tabBar.isHidden = false
        }
    }
    
//    private func startTimer() {
//        
//        //PE-13652 this to prevent page 0 called with page 1 simultaneously
//        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
//            guard let self = self else { return }
//            KKLogFile.instance.log(label:"\(feedType)", message: "DataScheduler startTimer")
//            loadDataScheduler = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(handleLoadDataScheduler), userInfo: nil, repeats: true)
//            loadDataScheduler?.fire()
//        }
//
//    }
//    
//    private func stopTimer() {
//        print("DataScheduler", feedType, "stop")
//        loadDataScheduler?.invalidate()
//        loadDataScheduler = nil
//    }
    
    private func showNetworkErrorDialog(title: String = "", onRetry: (() -> Void)? = nil, onCancel: (() -> Void)? = nil) {
        //PE-11660, always retry
//        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
//            onRetry?()
//        }
        showToast(with: "Network Error \(title)", backgroundColor: .redError, textColor: .white)
        
//        let alert = UIAlertController(title: "Network Error \(title)" , message: "", preferredStyle: .actionSheet)
//
//        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { [weak self] (UIAlertAction) in
//            guard self != nil else { return }
//            onCancel?()
//        }))

//        alert.addAction(UIAlertAction(title: "Retry", style: .default , handler:{ [weak self] (UIAlertAction) in
//            guard self != nil else { return }
//            onRetry?()
//        }))
//        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { [weak self] (UIAlertAction) in
//            guard self != nil else { return }
//            onCancel?()
//        }))
//        self.present(alert, animated: true)
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
    
//    @objc private func handleLoadDataScheduler() {
//        
//        let videoCount = mainView.tuiView.videos.count
//        //let videoCount = feeds.count
//        
//        guard feedType != .profile else { print("DataScheduler", feedType, "guard 1"); return }
//        guard loadDataTryCount < self.MAX_TRY_COUNT else { print("DataScheduler", feedType, "guard 2"); return }
//        guard !isLoadingData else { print("DataScheduler", feedType, "guard 3"); return }
//        
//        var canAutoLoadData = false
//        
//        let diffMinDataShow = videoCount - MIN_DATA_SHOW
//        let currentIndexIsOverlap = mainView.tuiView.currentVideoIndex >= diffMinDataShow
//        
//        if(videoCount > 1) {
//            if currentIndexIsOverlap {
//                print("DataScheduler", feedType, "can 4", "currentIndexIsOverlap")
//                canAutoLoadData = true
//            }
//        }
//        
//        if interactor.page >= 0 && videoCount < MIN_DATA_SHOW {
//            if(feedType != .following){
//                print("DataScheduler", feedType, "can 5")
//                canAutoLoadData = true
//            } 
//        }
//            
//        if(canAutoLoadData) {
//            loadDataTryCount += 1
//            print("DataScheduler", feedType, "running try for:", loadDataTryCount)
//            handleLoadMore()
//        } else {
//            
//            print("DataScheduler", feedType, "ignore auto Load data", "feeds.count: \(videoCount)"
//                  , "mainView.tuiView.videos.count: \(mainView.tuiView.videos.count)", "interactor.page: \(interactor.page)")
//        }
//        
//        
//    }
    
    @objc private func shouldRefreshData() {
        viewType = .loading
        
        mainView.tuiView.removeAllVideoModels()
//        self.interactor.page = 0
        self.interactor.requestFeeds(reset: true)
    }
    
    @objc func handleDelete(notification: NSNotification){
        pauseIfNeeded()
        
        if let index = indexFeedByIdFromNotification(notification) {
            let id = feeds[index].post?.id
            
            feeds.remove(at: index)
            
            if feedType == .profile || feedType == .otherProfile || feedType == .explore || feedType == .channel {
                NotificationCenter.default.post(name: Notification.Name(rawValue: "com.kipaskipas.updateProfile"), object: nil)
                
                if feedType == .explore || feedType == .channel {
                    NotificationCenter.default.post(name: .init("exploreDeleteContent"), object: id)
                }
               
                navigationController?.popViewController(animated: true)
            }
        }
    }
    
    @objc func handleReport(notification: NSNotification){
        if let index = indexFeedByIdFromNotification(notification) {
            
            // ngeremove index 0 sampai index yang di report
            feeds.removeSubrange(0...index)
            mainView.tuiView.setShortVideoModels(feeds)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
                guard let self = self else { return }
                let tuiCountVideos = self.mainView.tuiView.videos.count
                if tuiCountVideos > 0 {
                    self.mainView.tuiView.didScrollToCell(with: 0, animated: false)
                    self.resume()
                }
            }
            
            // ngeremove index reported dan scrolling ke next index. Tapi video yang keplay index 0
//            feeds.remove(at: index)
//            mainView.tuiView.setShortVideoModels(feeds)
//            print("oiiiiii1", feeds.count)
//            self.mainView.tuiView.pause()
//            DispatchQueue.main.async {
//                self.mainView.tuiView.didScrollToCell(with: index)
//            }
            
            
            //kode sebelumnya
//            feeds.remove(at: index)
//
//            DispatchQueue.main.async {
//                self.mainView.tuiView.tableView()?.beginUpdates()
//                self.mainView.tuiView.videos.removeObject(at: index)
//                self.mainView.tuiView.tableView()?.deleteRows(at: [.init(row: index, section: 0)], with: .top)
//
//                /// Due to the trickiness of TUIPlayer
//                /// need to scroll to index + 1 (skipping one video)
//                /// It's better if Tencent provides delete item at index mechanism.
//                if self.mainView.tuiView.videos[safe: index + 1] != nil {
//                    self.mainView.tuiView.didScrollToCell(with: index + 1)
//                }
//                self.mainView.tuiView.tableView()?.endUpdates()
//            }
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
//        mainView.tuiView.resume()

        if !mainView.tuiView.isPlaying {
            print("***** resume NOT Playing", feedType, "status:",mainView.tuiView.currentPlayerStatus.rawValue)
//
//            print("***** resume 2.paused", feedType)
            
            switch mainView.tuiView.currentPlayerStatus {
                case .ended: // kasus donasi [PE-11965], tidak playing, isPlaying = false, status = ended (5)
                    print("***** resume NOT Playing - ended", feedType)
                    if(feedType == .donation){
                        reSetVideos()
                    }
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
//                    if(feedType == .donation){
//                        mainView.tuiView.resume()
//                    }
//                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
//                        guard let self = self else { return }
//                        guard self.topMostViewController() == self else { return }
//                        
//                        if !self.mainView.tuiView.isPlaying {
//                            // this cause issue [PE-13440], while issue [PE-12132] not occured anymore
//                            //self.reSetVideos()
//                        }
//                    }
//                    mainView.tuiView.resume()
                self.goResumeVideo()

                case .prepared:
//                    mainView.tuiView.resume()
//                self.resume()
                self.goResumeVideo()
                    print("***** resume NOT Playing - prepared", feedType)
                case .unload:
                    print("***** resume NOT Playing - unload", feedType)
//                mainView.tuiView.resume()
//                self.resume()
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
        mainView.disablePlay = true
        
        if mainView.tuiView.isPlaying {
//            mainView.tuiView.pause()
            pause()
        }
    }
    
    public func resumeIfNeeded() {
        mainView.disablePlay = false

        if !mainView.tuiView.isPlaying {
//            mainView.tuiView.resume()
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

extension HotNewsViewController: HotNewsViewDelegate {
    func getMediaType() -> FeedMediaType? {
        interactor.mediaType  
    }
    
    func getFeeds() -> [FeedItem] {
        feeds
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
    
    func showPlayingType() {
//        return
//        showToastType(msg: "start play")
        let isTop = isTheShowController()
        print("pointpoint le isTop = \(isTop) type = \(feedType) ")
        guard isTop else {
            pause()
            return
        }
        viewType = .video
//        DispatchQueue.main.async {
//            self.pause()
//            self.resume()
//        }
    }
    
    func showAlert(text: String) {
        showToast(with: "\(text)", backgroundColor: .redError, textColor: .white)
    }
    
    func refreshStory() {
        if feedType == .following {
            mainView.storyView.listView.myStory = nil
            mainView.storyView.listView.stories = []
            interactor.requestStories(reset: true)
        }
    }
    
    func isOnTopController() -> Bool {
        let isHome = NSStringFromClass(type(of: topMostVC!)) == "KipasKipas.NewHomeController"
        let isHotnews = type(of: topMostVC) == type(of: self)
        
        return isHome || isHotnews
    }

    func configTUI(speedInKb: Int) {
        let model = TUIPlayerVodStrategyModel()
        model.mRenderMode = .RENDER_MODE_FILL_SCREEN
        model.isLastPrePlay = true
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
        
        if !interactor.isForSingleFeed {
            interactor.requestFeed(by: item.id ?? "")
        }
        
        saveCache(current: index) // Ketika scrolling
        disablePlayWhenOnCall()
    }
    
    func handleSeenBy(id: String, accountId: String) {
        setLastAppear()
        if !interactor.isLogin && isFromPushFeed {
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
        feeds = []
        mainView.tuiView.setShortVideoModels(feeds)
        refreshing()
        loadCache()
    }
    
    func refreshing(){
        guard !isLoadingData else { return }

        isLoadingData = true
        viewType = .loading

        if(isRefresh){
            mainView.tuiView.removeAllVideoModels()

            if feedType == .following {
                interactor.requestFollowing()
                self.interactor.requestStories(reset: true)
                return
            }
            
            self.interactor.requestFeeds(reset: true)

        }
    }
    
    func handleOnLicenceLoaded(_ result: Int32, reason: String) {
        guard result == 0 else { return }
        DispatchQueue.main.async {
            let empty: [TUIPlayerVideoModel] = []
            self.mainView.tuiView.setShortVideoModels(empty)
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
        
        if feedType == .profile {
            guard interactor.page < interactor.totalPage else { return }
            isLoadingData = true
//            interactor.page += 1
            isFromPushFeed ?  interactor.requestPushFeeds(reset: false) : interactor.requestFeeds()
        } else {
            isLoadingData = true
//            interactor.page += 1
            isFromPushFeed ?  interactor.requestPushFeeds(reset: false) : interactor.requestFeeds()
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

extension HotNewsViewController: IHotViewController {

    public func setRouter(router: IHotNewsRouter) {
        self.router = router
    }
    
    public var viewsFeeds: [FeedItem] {
        feeds
    }

    //    MARK: -  error  SingFeed
    public func displayErrorSingleFeed(with message: String) {

//        mainView.kkRefreshControl.endRefreshing()
        loadingView.stopLoading()
        if interactor.isForSingleFeed {
                if isFromPushFeed {
                    let item = FeedItem()
                    item.feedType = .deletePush
//                    feeds = interactor.alreadyLoadFeeds
//                    mainView.feeds = [item]
                    feeds.append(contentsOf: [item])
//                    if(isFromPushFeed){
//                        mainView.tuiView.appendShortVideoModels([item])
//                    }else{
                        mainView.tuiView.setShortVideoModels(feeds)
//                    }
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
            mainView.tuiView.setShortVideoModels([item])
            interactor.alreadyLoadFeeds = feeds
            
            if isFromPushFeed { 
                interactor.requestPushFeeds(reset: true)
            }
            
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
    
    public func displayFeedTrendingCache(with item: FeedItem) {
        print("***preload CACHE \(LOG_ID) \(feedType) ")
//        showToastType(msg: ".video 3")
//        viewType = .video
        let uniqueItems = uniqueItems(feeds, [item])
        print("PE-12388 append trending cache?", !uniqueItems.isEmpty)
        feeds.append(contentsOf: uniqueItems)
//        mainView.feeds.append(contentsOf: feeds)
        mainView.tuiView.appendShortVideoModels(feeds)

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            self.resumePreload()
            self.updateEmptyState(items: uniqueItems)
        }
    }

    public func displayUpdateFollowAccount(id: String) {
    }
    
    public func displayMentionUserByUsername(id: String?, type: String?) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { KKDefaultLoading.shared.hide() }
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
            if feedType == .donation {
                viewType = .donationEmpty(isFilterActive: interactor.isDonationFilterActive())
            } else {
                viewType = .error(message: title)
            }
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
            
//            showDataEmptyDialog(onRetry: { [weak self] in
//                guard let self = self else { return }
//                self.interactor.latitude = 0.0
//                self.interactor.longitude = 0.0
//                self.interactor.provinceId = ""
//                self.interactor.categoryId = ""
//                self.pullToRefresh()
//            }, title: "Data Donasi tidak tersedia-2")
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
    
    public func displayFeeds(with items: [FeedItem], totalItems:Int = 0, isLogin: Bool) {
        
        KKLogFile.instance.log(label:"displayFeeds \(feedType)", message: "items: \(items.count)   from: \(totalItems)")
        
        if(!mainView.isValidTUILicense()){
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
                guard let self = self else { return }
                print("***** displayFeeds \(self.feedType) NOT Valid TUI")
                // TUI License not loaded, mainly because Network problem
                self.pullToRefresh()
            }
        }
//        showToastType(msg: ".video 2")
//        viewType = .video
        handleLoadMyCurrency?()
        isLoadingData = false
        
        if feedType != .donation {
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
        }
        
        switch feedType {
        case .profile, .explore, .channel, .searchTop, .following:

            if(feedType == .following){
                pausePreload()
            }

            if isRefresh {
                
                if interactor.alreadyLoadFeeds.isEmpty {
                    feeds = items
                    mainView.tuiView.setShortVideoModels(items)

                    if( feedType == .following) {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
                            guard let self = self else { return }
                            let tuiCountVideos = self.mainView.tuiView.videos.count
                            if tuiCountVideos > 0 {
                                self.mainView.tuiView.didScrollToCell(with: 0, animated: false)
                                self.resume()
                            }
                        }
                    }
                } else {
                    feeds = interactor.alreadyLoadFeeds
                    
                    if(isFromPushFeed){
                        if items.count == 0 {
                            self.showTipsMsg("No more data",position: .center)
                        }
                        let pushItem = feeds.first
                        let newItems = items.filter{$0.id != pushItem?.id}
                        feeds.append(contentsOf: newItems)
                        
                        mainView.tuiView.appendShortVideoModels(newItems)
                    }else{
                        feeds.append(contentsOf: items)
                        feeds = feeds.filterDuplicates()
                        mainView.tuiView.setShortVideoModels(feeds)
                    }
                    interactor.alreadyLoadFeeds = []
                    
                    if let index = feeds.firstIndex(where: { $0.id == interactor.selectedFeedId }) {
                        scrollWithRetry(to: index)
                    }
                }
                print("xxxxxx \(feedType) isRefresh6 = false")
                isRefresh = false
            } else {

                if(isFromPushFeed){
                    if items.count == 0 {
                        self.showTipsMsg("No more data",position: .center)
                    } 
                    let pushItem = feeds.first
                    let newItems = items.filter{$0.id != pushItem?.id}
                    
                    feeds.append(contentsOf: newItems)
                    mainView.tuiView.appendShortVideoModels(newItems)
                }else{
                    feeds.append(contentsOf: items)
    //                mainView.feeds = feeds
                    mainView.tuiView.appendShortVideoModels(items)
                }
                
            }
            
        default:
            let uniqueItems = uniqueItems(feeds, items)
            print(" *** uniqueFeed displayFeeds \(self.feedType) items: ", items.count, "  uniqueItems: ", uniqueItems.count)
            print(" *** uniqueFeed -------- isRefresh = \(isRefresh)")
            
            if isRefresh {                
                feeds = []
//                mainView.feeds = []
                print("*** uniqueFeed refresh 1", feedType)
                feeds.append(contentsOf: uniqueItems)
//                mainView.feeds.append(contentsOf: uniqueItems)
                mainView.tuiView.setShortVideoModels(uniqueItems)
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
                    guard let self = self else { return }
                    
                    let tuiCountVideos = self.mainView.tuiView.videos.count                    
                    if tuiCountVideos > 0 {
                        //print("*** didScrollToCell default", feedType)
                        KKLogFile.instance.log(label:"HotNewsViewController \(feedType)", message: "didScrollToCell default")
                        self.mainView.tuiView.didScrollToCell(with: 0, animated: false)
                        self.resume()
                    }
                }

                
                if(!mainView.isAppear){
                    pausePreload()
                }
                if items.isEmpty {
                    if feedType == .donation {
                        displayDonation()
                    } else {
                        refreshEmpty(uniqueItems, totalItems, isLogin)
                    }
                }
                print("xxxxxx \(feedType) isRefresh7 = false")
                isRefresh = false
            } else {
                if uniqueItems.isEmpty {
                    if feedType == .donation {
                        handleDonationEmpty()
                    } else {
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
                    }
                    return
                } else {
                    loadDataTryCount = 0
                    feeds.append(contentsOf: uniqueItems)
                    mainView.tuiView.appendShortVideoModels(uniqueItems)
                }
            }
        }
        
//        DispatchQueue.main.asyncAfter(deadline: .now() + 15) {
//            self.updateEmptyState(items: items)
//        }
        DispatchQueue.main.async {
            self.updateEmptyState(items: items)
        }
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
        
        guard feedType == .hotNews else { return }
        
        print("**** refreshIfDataIsOld.. start refreshing", feedType)
        
        //Data
        feeds = []
        mainView.tuiView.setShortVideoModels([])
        
        //UI
        //viewType = .loading //comment this, cause [PE-14101]
        mainView.tuiView.removeAllVideoModels()
        
        // Load Data
        loadCache()
//        interactor.page = 0
        shouldRefreshData()
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
     
    public func displayStories(with data: StoryData) {
        storyData = data
        mainView.storyView.listView.myStory = data.myFeedStory
        if interactor.storyPage == 0 {
            let stories = data.feedStoryAnotherAccounts?.content ?? []
            otherStories = stories
        } else {
            let stories = data.feedStoryAnotherAccounts?.content ?? []
            otherStories = unify(otherStories + stories)
        }
        
        mainView.storyView.listView.myStory = data.myFeedStory
        mainView.storyView.listView.stories = otherStories
    }
}

// MARK: - Helper
private extension HotNewsViewController {
    func updateEmptyState(items: [FeedItem]) {
        let sequence: [FeedType] = [.donation, .feed, .following, .hotNews]
        guard sequence.contains(where: {$0 == feedType}) else { return }
        
        if mainView.tuiView.videos.count == 0 {
            print("PE-12552 showing empty feedType:", feedType)
            if feedType == .donation {
                viewType = .donationEmpty(isFilterActive: interactor.isDonationFilterActive())
            } else {
                viewType = .error(message: "Data tidak tersedia")
            }
        } else {
            print("PE-12552 hiding empty")
//            self.viewType = .loading
//            self.showToastType(msg: ".video 1")
//            print("abc type = \(mainView.tuiView.currentVideoModel)")
            if let item = mainView.tuiView.currentVideoModel as? FeedItem {
                
                let it = feeds.first(where: { i in
                    i.id == item.id
                })
                if let theItem = it {
//                    print("abc type = \(item.feedMediaType)")
                    if theItem.post?.medias?.first?.type == "image" {
                        self.viewType = .video
                    }
                }
            }
            
//            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
//                self.showToastType(msg: ".video 1")
//                self.viewType = .video
//            }
            
            
            
        }
    }
    
    func uniqueItems(_ oldItems: [FeedItem], _ newItems: [FeedItem]) -> [FeedItem] {
        if feedType == .donation {
            return newItems
        }
        
        var uniqueItems: [FeedItem] = []
        newItems.forEach { item in
            guard !oldItems.contains(where: { $0.id == item.id }) else {
                return
            }
            uniqueItems.append(item)
        }

        return uniqueItems
    }

    func saveCache(current index: Int) {
        guard feedType == .hotNews else { return }
        guard let item = mainView.tuiView.videos[safe: index + 1] as? FeedItem else { return }

        interactor.trendingCache.save(with: item)
    }

    func loadCache() {
        
        return
        
        guard feedType == .hotNews else { return }
        interactor.trendingCache.load(type: feedType)
    }
    
    func reSetVideos() {
        let currIdx = mainView.tuiView.currentVideoIndex //keep the current index
        let items = mainView.tuiView.videos as? [FeedItem] ?? feeds
        guard items[safe: currIdx]?.post?.medias?.first?.type == "video" else { return }
        
        // set empty first
        mainView.tuiView.setShortVideoModels([])
        //mainView.tuiView.didScrollToCell(with: 0, animated: false)
        
        mainView.tuiView.setShortVideoModels(items) // re-set data
        scrollWithRetry(to: currIdx) // auto scroll to current index
    }
    
    func scrollWithRetry(to index: Int) {
        guard mainView.tuiView.currentVideoIndex != index else { return } // validate if current index = target index
        
        guard mainView.tuiView.videos.count > index else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.025) { [weak self] in
                guard let self = self else { return }
                self.scrollWithRetry(to: index)
            }
            
            return
        }
        
        mainView.tuiView.didScrollToCell(with: index, animated: false)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.025) { [weak self] in // delay for check target index from first code in this func
            guard let self = self else { return }
            self.scrollWithRetry(to: index)
        }
    }
}

// MARK: Call Handler for Play/Pause
private extension HotNewsViewController {
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
private extension HotNewsViewController {
    private func showToastType(msg: String) {
        var window = UIWindow()
        if #available(iOS 13.0, *) {
            window = UIApplication.shared.windows.filter({ $0.isKeyWindow }).last ?? UIWindow()
        } else {
            window = UIApplication.shared.keyWindow ?? UIWindow()
        }
        showToast(with: msg, backgroundColor: .green, isOnTopScreen: true, textColor: .red, backgroundView: window)
    }
    
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
//                mainView.tuiView.pause()
                pause()
            }
            showView = newView
        }
//        if view != newView {
//            view = newView
//        }
    }

    
//    override func viewDidLayoutSubviews() {
//         super.viewDidLayoutSubviews()
//        mainView.setupTUIView(cell: feedType.controllCell, feedType: feedType)
//    }
    
    private func updateView() {

//        showToastType(msg: "viewType = \(viewType)")
        errorView.button.isHidden = false
        
        switch viewType {
        case .video:
            setViewIfNeeded(mainView)
        case let .following(data):
            setViewIfNeeded(followingView)
            followingView.configure(with: data)
        case let .error(message):
            if(feeds.isEmpty){
                setViewIfNeeded(errorView)
                errorView.message = message
            } else {
//                print("xxxxxx error feedsNoEmpy")
//                showToast(with: "xxxxxx error feedsNoEmpy")
            }
        case .loading:
            setViewIfNeeded(loadingView)
            
        case let .notFound(message):
            setViewIfNeeded(errorView)
            errorView.message = message
            errorView.button.isHidden = true
        case let .donationEmpty(isFilterActive):
            donationEmptyView.isFilterActive = isFilterActive
            setViewIfNeeded(donationEmptyView)
        }
    }
}

// MARK: - HotNews View Event Delegate
extension HotNewsViewController: HotNewsViewEventDelegate {
    
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
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { KKDefaultLoading.shared.show() }
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
extension HotNewsViewController: FollowingViewDelegate {
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
extension HotNewsViewController: HotNewsErrorViewDelegate {
    func didTapButton() {
        if errorView.message.lowercased().contains("login") {
            router.presentPublicEmptyPopup()
            return
        }
        
        pullToRefresh()
    }
}

extension HotNewsViewController: DonationEmptyViewDelegate {
    func didChangeFilter() {
        router.presentDonationFilterCategory(id: interactor.categoryId)
    }
}

// MARK: - Story List View Delegate
extension HotNewsViewController: StoryListViewDelegate {
    public func didSelectedMyStory(by item: KipasKipasStory.StoryFeed) {
        guard let data = storyData else { return }
        router.presentMyStory(item: item, data: data, otherStories: otherStories)
    }
    
    public func didSelectedLive() {
        router.presentStoryLive()
    }
    
    public func didSelectedOtherStory(by item: KipasKipasStory.StoryFeed) {
        guard let data = storyData else { return }
        router.presentOtherStory(item: item, data: data, otherStories: otherStories)
    }
    
    public func didAddStory() {
        router.storyDidAdd()
    }
    
    public func didRetryUpload() {
        router.storyDidRetry()
    }
    
    public func didReachLast() {
        //interactor.requestStories(reset: false)
    }
}

// MARK: - Hotnews Story View Delegate
extension HotNewsViewController: HotNewsStoryViewDelegate {
    func didShow() {
//        pause()
        mainView.storyOverlayView.isHidden = false
        updateStory()
        interactor.requestStories(reset: true)
    }
    
    func didDismiss() {
//        resume()
        mainView.storyOverlayView.isHidden = true
    }
}

// MARK: - Private Story Func
private extension HotNewsViewController {
    private func bindStoryObserver() {
        guard feedType == .following else { return }
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(storyUploadDidStartUploadNotification),
            name: Notification.Name("storyUploadDidStartUploadNotification"),
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(storyUploadDidProgressNotification),
            name: Notification.Name("storyUploadDidProgressNotification"),
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(storyUploadDidFailureNotification),
            name: Notification.Name("storyUploadDidFailureNotification"),
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(storyUploadDidCompleteNotification),
            name: Notification.Name("storyUploadDidCompleteNotification"),
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(storyDidBackFromViewing),
            name: Notification.Name("storyDidBackFromViewing"),
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(updateIsFollowFromFolowingFolower),
            name: .updateIsFollowFromFolowingFolower,
            object: nil
        )
    }
    
    private func updateStory() {
        guard feedType == .following else { return }
        
        if router?.storyOnError() == true { // nil or false
            mainView.storyView.listView.setUploadError()
            return
        }
        
        if router?.storyOnUpload() != true { // nil or true
            return
        }
        
        if let p = router?.storyUploadProgress() {
            mainView.storyView.listView.setUploadProgress(to: p)
        }
    }
    
    @objc private func storyUploadDidStartUploadNotification(_ notification: NSNotification) {
        guard feedType == .following, mainView.window != nil else { return }
        
        expandStoryListView()
    }
    
    @objc private func storyUploadDidProgressNotification(_ notification: NSNotification) {
        guard feedType == .following else { return }
        if let p = notification.userInfo?["progress"] as? Double {
            DispatchQueue.main.async {
                self.mainView.storyView.listView.setUploadProgress(to: p)
            }
        }
    }
    
    @objc private func storyUploadDidFailureNotification() {
        guard feedType == .following else { return }
        mainView.storyView.listView.setUploadError()
    }
    
    @objc private func storyUploadDidCompleteNotification() {
        guard feedType == .following else { return }
        mainView.storyView.listView.setUploadDone()
        interactor.requestStories(reset: true)
    }

    @objc func storyDidBackFromViewing() {
        guard feedType == .following else { return }
        interactor.requestStories(reset: true)
    }

    @objc private func updateIsFollowFromFolowingFolower() {
        guard feedType == .following else { return }
        interactor.requestStories(reset: true)
    }
}
// MARK: - Public Story Func
public extension HotNewsViewController {
    func expandStoryListView() {
        guard feedType == .following else { return }
        mainView.storyView.expand()
    }
    
    func collapseStoryListView() {
        guard feedType == .following else { return }
        mainView.storyView.collapse()
    }
}

extension HotNewsViewController: UIGestureRecognizerDelegate {}

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
 
func unify<T: Hashable>(_ array: [T]) -> [T] {
    var seen: Set<T> = []
    return array.filter { seen.insert($0).inserted }
}
 
extension Array where Element: FeedItem {
    func filterDuplicates() -> [Element] {
        return self.reduce(into: [Element]()) { result, element in
            if !result.contains(where: { $0.id == element.id }) {
                result.append(element)
            }
        }
    }
}
