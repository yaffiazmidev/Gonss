//
//  WebServerManager.swift
//  tiktokclone
//
//  Created by koanba on 06/02/22.
//

import UIKit
import AVKit
import AVFoundation
//import HLSCachingReverseProxyServer
import GCDWebServer

public final class KKWebServerFeedCleeps {

    public var webServer: GCDWebServer!
    private var urlSession: URLSession!
    private var cache: DataCache!
//    private var server: ProxyServer!

    public static let shared = KKWebServerFeedCleeps()
    
    
    
    private init() {
//        ProxyServer.init()
//        self.webServer = GCDWebServer()
//        self.cache = DataCache(name: "KKCache")
//        cache.maxDiskCacheSize = 20 * 1024 * 1024      // 100*1024*1024 = 100 MB
//        cache.maxCachePeriodInSecond = 1 * 86400      // 2*86400 = 2 day
//
//        self.urlSession = URLSession.shared //(configuration: .default)
//        self.server = HLSCachingProxy(webServer: self.webServer, urlSession: self.urlSession, cache: self.cache)
//
//        if(DebugMode().isTrue()){
//            self.cleanAllCache()
//            //GCDWebServer.setLogLevel(1)
//        }
//
//        self.server.IS_THROTTLE = true

    }
    
//    public func start(){
//        self.server.start(port: 8082)
//        print("**** GCDWebServer - starts")
//        GCDWebServer.setLogLevel(5)
//    }

//    func getUrl(url: String) -> URL{
//        let playlistURL = URL(string: url)!
//        return server.reverseProxyURL(from: playlistURL)!
        
//        var forceUrl = KKVideoCache.shared.selectPlaylist(source: url, toPlaylist: KKVideoCache.shared.SELECTED_RESOLUTION)
//        return server.reverseProxyURL(from: playlistURL)!
//    }

//    func cleanAllCache(){
//        DataCache.instance.cleanAll()
//        self.cache.cleanAll()
//    }
//
//    func cleanMemCache(){
//        print("*****cache cleanMemCache")
//        self.cache.cleanMemCache()
//    }
//
//    func cleanExpiredDiskCache(){
//        self.cache.cleanExpiredDiskCache()
//    }
//
//
//    func cleanDiskCache(){
//        self.cache.cleanDiskCache()
//    }

}
