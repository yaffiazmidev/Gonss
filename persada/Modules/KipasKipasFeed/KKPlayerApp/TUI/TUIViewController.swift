//
//  TUIViewController.swift
//  KKPlayerApp
//
//  Created by Rahmat Trinanda Pramudya Amar on 22/09/23.
//

import UIKit
import TUIPlayerShortVideo
import TUIPlayerCore
import TXLiteAVSDK_Professional

class TUIViewController: UIViewController {
    
    lazy var videoView: HotNewsVideoView = {
        let view = HotNewsVideoView()
        view.frame = self.view.bounds
        view.delegate = self
        // view.setPlaymode(.listLoop) /// 单个视频循环播放&列表循环播放
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let model = TUIPlayerStrategyModel()
        model.mPreloadConcurrentCount = 1
        model.mPreloadBufferSizeInMB = 0.5
        videoView.setShortVideoStrategyModel(model)
        
        view.addSubview(videoView)
        videoView.startLoading()
        videoView.fillSuperview()
        
        let licence = TUIPlayerAuth.licenceInfo()
        if !licence.isEmpty {
            setVideos()
        } else {
            lincenceConfig()
        }
    }
}

extension TUIViewController {
    func setVideos() {
        var models: [TUIPlayerVideoModel] = []
        AppConfig.shared.data.forEach { s in
            var model = TUIPlayerVideoModel()
            model.videoUrl = s
            models.append(model)
        }
        videoView.setShortVideoModels(models)
    }
    
    func lincenceConfig() {
        let config = TUIPlayerConfig()
        config.enableLog = true
//        config.licenseUrl = "https://license.vod-control.com/license/v2/1316940742_1/v_cube.license"
//        config.licenseKey = "7e83f0cac294d0b9f53a23c96b36c388"
        TUIPlayerCore.shareInstance().setPlayerConfig(config)
//        TUIPlayerAuth.shareInstance().delegate = self
        
        TXLiveBase.setLicenceURL("https://license.vod-control.com/license/v2/1316940742_1/v_cube.license", key: "7e83f0cac294d0b9f53a23c96b36c388")
        TXLiveBase.sharedInstance().delegate = self
    }
}

extension TUIViewController: TXLiveBaseDelegate {
    func onLicenceLoaded(_ result: Int32, reason: String) {
        if result == 0 {
            DispatchQueue.main.async {
                self.setVideos()
            }
        }
    }
}


extension TUIViewController: TUIShortVideoViewDelegate {
    func scroll(toVideoIndex videoIndex: Int, videoModel: TUIPlayerVideoModel) {
        
    }
    
    func currentVideo(_ videoModel: TUIPlayerVideoModel, statusChanged status: TUITXVodPlayerStatus) {
        
    }
    
    func currentVideo(_ videoModel: TUIPlayerVideoModel, currentTime: Float, totalTime: Float, progress: Float) {
        
    }
    
    func onNetStatus(_ videoModel: TUIPlayerVideoModel, withParam param: [AnyHashable : Any]) {
        
    }
    
    func videoPreLoadState(with videoModel: TUIPlayerVideoModel) {
        
    }
    
    func onReachLast() {
        //paging
    }
}
