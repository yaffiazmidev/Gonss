//
//  HotRoomView.swift
//  FeedCleeps
//
//  Created by Administer on 2024/7/4.
//

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


public class HotRoomView: UIView, IHotView {
    
    var disablePlay: Bool = false
    var isAppear = false {
        didSet {
            disablePlay = !isAppear
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
    
    weak var delegate: HotNewsDelegate?
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
//        lincenceConfig()
        let nib = UINib(nibName: "HotNewsView", bundle: Bundle.init(identifier: "com.koanba.kipaskipas.mobile.FeedCleeps"))
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
        isValidTUILicense()
    
        let uiManager = TUIPlayerShortVideoUIManager()
        uiManager.setControlViewClass(cell)
        uiManager.setBackgroundView(UIView())
        uiManager.setVideoPlaceholderImage(UIImage())
        uiManager.setLoading(HotNewsLoadingView())
        
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

        if window == nil { // this view dettached
            tuiView.pause()
            return
        }
        
        if delegate?.isOnTopController() == false { // this view/controller is not on top/visible for user
            tuiView.pause()
            return
        }
        
        if disablePlay { // disable play
            tuiView.pause()
            return
        }
        
        if UIApplication.shared.applicationState == .background {
            if(tuiView.isPlaying){
                tuiView.pause()
                return
            }
        }
    }
    
    @objc private func handleRefresh() {
        delegate?.pullToRefresh()
    }
}

extension HotRoomView: TXLiveBaseDelegate {
    public func onLicenceLoaded(_ result: Int32, reason: String) {
        //setResolution(isFast: true)
        print("Hotnews License TUI: \(reason)")
        KKLogFile.instance.log(label:"Hotnews", message: "License TUI: \(reason)")
        
        //configTUI(speedInKb: 11_000_000)
        delegate?.handleOnLicenceLoaded(result, reason: reason)
        tuiView.stopLoading()
    }
}

extension HotRoomView: TUIShortVideoViewDelegate {
    public func videoPreLoadState(with videoModel: TUIPlayerVideoModel) {
        //print("**** HotNewsController  videoPreLoadState \(videoModel.videoUrl)")
        
        if(videoModel.videoUrl.lowercased().contains(".m3u8") || videoModel.videoUrl.lowercased().contains(".mp4")){
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
        }
    }
    
    public func currentVideo(_ videoModel: TUIPlayerVideoModel, statusChanged status: TUITXVodPlayerStatus) {
                
        if(videoModel.videoUrl.lowercased().contains(".mp4") || videoModel.videoUrl.lowercased().contains(".m3u8")){
            let videoId = KKVideoId().getId(urlString: videoModel.videoUrl)
            //print("**** videoModel.videoUrl", videoModel.videoUrl)
            switch status {
                case .paused:
                    break
                case .ended:
                    break
                case .unload:
                    break
                case .prepared:
//                delegate?.showPlayingType()
                    break
                case .loading:
                    break
                case .playing:
                    if UIApplication.shared.applicationState == .background {
                        tuiView.pause()
                        return
                    }
                delegate?.showPlayingType()
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
                
                if(netSpeedInt > 0) {
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

    }
    
    public func scroll(toVideoIndex videoIndex: Int, videoModel: TUIPlayerDataModel) {
                
        guard delegate?.getFeeds().count ?? 0 > 0 else {
            return
        }
        
        guard let feed = videoModel as? FeedItem else {
            return
        }
        
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
            let logTrendingAt = "feed.id:\(feed.id ?? "") - trendingAt: \(feed.trendingAt ?? 0) , Level: \(feed.post?.levelPriority ?? 0)"
            
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
        self.delegate?.handleLoadMore()

    }
}

extension HotRoomView: TUIPullUpRefreshControlDelegate {
    public func beginRefreshing() {
        delegate?.handleLoadMore()
    }
    
    public func endRefreshing() {}
    
    public func scrollViewDidScrollContentOffsetY(_ y: CGFloat) {
        delegate?.handleLoadMore()
        
        let message = "Pull up in last index, current index: \(tuiView.currentVideoIndex), total data: \(tuiView.videos.count), isRefreshing: \(pullUpRefreshControll.isRefreshing)"
        KKLogFile.instance.log(label: "HotRoomView - scrollViewDidScrollContentOffsetY", message: message)
        print("PE-12388 - scrollViewDidScrollContentOffsetY", message)
        
        if !pullUpRefreshControll.isRefreshing  {
            pullUpRefreshControll.beginRefreshing()
            KKLogFile.instance.log(label: "HotRoomView - scrollViewDidScrollContentOffsetY", message: "Begin pull up refresh")
            print("PE-12388 - scrollViewDidScrollContentOffsetY", "Begin pull up refresh")
        }
    }
}

extension HotRoomView: TUIShortVideoViewCustomCallbackDelegate {
    public func customCallbackEvent(_ info: Any) {
        guard let event = info as? HotNewsCellEvent else { return }
        
        switch event {
        case .onPlay:
            break
        case .profile(let feed):
            eventDelegate?.profile(feed: feed)
        case .like(let feed):
            eventDelegate?.like(feed: feed)
        case .share(let feed):
            disablePlay = true
            checkPlayer()
            eventDelegate?.share(feed: feed)
        case .follow(let feed):
            eventDelegate?.follow(feed: feed)
        case .comment(let feed):
            disablePlay = true
            checkPlayer()
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

