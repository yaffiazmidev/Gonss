//
//  AppConfig.swift
//  KKPlayerApp
//
//  Created by Rahmat Trinanda Pramudya Amar on 20/06/23.
//

import Foundation
import FeedCleeps

class AppConfig {
    static let shared: AppConfig = AppConfig()
    
    private init(){}
    
    let clearCache: Bool = true
    let usePreload: Bool = true
    let useTUIPlayer: Bool = true
    
    //Player Config
//        var player: VideoPlayer = VersaVideoPlayer.instance
    var player: VideoPlayer = TencentVideoPlayer.instance
    
    //var player: KKVideoPlayer = KKTencentVideoPlayer.instance
    
    //Data Url
    //    let data: [String] = AppData.shared.kipasUrl
    //    let data: [String] = AppData.shared.tencentId
    let data: [String] = AppData.shared.tencentUrl
    
}
