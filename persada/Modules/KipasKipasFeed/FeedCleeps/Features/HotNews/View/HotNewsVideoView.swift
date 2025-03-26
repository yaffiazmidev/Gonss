//
//  HotNewsVideoView.swift
//  FeedCleeps
//
//  Created by Administer on 2024/5/28.
//

import UIKit
import TUIPlayerShortVideo

public class HotNewsVideoView: TUIShortVideoView {
    lazy var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm:ss.SSS"
        return dateFormatter
    }()
    
    public override init(uiManager uimanager: TUIPlayerShortVideoUIManager) {
        super.init(uiManager: uimanager)
        printA("xjj HotNewsVideoView iM \(self)")
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        printA("xjj HotNewsVideoView iF \(self)")
    }
    
    deinit {
        printA("xjj HotNewsVideoView deinit \(self)")
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func pause() {
        if let fe = currentVideoModel as? FeedItem {
            let address = Unmanaged.passUnretained(self).toOpaque()
            printB("feURL \(address) pause = \(fe.videoUrl)")
        }
        super.pause()

        printA("xjj HotNewsVideoView pause\(self)")
    }
    
    public override func resume() {
        if let fe = currentVideoModel as? FeedItem {
            let address = Unmanaged.passUnretained(self).toOpaque()
            printB("feURL \(address) resume = \(fe.videoUrl)")
        }
        super.resume()
        printA("xjj HotNewsVideoView resume\(self)")
    }
    
    public override func removeAllVideoModels() {
        let address = Unmanaged.passUnretained(self).toOpaque()
        printB("feURL \(address) removeAllVideoModels")
        super.removeAllVideoModels()
        printA("xjj HotNewsVideoView removeAllVideoModels\(self)")
    }
    
    public override func destoryPlayer() {
        super.destoryPlayer()
        printA("xjj HotNewsVideoView destoryPlayer\(self)")
    }
    
    public override func startLoading() {
        if let fe = currentVideoModel as? FeedItem {
            let address = Unmanaged.passUnretained(self).toOpaque()
            printB("feURL \(address) startLoading = \(fe.videoUrl)")
        }
        super.startLoading()
        printA("xjj HotNewsVideoView startLoading\(self)")
    }
    
    public override func stopLoading() {
        if let fe = currentVideoModel as? FeedItem {
            let address = Unmanaged.passUnretained(self).toOpaque()
            printB("feURL \(address) stopLoading = \(fe.videoUrl)")
        }
        super.stopLoading()
        printA("xjj HotNewsVideoView stopLoading\(self)")
    }
    
    public override func pausePreload() {
        if let fe = currentVideoModel as? FeedItem {
            let address = Unmanaged.passUnretained(self).toOpaque()
            printB("feURL \(address) pausePreload = \(fe.videoUrl)")
        }
        super.pausePreload()
        printA("xjj HotNewsVideoView pausePreload\(self)")
    }
    
    public override func resumePreload() {
        if let fe = currentVideoModel as? FeedItem {
            let address = Unmanaged.passUnretained(self).toOpaque()
            printB("feURL \(address) resumePreload = \(fe.videoUrl)")
        }
        super.resumePreload()
        printA("xjj HotNewsVideoView resumePreload\(self)")
    }
    
    public override func setShortVideoStrategyModel(_ model: TUIPlayerVodStrategyModel) {
        super.setShortVideoStrategyModel(model)
        printA("xjj HotNewsVideoView setShortVideoStrategyModel\(self)")
    }
    
    public override func setShortVideoLiveStrategyModel(_ model: TUIPlayerLiveStrategyModel) {
        super.setShortVideoLiveStrategyModel(model)
        printA("xjj HotNewsVideoView setShortVideoLiveStrategyModel\(self)")
    }
    
    public override func setShortVideoModels(_ list: [TUIPlayerDataModel]) {
        for (index, item) in list.enumerated() {
            if let fe = item as? FeedItem {
                let address = Unmanaged.passUnretained(self).toOpaque()
                print("feURL \(address) = \(fe.videoUrl)")
            }
        }
        super.setShortVideoModels(list)
        return
//        var urls = ["http://ie-mps-1258344699.cos.ap-nanjing.myqcloud.com/common/paddyyuan/kipas/0710/h264/eq=brightness=0.03:contrast=1.2:saturation=1.2_h264_1080_kxAE14XiY7YA.mp4",
//        "http://ie-mps-1258344699.cos.ap-nanjing.myqcloud.com/common/paddyyuan/kipas/0710/h264/eq=brightness=0.03:contrast=1.2:saturation=1.2_h264_1080_4tjBhR0IMTAA.mp4",
//        "http://ie-mps-1258344699.cos.ap-nanjing.myqcloud.com/common/paddyyuan/kipas/0710/h264/eq=brightness=0.03:contrast=1.2:saturation=1.2_h264_1080_pea4Xavv0ooA.mp4",
//        "http://ie-mps-1258344699.cos.ap-nanjing.myqcloud.com/common/paddyyuan/kipas/0710/h264/eq=brightness=0.03:contrast=1.2:saturation=1.2_h264_1080_6jSfEBnmX2AA.mp4",
//        "http://ie-mps-1258344699.cos.ap-nanjing.myqcloud.com/common/paddyyuan/kipas/0710/h264/eq=brightness=0.03:contrast=1.2:saturation=1.2_h264_1080_bAuna7eIockA.mp4",
//        "http://ie-mps-1258344699.cos.ap-nanjing.myqcloud.com/common/paddyyuan/kipas/0710/h264/eq=brightness=0.03:contrast=1.2:saturation=1.2_h264_1080_bua4VZbztr8A.mp4",
//        "http://ie-mps-1258344699.cos.ap-nanjing.myqcloud.com/common/paddyyuan/kipas/0710/h264/eq=brightness=0.03:contrast=1.2:saturation=1.2_h264_1080_vJfoe2nfnOMA.mp4",
//        "http://ie-mps-1258344699.cos.ap-nanjing.myqcloud.com/common/paddyyuan/kipas/0710/h264/eq=brightness=0.03:contrast=1.2:saturation=1.2_h264_1080_J5B9HxA7Kz8A.mp4",
//        "http://ie-mps-1258344699.cos.ap-nanjing.myqcloud.com/common/paddyyuan/kipas/0710/h264/eq=brightness=0.03:contrast=1.2:saturation=1.2_h264_1080_rmunFHYAcY4A.mp4",
//        "http://ie-mps-1258344699.cos.ap-nanjing.myqcloud.com/common/paddyyuan/kipas/0710/h264/eq=brightness=0.03:contrast=1.2:saturation=1.2_h264_1080_aF8zuPYb84IA.mp4",
//        "http://ie-mps-1258344699.cos.ap-nanjing.myqcloud.com/common/paddyyuan/kipas/0710/h264/eq=brightness=0.03:contrast=1.2:saturation=1.2_h264_1080_i2agVec2F70A.mp4",
//        "http://ie-mps-1258344699.cos.ap-nanjing.myqcloud.com/common/paddyyuan/kipas/0710/h264/eq=brightness=0.03:contrast=1.2:saturation=1.2_h264_1080_MNZoVgt89uwA.mp4"]
//        
//        
//        urls = ["http://ie-mps-1258344699.cos.ap-nanjing.myqcloud.com/common/paddyyuan/kipas/0710/h264/eq=brightness=0.02:contrast=1.2:saturation=1.5_h264_1080_kxAE14XiY7YA.mp4",
//               "http://ie-mps-1258344699.cos.ap-nanjing.myqcloud.com/common/paddyyuan/kipas/0710/h264/eq=brightness=0.02:contrast=1.2:saturation=1.5_h264_1080_4tjBhR0IMTAA.mp4",
//               "http://ie-mps-1258344699.cos.ap-nanjing.myqcloud.com/common/paddyyuan/kipas/0710/h264/eq=brightness=0.02:contrast=1.2:saturation=1.5_h264_1080_pea4Xavv0ooA.mp4",
//               "http://ie-mps-1258344699.cos.ap-nanjing.myqcloud.com/common/paddyyuan/kipas/0710/h264/eq=brightness=0.02:contrast=1.2:saturation=1.5_h264_1080_6jSfEBnmX2AA.mp4",
//               "http://ie-mps-1258344699.cos.ap-nanjing.myqcloud.com/common/paddyyuan/kipas/0710/h264/eq=brightness=0.02:contrast=1.2:saturation=1.5_h264_1080_bAuna7eIockA.mp4",
//               "http://ie-mps-1258344699.cos.ap-nanjing.myqcloud.com/common/paddyyuan/kipas/0710/h264/eq=brightness=0.02:contrast=1.2:saturation=1.5_h264_1080_bua4VZbztr8A.mp4",
//               "http://ie-mps-1258344699.cos.ap-nanjing.myqcloud.com/common/paddyyuan/kipas/0710/h264/eq=brightness=0.02:contrast=1.2:saturation=1.5_h264_1080_vJfoe2nfnOMA.mp4",
//               "http://ie-mps-1258344699.cos.ap-nanjing.myqcloud.com/common/paddyyuan/kipas/0710/h264/eq=brightness=0.02:contrast=1.2:saturation=1.5_h264_1080_J5B9HxA7Kz8A.mp4",
//               "http://ie-mps-1258344699.cos.ap-nanjing.myqcloud.com/common/paddyyuan/kipas/0710/h264/eq=brightness=0.02:contrast=1.2:saturation=1.5_h264_1080_rmunFHYAcY4A.mp4",
//               "http://ie-mps-1258344699.cos.ap-nanjing.myqcloud.com/common/paddyyuan/kipas/0710/h264/eq=brightness=0.02:contrast=1.2:saturation=1.5_h264_1080_aF8zuPYb84IA.mp4",
//               "http://ie-mps-1258344699.cos.ap-nanjing.myqcloud.com/common/paddyyuan/kipas/0710/h264/eq=brightness=0.02:contrast=1.2:saturation=1.5_h264_1080_i2agVec2F70A.mp4",
//               "http://ie-mps-1258344699.cos.ap-nanjing.myqcloud.com/common/paddyyuan/kipas/0710/h264/eq=brightness=0.02:contrast=1.2:saturation=1.5_h264_1080_MNZoVgt89uwA.mp4"]
////
//        var arr: [FeedItem] = []
//        for (index, item) in list.enumerated() {
//            if let fe = item as? FeedItem {
//                if index < urls.count {
//                    fe.videoUrl = urls[index]
//                }
//                printA("xjj picurl = \(fe.coverPictureUrl)")
//                
//                fe.post?.medias = nil
//                arr.append(fe)
//            }
//        }
//        super.setShortVideoModels(arr)
//        printA("xjj HotNewsVideoView setShortVideoModels\(self)")
    }
    
    public override func appendShortVideoModels(_ list: [TUIPlayerDataModel]) {
        super.appendShortVideoModels(list)
        return
//        let urls = [
//    "https://1316940742.vod2.myqcloud.com/ae9df7c5vodtranssgp1316940742/8a28afcb1253642699021931986/adp.1475297.m3u8",
//    "https://1316940742.vod2.myqcloud.com/ae9df7c5vodtranssgp1316940742/41408bce1253642699068063478/adp.1475297.m3u8",
//    "https://1316940742.vod2.myqcloud.com/ae9df7c5vodtranssgp1316940742/690a96231253642699072471451/adp.1475297.m3u8",
//    "https://1316940742.vod2.myqcloud.com/bd86ecc4vodtransjkt1316940742/470828221397757888218599228/adp.1475297.m3u8",
//    "https://1316940742.vod2.myqcloud.com/bd86ecc4vodtransjkt1316940742/8c9c2f331397757888202551583/adp.1475297.m3u8"
//        ]
//        var arr: [FeedItem] = []
//        for (index, item) in list.enumerated() {
//            if let fe = item as? FeedItem {
//                if index < urls.count {
//                    fe.videoUrl = urls[index]
//                }
//                fe.post?.medias = nil
//                arr.append(fe)
//            }
//        }
//        super.appendShortVideoModels(arr)
//        for item in list {
//            if let fe = item as? FeedItem {
//                printA("xjjjj = \(fe.videoUrl)")
//            }
//        }
//        printA("xjj HotNewsVideoView appendShortVideoModels\(self)")
    }
    
    public func printA(_ items: Any..., separator: String = " ", terminator: String = "\n") {
//        return;
        print("\(dateFormatter.string(from: Date())) \(items)", separator: separator, terminator: terminator)
    }
    
    public func printB(_ items: Any..., separator: String = " ", terminator: String = "\n") {
        return;
        print("\(dateFormatter.string(from: Date())) \(items)", separator: separator, terminator: terminator)
    }
}

