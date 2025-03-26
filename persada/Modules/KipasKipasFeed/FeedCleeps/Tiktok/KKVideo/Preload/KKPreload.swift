//
//  KKPreload.swift
//  DesignKit
//
//  Created by koanba on 26/05/23.
//

import CoreMedia
import AVFoundation

public class KKPreload: NSObject {
    public static let instance = KKPreload()
    let LOG_ID = "KKPreload"
    var urls: [String] = []
    var limit = 2
    var downloadDone = 0
    var needDownload = 0
    var loadedTimeRangeObsever:NSKeyValueObservation?
    var waitingReasonObserver:NSKeyValueObservation?
    var lastPreloadCheck = 0.0
    var isInit = true
    var observer:Any!
    var lastStartPreload = Date()
    var lastLoadedTime = 0.0
    var isInitPlay = true
    var lastRun = Date()
    var preloadNextVideo:String?
    var allUrls: [String] = []
    var isCanPreload = false
    var nextVideo = 0
    var lastRunNextVideo = Date()

    public func setup(urls: [String], country: String) {
        let oldPreloads = KKPreload.instance.allUrls.filter({!urls.contains(($0))})
        
        self.cancelPreload(urls: oldPreloads)
        
        KKPreload.instance.nextVideo = 0
        if(oldPreloads.count == KKPreload.instance.allUrls.count) {
            downloadDone = 0
            needDownload = 0
        }
        
        if(urls.count == 0) {
            if(KKPreload.instance.preloadNextVideo != nil) {
                let videoId = KKResourceHelper.instance.getVideoId(urlPath: KKPreload.instance.preloadNextVideo!)
                let downloadTask = KKDownloadTask.instance.sessions[videoId]
                let data = downloadTask?.task?.data
                if(data != nil && downloadTask?.startByte != nil) {
                    let mediaInfo = KKDownloadTask.instance.mediaInfoList[videoId]
                    KKResourceHelper.instance.writeTmpBuffer(data: data!, urlPath: mediaInfo?.urlToDownload.absoluteString ?? "", requestOffset: downloadTask!.startByte)
                }
                downloadTask?.task?.cancel()
                KKDownloadTask.instance.sessions[videoId] = nil
            }
        }
        
        if(KKPreload.instance.allUrls.count > 1) {
            if(KKPreload.instance.allUrls[1] != urls.first && KKPreload.instance.allUrls[0] != urls.first) {
                if(KKPreload.instance.preloadNextVideo != nil) {
                    let videoId = KKResourceHelper.instance.getVideoId(urlPath: KKPreload.instance.preloadNextVideo!)
                    let downloadTask = KKDownloadTask.instance.sessions[videoId]
                    let data = downloadTask?.task?.data
                    if(data != nil && downloadTask?.startByte != nil) {
                        let mediaInfo = KKDownloadTask.instance.mediaInfoList[videoId]
                        KKResourceHelper.instance.writeTmpBuffer(data: data!, urlPath: mediaInfo?.urlToDownload.absoluteString ?? "", requestOffset: downloadTask!.startByte)
                    }
                    downloadTask?.task?.cancel()
                    KKDownloadTask.instance.sessions[videoId] = nil
                }
            }
        }
        KKPreload.instance.urls = urls.filter({$0.contains(".mp4")})
        KKPreload.instance.allUrls = KKPreload.instance.urls
        if(KKPreload.instance.urls.count > KKPreload.instance.nextVideo) {
            KKPreload.instance.preloadNextVideo = KKPreload.instance.urls[KKPreload.instance.nextVideo]
        }
        print(self.LOG_ID, "doPreload --- ", country)
        urls.forEach { urlPreload in
            print(self.LOG_ID, "doPreload", KKVideoId().getId(urlString:  urlPreload))
        }
        
                
        lastPreloadCheck = 0.0
        lastLoadedTime = 0.0
        lastRunNextVideo = Date()
        KKPreload.instance.isCanPreload = true
        needDownload = 0
        downloadDone = 0
        self.startPreload()
        self.doPreloadNextVideo()
        
        if(isInit) {
            addInterval()
            isInit = false
        }
    }
    
    func resetPreload() {
        KKDownloadTask.instance.sessions.forEach { key, downloadTask in
            let curPlayVideoId = KKResourceHelper.instance.getVideoId(urlPath: KKResourceLoader.instance.loadingRequest?.request.url?.absoluteString ?? "")
            if(downloadTask.id != curPlayVideoId) {
                let data = downloadTask.task?.data
                if(data != nil && downloadTask.startByte != nil) {
                    let mediaInfo = KKDownloadTask.instance.mediaInfoList[key]
                    KKResourceHelper.instance.writeTmpBuffer(data: data!, urlPath: mediaInfo?.urlToDownload.absoluteString ?? "", requestOffset: downloadTask.startByte)
                }
                downloadTask.urlSessions.cancelAllRequests()
                downloadTask.task?.cancel()
                KKDownloadTask.instance.sessions[key] = nil
            }
        }
        KKPreload.instance.urls = KKPreload.instance.allUrls
        needDownload = 0
        downloadDone = 0
    }
        
