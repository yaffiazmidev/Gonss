//
//  HotNewsView.swift
//  KKTUIPlayerApp
//
//  Created by DENAZMI on 27/09/23.
//

import UIKit
import TUIPlayerCore
import TUIPlayerShortVideo
import TXLiteAVSDK_Professional

protocol HotNewsViewDelegate: AnyObject {
    func pullToRefresh()
    func handleOnLicenceLoaded(_ result: Int32, reason: String)
    func handleSetTUIVideos()
    func handleLoadMore()
}

class HotNewsView: UIView {
        
    @IBOutlet weak var containerView: UIView!
    
    lazy var kkRefreshControl: UIRefreshControl = {
        let view = UIRefreshControl()
        view.tintColor = .red
        view.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        return view
    }()
    
    lazy var tuiView: TUIShortVideoView = {
        let view = TUIShortVideoView()
        view.delegate = self
        view.backgroundColor = .black
        view.refreshControl = kkRefreshControl
        return view
    }()
    
    weak var delegate: HotNewsViewDelegate?

    override init(frame: CGRect) {
        super.init(frame: frame)
        loadViewFromNib()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupTUIView(cell: TUIPlayerShortVideoControl.Type) {
        let licence = TUIPlayerAuth.licenceInfo()
        
        if licence.isEmpty {
            lincenceConfig()
        } else {
            delegate?.handleSetTUIVideos()
        }
        
        TUIPlayerShortVideoUIManager.shared().setControlViewClass(cell)
        
        containerView.addSubview(tuiView)
        tuiView.onTap { [weak self] in
            guard let self = self else { return }
            
            self.tuiView.isPlaying ? self.tuiView.pause() : self.tuiView.resume()
        }
        tuiView.fillSuperview()
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
    
    func setResolution(isFast: Bool) {
        let model = TUIPlayerStrategyModel()
        model.mRenderMode = .RENDER_MODE_FILL_SCREEN
//        model.enableAutoBitrate = false
        model.mIsPreVideoResume = true
        
        model.mPreloadConcurrentCount = isFast ? 4 : 2
        model.mPreloadBufferSizeInMB = isFast ? 0.5 : 0.5
        model.mPreferredResolution = isFast ? 1080 * 1920 : 720 * 1280
        
        tuiView.setShortVideoStrategyModel(model)
    }
    
    @objc private func handleRefresh() {
        delegate?.pullToRefresh()
    }
}

extension HotNewsView: TUIPlayerAuthDelegate {
    public func onLicenceLoaded(_ result: Int32, reason: String) {
        delegate?.handleOnLicenceLoaded(result, reason: reason)
    }
}

extension HotNewsView: TUIShortVideoViewDelegate {
    func currentVideo(_ videoModel: TUIPlayerVideoModel, statusChanged status: TUITXVodPlayerStatus) {
        print("currentVideo")
    }
    
    func currentVideo(_ videoModel: TUIPlayerVideoModel, currentTime: Float, totalTime: Float, progress: Float) {
        print("currentVideo")
    }
    
    func onNetStatus(_ videoModel: TUIPlayerVideoModel, withParam param: [AnyHashable : Any]) {
        print("onNetStatus")
    }
    
    func scroll(toVideoIndex videoIndex: Int, videoModel: TUIPlayerVideoModel) {
        print("scroll")
    }
    
    public func onReachLast() {
        delegate?.handleLoadMore()
    }
}
