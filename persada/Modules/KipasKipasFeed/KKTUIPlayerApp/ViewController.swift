//
//  ViewController.swift
//  KKTUIPlayerApp
//
//  Created by Rahmat Trinanda Pramudya Amar on 24/09/23.
//

import UIKit
import TUIPlayerCore
import TUIPlayerShortVideo

class ViewController: UIViewController {
    
//    private lazy var tuiView: TUIShortVideoView = {
//        let view = TUIShortVideoView()
//        view.frame = self.view.bounds
//        view.delegate = self
//        view.backgroundColor = .black
//        // view.setPlaymode(.listLoop) /// 单个视频循环播放&列表循环播放
//        return view
//    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        setupTUIView()
//        setTUIVideos(with: [
//            "https://1316940742.vod2.myqcloud.com/ae9df7c5vodtranssgp1316940742/fe9db4be5576678021425411126/adp.1449774.m3u8",
//            "https://1316940742.vod2.myqcloud.com/bd86ecc4vodtransjkt1316940742/ad7c3a2f5576678021424289275/adp.1449774.m3u8"
//        ])
    }
    @IBAction func didClickToDonationPageButton(_ sender: Any) {
        let vc = makeHotNewsController(feedType: .donation)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func didClickToHotNewsPageButton(_ sender: Any) {
        let vc = makeHotNewsController(feedType: .hotNews)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    private func makeHotNewsController(feedType: FeedType) -> HotNewsViewController {
        let loader = RemoteFeedLoader()
        let viewModel = HotNewsViewModel(loader: loader)
        let controller = HotNewsViewController(viewModel: viewModel, feedType: feedType)
        viewModel.delegate = controller
        return controller
    }
}


//extension ViewController {
//    private func setupTUIView() {
//        let model = TUIPlayerStrategyModel()
//        model.mPreloadConcurrentCount = 1
//        model.mPreloadBufferSizeInMB = 0.5
//        model.mPreferredResolution = 1080 * 1920
//        tuiView.setShortVideoStrategyModel(model)
//        
//        let licence = TUIPlayerAuth.licenceInfo()
//        if !licence.isEmpty {
//            setTUIVideos(with: [])
//        } else {
//            lincenceConfig()
//        }
//        
//        view.addSubview(tuiView)
//        tuiView.startLoading()
//        tuiView.fillSuperview()
//    }
//    
//    //    func setTUIVideos(with data: [Feed]) {
//    func setTUIVideos(with data: [String]) {
//        var models: [TUIPlayerVideoModel] = []
//        //                data.forEach { feed in
//        //                    if let media = feed.post?.medias?.first, let videoUrl = media.vodUrl {
//        //                        let model = TUIPlayerVideoModel()
//        //                        model.videoUrl = videoUrl
//        //                        model.coverPictureUrl = media.thumbnail?.large ?? ""
//        //                        model.duration = "\(media.metadata?.duration ?? 0)"
//        //                        models.append(model)
//        //                    }
//        //                }
//        data.forEach { url in
//            let model = TUIPlayerVideoModel()
//            model.videoUrl = url
//            models.append(model)
//        }
//        
//        print("TUIPlayerApp", "2594", data.count, models.count)
//        tuiView.appendShortVideoModels(models)
//        print("TUIPlayerApp", "totalVideos", tuiView.videos.count)
//    }
//    
//    func lincenceConfig() {
//        let config = TUIPlayerConfig()
//        config.enableLog = true
//        config.licenseUrl = "https://license.vod-control.com/license/v2/1316940742_1/v_cube.license"
//        config.licenseKey = "7e83f0cac294d0b9f53a23c96b36c388"
//        TUIPlayerCore.shareInstance().setPlayerConfig(config)
//        TUIPlayerAuth.shareInstance().delegate = self
//    }
//}
//
//extension ViewController: TUIPlayerAuthDelegate {
//    public func onLicenceLoaded(_ result: Int32, reason: String) {
//        if result == 0 {
//            DispatchQueue.main.async {
//                self.setTUIVideos(with: [])
//            }
//        }
//    }
//}
//
//
//extension ViewController: TUIShortVideoViewDelegate {
//    func currentVideo(_ videoModel: TUIPlayerVideoModel, statusChanged status: TUITXVodPlayerStatus) {
//        
//    }
//    
//    func currentVideo(_ videoModel: TUIPlayerVideoModel, currentTime: Float, totalTime: Float, progress: Float) {
//        
//    }
//    
//    func onNetStatus(_ videoModel: TUIPlayerVideoModel, withParam param: [AnyHashable : Any]) {
//        
//    }
//    
//    func scroll(toVideoIndex videoIndex: Int, videoModel: TUIPlayerVideoModel) {
//        
//    }
//    
//    public func onReachLast() {
//        //paging
//    }
//}