    func cancelPreload(urls: [String]) {
        urls.forEach { urlStr in
            if(urlStr != KKPreload.instance.preloadNextVideo) {
                let videoId = KKResourceHelper.instance.getVideoId(urlPath: urlStr)
                let downloadTask = KKDownloadTask.instance.sessions[videoId]
                let data = downloadTask?.task?.data
                if(data != nil && downloadTask?.startByte != nil) {
                    let mediaInfo = KKDownloadTask.instance.mediaInfoList[videoId]
                    KKResourceHelper.instance.writeTmpBuffer(data: data!, urlPath: mediaInfo?.urlToDownload.absoluteString ?? "", requestOffset: downloadTask!.startByte)
                    downloadDone += 1
                }
                downloadTask?.urlSessions.cancelAllRequests()
                downloadTask?.task?.cancel()
                KKDownloadTask.instance.sessions[videoId] = nil
            }
        }
    }
    
    func addInterval() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
            self.startPreload()
            self.addInterval()
        })
    }
    
    public func startPreload() {
        guard let player = KKVersaVideoPlayer.instance as? KKVersaVideoPlayer else { return }
        let timePlaying = CMTimeGetSeconds(player.player?.currentTime() ?? .zero)
        let timeRange = player.player?.currentItem?.loadedTimeRanges.first?.timeRangeValue
        var loadedTime = CMTimeGetSeconds(timeRange?.duration ?? CMTime())
        let itemDuration = CMTimeGetSeconds(player.player?.currentItem?.duration ?? .zero)
        
        if(KKPreload.instance.urls.count < 1) {
            KKPreload.instance.urls = KKPreload.instance.allUrls
        }
        
        if(needDownload < downloadDone) {
            needDownload = 0
            downloadDone = 0
        }
        
        if(KKPreload.instance.isCanPreload && needDownload == downloadDone) {
            var max = 1
            max = max < KKPreload.instance.urls.count ? max : KKPreload.instance.urls.count
            if(KKPreload.instance.urls.count > 0) {
                //print(self.LOG_ID, "preload-enter-1")
                for i in 0..<max {
                    if let _ = KKPreload.instance.urls[exist: i] {
                        
                        let url = KKPreload.instance.urls[i]
                        let videoId = KKResourceHelper.instance.getVideoId(urlPath: url)
                        
                        //print(self.LOG_ID, "preload-enter-2", videoId)
                        
                        DispatchQueue.main.async {
                            KKDownloadTask.instance.getDownloadInfo(url: URL(string: url)!, videoId: videoId) {
                                let mediaInfo = KKDownloadTask.instance.mediaInfoList[videoId]
                                
                                print(self.LOG_ID, "download --- ", KKVideoId().getId(url: mediaInfo!.urlToDownload))
                                
                                self.download(urlToDownload: mediaInfo!.urlToDownload, isNextVideo: false)
                                KKPreload.instance.urls.removeAll(where: {KKResourceHelper.instance.getVideoId(urlPath: $0) == videoId})
                            }
                        }
                    }
                }
            } else {
                //print(self.LOG_ID, "preload-skip-2")
            }
        } else {
            //print(self.LOG_ID, "preload-skip-1")
        }
        self.doPreloadNextVideo()
    }
    
    func doPreloadNextVideo() {
        guard let player = KKVersaVideoPlayer.instance as? KKVersaVideoPlayer else { return }
        let timePlaying = CMTimeGetSeconds(player.player?.currentTime() ?? .zero)
        if(timePlaying > 0.0 && !timePlaying.isNaN && KKPreload.instance.isCanPreload && downloadDone % 5 == 0 && downloadDone != 0) {
            if(KKPreload.instance.preloadNextVideo != nil) {
                let url = KKPreload.instance.preloadNextVideo!
                let videoId = KKResourceHelper.instance.getVideoId(urlPath: url)
                KKDownloadTask.instance.getDownloadInfo(url: URL(string: url)!, videoId: videoId) {
                    let mediaInfo = KKDownloadTask.instance.mediaInfoList[videoId]
                    let videoId = KKResourceHelper.instance.getVideoId(urlPath: KKPreload.instance.preloadNextVideo!)
                    let downloadTask = KKDownloadTask.instance.sessions[videoId]
                    let isFinished = downloadTask?.task?.isFinished ?? false
                    
                    let request = downloadTask?.task?.request
                    let range = request?.value(forHTTPHeaderField: "Range")?.replacingOccurrences(of: "bytes=", with: "")
                    let rangeSplit = range?.split(separator: "-")
                    var endByte = -1
                    if(rangeSplit?.count ?? 0 > 1) {
                        endByte = Int(rangeSplit?[1] ?? "-") ?? -1
                    }
                    if(isFinished || mediaInfo?.size ?? 0 != endByte || downloadTask == nil) {
                        let data = downloadTask?.task?.data
                        if(data != nil && downloadTask?.startByte != nil) {
                            let mediaInfo = KKDownloadTask.instance.mediaInfoList[videoId]
                            KKResourceHelper.instance.writeTmpBuffer(data: data!, urlPath: mediaInfo?.urlToDownload.absoluteString ?? "", requestOffset: downloadTask!.startByte)
                        }
                        downloadTask?.task?.cancel()
                        KKDownloadTask.instance.sessions[videoId] = nil
                        self.download(urlToDownload: mediaInfo!.urlToDownload, isNextVideo: true)
                    }
                }
            }
        }
    }
    
    private func download(urlToDownload: URL, isFromError: Bool = false, isNextVideo: Bool = false) {
        if(urlToDownload.absoluteString != "" && urlToDownload.absoluteString.contains(".mp4")) {
            let videoId = KKResourceHelper.instance.getVideoId(urlPath: urlToDownload.absoluteString)
            var mediaInfo = KKDownloadTask.instance.mediaInfoList[videoId]
            let size = mediaInfo!.size
            let kbps = mediaInfo!.kbps
            let fileSize = KKResourceHelper.instance.readTmpBuffer(urlPath: urlToDownload.absoluteString)
            let startByte = fileSize.count
            var endByte = 500_000
            if(isNextVideo) {
                endByte = Int(size)
            }

            var request = URLRequest(url: urlToDownload)
            request.setValue("bytes=" + String(startByte) + "-" + String(endByte), forHTTPHeaderField: "Range")
            let downloadTask = KKDownloadTask.instance.sessions[videoId]
            let isFinished = downloadTask?.task?.isFinished ?? false
            if((downloadTask == nil || isFinished) && startByte < endByte && startByte < size) {
                //print(self.LOG_ID, "prepare video", KKVideoId().getId(url: urlToDownload) , isNextVideo, startByte, endByte)
                //print(self.LOG_ID, "prepare video", urlToDownload.absoluteString.suffix(23) , startByte, endByte, isNextVideo)
                if(!isNextVideo) {
                    self.needDownload += 1
                }
                KKDownloadTask.instance.download(request: request, isLowRes: true, isFromPreload: true, isFromError: isFromError) { dataResponse in
                    if(dataResponse.error != nil) {
                        KKDownloadTask.instance.sessions[videoId] = nil
                    }
                    if(dataResponse.error == nil) {
                        do {
                            let data = dataResponse.data
                            if(data != nil) {
                                if(!isNextVideo) {
                                    self.downloadDone += 1
                                }
                                let downloadTask = KKDownloadTask.instance.sessions[videoId]
                                if(downloadTask?.task?.state == .finished) {
                                    let videoIdFromLoadingRequest = KKResourceHelper.instance.getVideoId(urlPath: KKResourceLoader.instance.loadingRequest?.request.url?.absoluteString ?? "")
                                    let videoId = KKResourceHelper.instance.getVideoId(urlPath: urlToDownload.absoluteString)
                                    let fileSize = KKResourceHelper.instance.readTmpBuffer(urlPath: urlToDownload.absoluteString)
                                    if(videoId != videoIdFromLoadingRequest && data!.count >= endByte && downloadTask?.startByte != nil) {
                                        KKResourceHelper.instance.writeTmpBuffer(data: data!, urlPath: urlToDownload.absoluteString, requestOffset: downloadTask!.startByte)
                                        print(self.LOG_ID, "preload done ", urlToDownload.absoluteString.suffix(23), endByte, data?.count ?? 0, downloadTask?.task?.state ?? "", downloadTask!.startByte)
                                    }
                                    
                                    if(isNextVideo) {
                                        KKPreload.instance.nextVideo += 1
                                        if(KKPreload.instance.urls.count > KKPreload.instance.nextVideo) {
                                            if let _ = KKPreload.instance.allUrls[exist: KKPreload.instance.nextVideo] {
                                                KKPreload.instance.preloadNextVideo = KKPreload.instance.allUrls[KKPreload.instance.nextVideo]
                                                let videoId = KKResourceHelper.instance.getVideoId(urlPath: KKPreload.instance.preloadNextVideo!)
                                                let downloadTask = KKDownloadTask.instance.sessions[videoId]
                                                let data = downloadTask?.task?.data
                                                if(data != nil && downloadTask?.startByte != nil) {
                                                    let mediaInfo = KKDownloadTask.instance.mediaInfoList[videoId]
                                                    KKResourceHelper.instance.writeTmpBuffer(data: data!, urlPath: mediaInfo?.urlToDownload.absoluteString ?? "", requestOffset: downloadTask!.startByte)
                                                }
                                                downloadTask?.task?.cancel()
                                                KKDownloadTask.instance.sessions[videoId] = nil
                                                self.doPreloadNextVideo()
                                            }
                                        }
                                    } else {
                                        KKPreload.instance.isCanPreload = true
                                        self.startPreload()
                                    }
                                }
                            }
                        }
                    }
                }
            } else {
                if(!isNextVideo && (startByte >= endByte || startByte >= size)) {
                    self.downloadDone += 1
                }
            }
        }
    }
}

extension Collection where Indices.Iterator.Element == Index {
    subscript (exist index: Index) -> Iterator.Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
