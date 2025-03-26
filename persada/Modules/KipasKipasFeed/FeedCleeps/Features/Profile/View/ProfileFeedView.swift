//
//  ProfileFeedView.swift
//  FeedCleeps
//
//  Created by DENAZMI on 01/11/23.
//

import TUIPlayerCore
import TUIPlayerShortVideo
import KipasKipasShared
import TXLiteAVSDK_Professional

protocol ProfileFeedViewDelegate: AnyObject {
    func pullToRefresh()
    func handleOnLicenceLoaded(_ result: Int32, reason: String)
    func handleLoadMore()
}

public class ProfileFeedView: UIView {
        
    lazy var refreshControl: UIRefreshControl = {
        let view = UIRefreshControl()
        view.tintColor = .red
        view.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        return view
    }()
    
    public lazy var tuiView: HotNewsVideoView = {
        let uiManager = TUIPlayerShortVideoUIManager()
        uiManager.setControlViewClass(ProfileFeedViewCell.self)
        uiManager.setBackgroundView(UIView())
        uiManager.setVideoPlaceholderImage(UIImage())
        let view = HotNewsVideoView(uiManager: uiManager)
        view.delegate = self
        view.backgroundColor = .black
        view.refreshControl = refreshControl
        view.isAutoPlay = true
        return view
    }()
    
    weak var delegate: ProfileFeedViewDelegate?
    public var feeds: [FeedItem] = []
    
    var isAppear = false
    var lastBufferInMB = 0.0
    let LOG_ID = ""
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
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
    
    let labelRetry = UILabel(frame: CGRect(x: 100, y: 550,
                                           width: 200, height: 50))
    
    let buttonRetry = UIButton(frame: CGRect(x: 100, y: 600,
                                             width: 200, height: 50))

    var loadingView: UIActivityIndicatorView?

    var lastNetSpeedInt = 0
    
    func showStateEmpty(label: String){
        
        if !tuiView.subviews.contains(labelRetry) {
            tuiView.addSubview(labelRetry)
        }
        
        if !tuiView.subviews.contains(buttonRetry) {
            tuiView.addSubview(buttonRetry)
        }

        
        buttonRetry.isHidden = false
        labelRetry.isHidden = false
        
        labelRetry.text = label
        labelRetry.textAlignment = .center
        labelRetry.textColor = .white
        
        buttonRetry.setTitle("Retry", for: .normal)
        buttonRetry.setTitleColor(.white, for: .normal)
        buttonRetry.backgroundColor = .red

        buttonRetry.addTarget(self, action: #selector(handleRefresh), for: .touchUpInside)
    }
    
    func hideState(){
        buttonRetry.isHidden = true
        labelRetry.isHidden = true
    }
    
    func showLoading() {
         
        if loadingView == nil {
            loadingView = UIActivityIndicatorView(style: .large)
        }
        
        if !tuiView.subviews.contains(loadingView!) {
            loadingView?.center = tuiView.center
            tuiView.addSubview(loadingView!)
        }

        loadingView?.isHidden = false
        loadingView?.startAnimating()
    }

    func hideLoading(){
        if (loadingView != nil){
            loadingView?.stopAnimating()
            loadingView?.isHidden = true
        }
    }

    
    func setupTUIView() {
        let licence = TXLiveBase.getLicenceInfo()
        
        if licence.isEmpty {
            lincenceConfig()
        }
        
        addSubview(tuiView)
        
        let screenWidth  = UIScreen.main.bounds.width
        let screenHeight = UIScreen.main.bounds.height
        
        tuiView.frame = CGRectMake(0, 0, screenWidth, screenHeight)
        tuiView.startLoading()
    }
    
    func setupRefreshControl() {
        tuiView.tableView()?.bounces = false
    }
    
    private func lincenceConfig() {
        let config = TUIPlayerConfig()
        config.enableLog = false
//        config.licenseUrl = "https://license.vod-control.com/license/v2/1316940742_1/v_cube.license"
//        config.licenseKey = "7e83f0cac294d0b9f53a23c96b36c388"
        TUIPlayerCore.shareInstance().setPlayerConfig(config)
//        TUIPlayerAuth.shareInstance().delegate = self
        
        TXLiveBase.setLicenceURL("https://license.vod-control.com/license/v2/1316940742_1/v_cube.license", key: "7e83f0cac294d0b9f53a23c96b36c388")
        TXLiveBase.sharedInstance().delegate = self
    }
    
    func setResolution(isFast: Bool) {
        let model = TUIPlayerVodStrategyModel()
        model.mRenderMode = .RENDER_MODE_FILL_SCREEN
        model.enableAutoBitrate = false
//        model.mIsPreVideoResume = true
        model.mResumeModel = .RESUM_MODEL_NONE

        model.mPreloadConcurrentCount = 3
        model.mPreloadBufferSizeInMB = 0.8
        model.mPreferredResolution = 1080 * 1920

        tuiView.setShortVideoStrategyModel(model)
    }
    
    func configTUI(speedInKb: Int){
                
        let model = TUIPlayerVodStrategyModel()
        model.mRenderMode = .RENDER_MODE_FILL_SCREEN
        model.enableAutoBitrate = false
        model.mResumeModel = .RESUM_MODEL_NONE

        
//        let SPEED_10_M = 1250
//        let SPEED_5_M = 625
        let SPEED_8_M = 8_000
        let SPEED_5_M = 5_000

        
        if(speedInKb < 1){
            //return
        }
                
        //middle
        var preloadCount = 3
        var bufferInMB = 0.5
        var resolution = 720 * 1280

        var resolutionLevel = "MED"
        
        
        if(speedInKb > SPEED_8_M){
            // high
            resolutionLevel = "HIGH"
            //preloadCount = 5
            bufferInMB = 0.8
            resolution = 1080 * 1920
        } else if(speedInKb < SPEED_5_M){
            // low
            resolutionLevel = "LOW"
            preloadCount = 2
            //bufferInMB = 0.3
            resolution = 480 * 852
        }
        
        //print(self.LOG_ID, "configTUI", "bufferInMB : \(bufferInMB)     speedInKb:\(speedInKb)")
        
        if lastBufferInMB == bufferInMB {
            return
        }
        self.lastBufferInMB = bufferInMB
        
        print(self.LOG_ID, "configTUI", "Change to \(resolutionLevel), Speed: \(speedInKb)")
        KKLogFile.instance.log(label:"configTUI", message: "Change to \(resolutionLevel), Speed: \(speedInKb)")

        model.mPreloadConcurrentCount = preloadCount
        model.mPreloadBufferSizeInMB = Float(bufferInMB)
        model.mPreferredResolution = resolution
        
        
        self.tuiView.setShortVideoStrategyModel(model)

    }

    
    @objc private func handleRefresh() {
        delegate?.pullToRefresh()
    }
}

extension ProfileFeedView: TXLiveBaseDelegate {
    public func onLicenceLoaded(_ result: Int32, reason: String) {
        //setResolution(isFast: true)
        print("Hotnews License TUI: \(reason)")
        KKLogFile.instance.log(label:"Hotnews", message: "License TUI: \(reason)")
        
        configTUI(speedInKb: 11_000_000)
        delegate?.handleOnLicenceLoaded(result, reason: reason)
    }
}

extension ProfileFeedView: TUIShortVideoViewDelegate {
    public func videoPreLoadState(with videoModel: TUIPlayerVideoModel) {
        //print("**** HotNewsController  videoPreLoadState \(videoModel.videoUrl)")
        
        if(videoModel.videoUrl.lowercased().contains(".m3u8") || videoModel.videoUrl.lowercased().contains(".mp4")){
            
            print("Preload \(KKVideoId().getId(urlString: videoModel.videoUrl))")
            //KKLogFile.instance.log(label:"Preload", message: "\(KKVideoId().getId(urlString: videoModel.videoUrl ))")
        }
    }
    
