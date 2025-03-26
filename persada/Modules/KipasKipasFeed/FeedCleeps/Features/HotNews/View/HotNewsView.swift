//
//  HotNewsView.swift
//  FeedCleeps
//
//  Created by DENAZMI on 04/10/23.
//
import SnapKit
import Foundation
import TUIPlayerCore
import TUIPlayerShortVideo
import KipasKipasShared
import TXLiteAVSDK_Professional


protocol IHotStoryViewDelegate: UIViewController {
    func refreshStory()
}

protocol HotNewsViewDelegate: HotNewsDelegate, IHotStoryViewDelegate {
}

protocol HotNewsDelegate: UIViewController {
    func pullToRefresh()
    func handleOnLicenceLoaded(_ result: Int32, reason: String)
    func handleLoadMore()
    func handleSeenBy(id: String, accountId: String)
    func scrolled(to index: Int, with item: FeedItem)
    func configTUI(speedInKb: Int)
    func isOnTopController() -> Bool
    func showAlert(text: String)
    func showPlayingType()
    func getFeeds() -> [FeedItem]
    
    func getMediaType() -> FeedMediaType?
}


public class HotNewsView: UIView, IHotNewsView {
    var disablePlay: Bool = false
    var isAppear = false {
        didSet {
            disablePlay = !isAppear
            handleCollapseStoryView()
        }
    }
    
    let LOG_ID = ""
        
    lazy var kkRefreshControl: UIRefreshControl = {
        let view = UIRefreshControl()
        view.tintColor = .red
        view.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        return view
    }()
    
    lazy var pullUpRefreshControll: TUIPullUpRefreshControl = {
        let loadingView = UILabel(text: "Loading...", font: .Roboto(.medium, size: 12), textColor: .white)
        
        let view = TUIPullUpRefreshControl()
        view.loadingViewSize = CGSize(width: UIScreen.main.bounds.size.width, height: 0)
        view.loadingView = loadingView
        view.delegate = self
    
        return view
    }()
    
    public lazy var tuiView: HotNewsVideoView = {
        let view = HotNewsVideoView()
        return view
    }()
    
    lazy var storyOverlayView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        view.isHidden = true
        