    public func currentVideo(_ videoModel: TUIPlayerVideoModel, statusChanged status: TUITXVodPlayerStatus) {
        
        if(videoModel.videoUrl.lowercased().contains(".mp4") || videoModel.videoUrl.lowercased().contains(".m3u8")){
            let videoId = KKVideoId().getId(urlString: videoModel.videoUrl)
            
            switch status {
                case .unload:
                    print("currentVideo \(videoId) status: unload")
                    KKLogFile.instance.log(label:"currentVideo \(videoId)", message: "status: unload")
                case .prepared:
                    print("currentVideo \(videoId) status: prepared")
                    KKLogFile.instance.log(label:"currentVideo \(videoId)", message: "status: prepared")
                case .loading:
                    print("currentVideo \(videoId) status: loading")
                    KKLogFile.instance.log(label:"currentVideo \(videoId)", message: "status: loading")
                case .playing:
                    print("currentVideo \(videoId) status: playing")
                    KKLogFile.instance.log(label:"currentVideo \(videoId)", message: "status: playing")
                case .error:
                    print("currentVideo \(videoId) status: ERROR")
                    KKLogFile.instance.log(label:"currentVideo \(videoId)", message: "status: ERROR", level: .error)
                default:
                    print("currentVideo \(videoId) status: \(status)")
            }
            
            if(self.isAppear){
               if(status == .prepared && !tuiView.isPlaying ){
                    tuiView.resume()
                }
            }
        }
    }
    
    public func currentVideo(_ videoModel: TUIPlayerVideoModel, currentTime: Float, totalTime: Float, progress: Float) {
        if !isAppear {
            tuiView.pause()
        } else {
            if(videoModel.videoUrl.lowercased().contains(".mp4") || videoModel.videoUrl.lowercased().contains(".m3u8")){
                let videoId = KKVideoId().getId(urlString: videoModel.videoUrl)

                print("currentVideo \(videoId) status: ERROR")
                KKLogFile.instance.log(label:"currentVideo \(videoId)", message: "status: ERROR", level: .error)
            }
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
                let speedAvg = (lastNetSpeedInt + netSpeedInt) / 2
                self.lastNetSpeedInt = netSpeedInt
                self.configTUI(speedInKb: speedAvg * 8)
            }
        }
    }
    
    public func scroll(toVideoIndex videoIndex: Int, videoModel: TUIPlayerDataModel) {
        guard feeds.count > 0 else {
            return
        }
        
        guard let feed = videoModel as? FeedItem else {
            return
        }
        
        if(videoIndex > 0){
            if(videoIndex % 2 == 0){
                self.configTUI(speedInKb: lastNetSpeedInt)
            }
        }
    }
    
    public func onReachLast() {
        delegate?.handleLoadMore()
    }
}