        return view
    }()
    
    lazy var storyView: HotNewsStoryView = {
        let view = HotNewsStoryView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    weak var delegate: HotNewsViewDelegate?
    weak var eventDelegate: HotNewsViewEventDelegate?
//    public var feeds: [FeedItem] = []
    
    var lastNetSpeedInt = 1_000
    
    deinit {
        tuiView.destoryPlayer()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    public override func didMoveToWindow() {
        super.didMoveToWindow()
        checkPlayer()
    }
    
    func commonInit() {
        let nibName = type(of: self).description().components(separatedBy: ".").last ?? ""
        let nib = UINib(nibName: nibName, bundle: Bundle.init(identifier: "com.koanba.kipaskipas.mobile.FeedCleeps"))
        if let view = nib.instantiate(withOwner: self, options: nil).first as? UIView {
            addSubview(view)
            view.frame = bounds
            view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        }
    }
    
    func isValidTUILicense() -> Bool{
        let licence = TXLiveBase.getLicenceInfo()
        
        if licence.isEmpty {
            lincenceConfig()
            return false
        }
        
        return true
    }
    
    func setupTUIView(cell: TUIPlayerShortVideoControl.Type, feedType: FeedType) {
//        let licence = TXLiveBase.getLicenceInfo()
//        
//        if licence.isEmpty {
//            lincenceConfig()
//        }

        isValidTUILicense()
    
        let uiManager = TUIPlayerShortVideoUIManager()
        uiManager.setControlViewClass(cell)
        uiManager.setBackgroundView(UIView())
        uiManager.setVideoPlaceholderImage(UIImage())
        var loadingView = HotNewsLoadingView()
        let mediaType = delegate?.getMediaType()
        if feedType == .feed , mediaType == .image {
            loadingView = HotNewsLoadingView(isBlackTitle: true)
        } 
        
        uiManager.setLoading(loadingView)
        
        let view = HotNewsVideoView(uiManager: uiManager)
        tuiView = view
        tuiView.delegate = self
        tuiView.customCallbackDelegate = self
        tuiView.backgroundColor = .black
        tuiView.refreshControl = kkRefreshControl
        tuiView.pullUpRefreshControl = pullUpRefreshControll
        tuiView.isAutoPlay = true
        
        if !self.subviews.contains(tuiView) {
            addSubview(tuiView)
        }
        
        let size = UIScreen.main.bounds.size
        var height = size.height
        let window = UIApplication.shared.windows.first
        
        switch feedType {
        case .donation, .feed, .hotNews, .following: // Ini flagging kalo dia ada di home
            height -= (window?.rootViewController?.topMostViewController().tabBarController?.tabBar.frame.height ?? 83)
        default : height -= (window?.safeAreaInsets.bottom ?? 34)
        }
        
        tuiView.frame = CGRectMake(0, 0, size.width, height)
        tuiView.startLoading()
        setupStoryView(type: feedType)
    }
    
    func setupRefreshControl() {
        tuiView.tableView()?.bounces = true
    }
    
    private func lincenceConfig() {
        let config = TUIPlayerConfig()
        config.enableLog = true
//        config.licenseUrl = "https://license.vod-control.com/license/v2/1316940742_1/v_cube.license"
//        config.licenseKey = "7e83f0cac294d0b9f53a23c96b36c388"
        TUIPlayerCore.shareInstance().setPlayerConfig(config)
//        TUIPlayerAuth.shareInstance().delegate = self
        
        TXLiveBase.setLicenceURL("https://license.vod-control.com/license/v2/1316940742_1/v_cube.license", key: "7e83f0cac294d0b9f53a23c96b36c388")
        TXLiveBase.sharedInstance().delegate = self
    }
    
    private func checkPlayer() {
        if disablePlay { // disable play
            tuiView.pause()
        }
        
        if window == nil { // this view dettached
            tuiView.pause()
            return
        }
        
//        if delegate?.isOnTopController() == false { // this view/controller is not on top/visible for user
//            print("pausepause 01")
//            tuiView.pause()
//            return
//        }
//        
//        if disablePlay { // disable play
//            print("pausepause 001")
//            tuiView.pause()
//            return
//        }
//         
        if UIApplication.shared.applicationState == .background {
            if(tuiView.isPlaying){
                tuiView.pause()
                return
            }
        }

    }
    
//    func setResolution(isFast: Bool) {
//        let model = TUIPlayerStrategyModel()
//        model.mRenderMode = .RENDER_MODE_FILL_SCREEN
//        model.enableAutoBitrate = false
//        //model.mIsPreVideoResume = true
//        model.mIsPreVideoResume = false
//
//        model.mPreloadConcurrentCount = 3
//        model.mPreloadBufferSizeInMB = 0.8
//        model.mPreferredResolution = 1080 * 1920
//
//        tuiView.setShortVideoStrategyModel(model)
//    }
    
    @objc private func handleRefresh() {
        delegate?.pullToRefresh()
    }
}

extension HotNewsView: TXLiveBaseDelegate {
    public func onLicenceLoaded(_ result: Int32, reason: String) {
        //setResolution(isFast: true)
        print("Hotnews License TUI: \(reason)")
        KKLogFile.instance.log(label:"Hotnews", message: "License TUI: \(reason)")
        
        //configTUI(speedInKb: 11_000_000)
        delegate?.handleOnLicenceLoaded(result, reason: reason)
        tuiView.stopLoading()
    }
}

extension HotNewsView: TUIShortVideoViewDelegate {
    public func videoPreLoadState(with videoModel: TUIPlayerVideoModel) {
        //print("**** HotNewsController  videoPreLoadState \(videoModel.videoUrl)")
        
        if(videoModel.videoUrl.lowercased().contains(".m3u8") || videoModel.videoUrl.lowercased().contains(".mp4")) {
            let feedType = delegate?.getFeeds().first?.typePost
            var state = ""
            
            switch videoModel.preloadState {
                case .finished:
                    state = "finished"
                case .failed:
                    state = "failed"
                case .none:
                    state = "none"
                case .start:
                    state = "start"
                default:
                    state = "unknown"
            }
            
            //print("** Preload \(feedType ?? "") \(KKVideoId().getId(urlString: videoModel.videoUrl)), state:\(state)")
            //KKLogFile.instance.log(label:"Preload", message: "\(KKVideoId().getId(urlString: videoModel.videoUrl )), state:\(state) ")
        }
    }
    
    public func currentVideo(_ videoModel: TUIPlayerVideoModel, statusChanged status: TUITXVodPlayerStatus) {
                
        if(videoModel.videoUrl.lowercased().contains(".mp4") || videoModel.videoUrl.lowercased().contains(".m3u8")){
            let videoId = KKVideoId().getId(urlString: videoModel.videoUrl)
            //print("**** videoModel.videoUrl", videoModel.videoUrl)
            switch status {
                case .paused:
                    //print("*** currentVideo \(videoId) status: paused")
                    break
                case .ended:
                    //print("*** currentVideo \(videoId) status: ended")
                    break
                case .unload:
                    //print("*** currentVideo \(videoId) status: unload")
                    //KKLogFile.instance.log(label:"currentVideo \(videoId)", message: "status: unload")
                    break
                case .prepared:
                    //print("*** currentVideo \(videoId) status: prepared")
                    //KKLogFile.instance.log(label:"currentVideo \(videoId)", message: "status: prepared")
                    break
                case .loading:
                    //print("*** currentVideo \(videoId) status: loading")
                    //KKLogFile.instance.log(label:"currentVideo \(videoId)", message: "status: loading")
                    break
                case .playing:
                    if UIApplication.shared.applicationState == .background {
                        tuiView.pause()
                        return;
                    }
                delegate?.showPlayingType()
                    //print("currentVideo \(videoId) status: playing")
                    KKLogFile.instance.log(label:"currentVideo \(videoId)", message: "status: playing")
                case .error:
                    print("*** currentVideo \(videoId) status: ERROR", videoModel.videoUrl)
                    KKLogFile.instance.log(label:"currentVideo \(videoId)", message: "status: ERROR", level: .error)
                default:
                    print("*** currentVideo \(videoId) status default: \(status)")
            }
        }
        
    }
    
    public func currentVideo(_ videoModel: TUIPlayerVideoModel, currentTime: Float, totalTime: Float, progress: Float) {
        if(!self.isAppear){
            tuiView.pause()
        }
        
        if(currentTime > 0.0){
            if(!self.isAppear){
                tuiView.pause()
            }
        }
    }
    
    public func onNetStatus(_ videoModel: TUIPlayerVideoModel, withParam param: [AnyHashable : Any]) {
        if let netSpeed = param["NET_SPEED"] {
            if let netSpeedInt = netSpeed as? Int {
                
                if(netSpeedInt > 0){
                    if netSpeedInt == self.lastNetSpeedInt {
                        return
                    }
                    //print("**** onNetStatus netSpeedInt:", netSpeedInt, "    lastNetSpeedInt:", lastNetSpeedInt)
                    self.lastNetSpeedInt = netSpeedInt

                    //self.configTUI(speedInKb: netSpeedInt)
                }
                
            }
        }
    }
    
    func checkIsDuplicate(indexCurrent: Int, videoUrl: String){
//        if(videoUrl == ""){ return }
//
//        for (index, feed) in feeds.enumerated() {
//            if(feed.videoUrl == videoUrl){
//                if(index != indexCurrent){
//                    print("***** found duplicate index: \(index), videoUrl: \(videoUrl)", feed.typePost ?? "")
//                    //delegate?.showAlert(text: "Duplikat indexCurrent:\(indexCurrent) dan \(index)")
//                }
//            }
//        }
    }
    
    public func scroll(toVideoIndex videoIndex: Int, videoModel: TUIPlayerDataModel) {
        //print("***** scroll ", videoIndex, feeds.first?.feedType ?? "")
        handleCollapseStoryView()
        guard delegate?.getFeeds().count ?? 0 > 0 else {
            return
        }
        
        guard let feed = videoModel as? FeedItem else {
            return
        }
        
        //checkIsDuplicate(indexCurrent: videoIndex, videoUrl: videoModel.videoUrl)
        
        delegate?.scrolled(to: videoIndex, with: feed)
        
        if(videoIndex > 0){
            if(videoIndex % 10 == 0){
                delegate?.configTUI(speedInKb: lastNetSpeedInt)
            }
        }
        
        if(videoIndex == 0){
            if(isAppear){
                delegate?.configTUI(speedInKb: 11_000_000)
            }
        }
        
        if let feedType = delegate?.getFeeds().first?.typePost {
            var logTrendingAt = ""
            if(feed.feedType == .hotNews){
                logTrendingAt = "feed.id:\(feed.id ?? "") - trendingAt: \(feed.trendingAt ?? 0) , Level: \(feed.post?.levelPriority ?? 0)"
            }

            print("\(feedType) - Scroll index:\(videoIndex) to \(feed.videoUrl) , speed:\(lastNetSpeedInt), \(logTrendingAt)")

            KKLogFile.instance.log(label:"\(feedType) Scroll index:\(videoIndex)", message: "to \(feed.videoUrl) , speed:\(lastNetSpeedInt) , \(logTrendingAt)")

        }
        
        delegate?.handleSeenBy(id: feed.id ?? "", accountId: feed.account?.id ?? "")
    }
    
    public func onReachLast() {
        if let feedType = delegate?.getFeeds().first?.typePost {
            print("onReachLast", feedType)
            KKLogFile.instance.log(label:"onReachLast", message: "feedType")
        }

//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
//            guard self != nil else { return }
//            self?.delegate?.handleLoadMore()
//        }

        self.delegate?.handleLoadMore()

    }
}

extension HotNewsView: TUIPullUpRefreshControlDelegate {
    public func beginRefreshing() {
        delegate?.handleLoadMore()
//        if tuiView.currentVideoIndex == (feeds.count - 1) {
//            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
//                self.safeScroll(to: self.tuiView.currentVideoIndex, animated: true)
//            }
//        }
    }
    
    public func endRefreshing() {}
    
    public func scrollViewDidScrollContentOffsetY(_ y: CGFloat) {
        delegate?.handleLoadMore()
        
        let message = "Pull up in last index, current index: \(tuiView.currentVideoIndex), total data: \(tuiView.videos.count), isRefreshing: \(pullUpRefreshControll.isRefreshing)"
        KKLogFile.instance.log(label: "HotnewsView - scrollViewDidScrollContentOffsetY", message: message)
        print("PE-12388 - scrollViewDidScrollContentOffsetY", message)
        
        if !pullUpRefreshControll.isRefreshing  {
            pullUpRefreshControll.beginRefreshing()
            KKLogFile.instance.log(label: "HotnewsView - scrollViewDidScrollContentOffsetY", message: "Begin pull up refresh")
            print("PE-12388 - scrollViewDidScrollContentOffsetY", "Begin pull up refresh")
        }
    }
}

extension HotNewsView: TUIShortVideoViewCustomCallbackDelegate {
    public func customCallbackEvent(_ info: Any) {
        guard let event = info as? HotNewsCellEvent else { return }
        
        switch event {
        case .onPlay:
            checkPlayer()
        case .profile(let feed):
            eventDelegate?.profile(feed: feed)
        case .like(let feed):
            eventDelegate?.like(feed: feed)
        case .share(let feed):
            disablePlay = true
            eventDelegate?.share(feed: feed)
        case .follow(let feed):
            eventDelegate?.follow(feed: feed)
        case .comment(let feed):
            disablePlay = true
            eventDelegate?.comment(feed: feed)
        case .productDetail(let feed):
            eventDelegate?.productDetail(feed: feed)
        case .donationDetail(let feed):
            eventDelegate?.donationDetail(feed: feed)
        case .shortcutStartPaidDM(let feed):
            eventDelegate?.shortcutStartPaidDM(feed: feed)
        case let .hashtag(feed, value):
            eventDelegate?.hashtag(feed: feed, value: value)
        case .donationFilterCategory(let feed):
            eventDelegate?.donationFilterCategory(feed: feed)
        case let .mention(feed, value):
            eventDelegate?.mention(feed: feed, value: value)
        case let .playPause(feed, isPlay):
            eventDelegate?.playPause(feed: feed, isPlay: isPlay)
        case let .newsPortal(feed, url):
            eventDelegate?.newsPortal(feed: feed, url: url)
        case .shortcutLiveStreaming(let feed):
            eventDelegate?.shortcutLiveStreaming(feed: feed)
        case .floatingLink(let feed):
            eventDelegate?.floatingLink(feed: feed)
        case .contentSetting(let feed):
            eventDelegate?.contentSetting(feed: feed)
        case .bookmark(let feed):
            eventDelegate?.bookmark(feed: feed)
        case .donationCart(let feed):
            eventDelegate?.donationCart(feed: feed)
        case .donateStuff(let feed):
            eventDelegate?.donateStuff(feed: feed)
        }
    }
}

// MARK: - Story
private extension HotNewsView {
    private func setupStoryView(type: FeedType) {
        guard type == .following else { return }
        
        addSubviews([storyOverlayView, storyView])
        
        storyView.anchors.leading.equal(anchors.leading)
        storyView.anchors.trailing.equal(anchors.trailing)
        storyView.anchors.top.equal(anchors.top)
        storyView.anchors.height.equal(storyView.height)
        
        storyOverlayView.anchors.leading.equal(anchors.leading)
        storyOverlayView.anchors.trailing.equal(anchors.trailing)
        storyOverlayView.anchors.top.equal(storyView.anchors.bottom)
        storyOverlayView.anchors.bottom.equal(anchors.bottom)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleStoryOverlayView))
        storyOverlayView.addGestureRecognizer(tapGesture)
        
        let swipeDirections: [UISwipeGestureRecognizer.Direction] = [.up, .down, .left, .right]
        for direction in swipeDirections {
            let swipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(handleStoryOverlayView))
            swipeGesture.direction = direction
            storyOverlayView.addGestureRecognizer(swipeGesture)
        }
        
    }
    
    @objc private func handleStoryOverlayView() {
        handleCollapseStoryView()
        delegate?.refreshStory()
    }
    
    private func handleCollapseStoryView() {
        storyView.collapse()
    }
}

public extension TUI_Enum_Type_RenderMode {
    var stringValue: String {
        switch self {
        case .RENDER_MODE_FILL_EDGE: return "RENDER_MODE_FILL_EDGE"
        case .RENDER_MODE_FILL_SCREEN: return "RENDER_MODE_FILL_SCREEN"
        @unknown default: return "UNKNOWN"
        }
    }
}

