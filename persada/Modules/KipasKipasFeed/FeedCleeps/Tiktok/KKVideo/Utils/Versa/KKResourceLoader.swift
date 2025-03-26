//
//  KKResourceLoader.swift
//  FeedCleeps
//
//  Created by ahyakamil on 06/03/23.
//

import AVFoundation
import UIKit

public class KKResourceLoader: UIViewController, AVAssetResourceLoaderDelegate, URLSessionDataDelegate, URLSessionTaskDelegate {
    let customPlaylistScheme = "kipas-app"
    let httpsScheme = "https"
    private let badRequestErrorCode = 400
    let slowNetworkDuration = 1.0
    lazy var isSlowNetwork = false
    var isSlowNetworkNotifHasBeenSent = false
    lazy var lastCheckCanPreload = Date()
    lazy var isInit = true
    lazy var currentPresenterId = ""
    lazy var contentLength = 99999999999
    let smallestChunk = 50_000
    let biggestChunk = 50_000
    let headerChunk = 50_000
    var onRequestMiss:() -> Void = {
        
    }
    var loadingRequest:AVAssetResourceLoadingRequest?
    var isDownloadHasStart = false
    var curStartByte = 0
    var retry = 0
    var lastWriteByte = 0
    var startByte = 0
    var curKey = ""
    var manyStall = 0
    var prevLoadedTime = 0.0
    var prevTimePlaying = 0.0

    
    public static let instance = KKResourceLoader()

    private func reportError(_ loadingRequest: AVAssetResourceLoadingRequest, withErrorCode error: Int) {
        print("KKResourceLoader error ", error)
        loadingRequest.finishLoading(with: NSError(domain: NSURLErrorDomain, code: error, userInfo: nil))
    }
    
    /*!
     *  AVARLDelegateDemo's implementation of the protocol.
     *  Check the given request for valid schemes:
     */
    public func resourceLoader(_ resourceLoader: AVAssetResourceLoader,
                        shouldWaitForLoadingOfRequestedResource loadingRequest: AVAssetResourceLoadingRequest) -> Bool {
//        print("KKResourceLoader...")
        UIApplication.shared.isIdleTimerDisabled = true
        let videoId = KKResourceHelper.instance.getVideoId(urlPath: KKResourceLoader.instance.loadingRequest?.request.url?.absoluteString ?? "")
        if(KKResourceLoader.instance.loadingRequest?.request.url?.absoluteString != loadingRequest.request.url?.absoluteString) {
            KKResourceLoader.instance.isDownloadHasStart = false
            KKDownloadTask.instance.sessions[videoId]?.task?.cancel()
            KKDownloadTask.instance.sessions[videoId] = nil
            KKResourceLoader.instance.loadingRequest?.finishLoading()
            KKResourceLoader.instance.manyStall = 0
            KKResourceLoader.instance.prevLoadedTime = 0.0
            KKResourceLoader.instance.prevTimePlaying = 0.0
        }
        KKResourceLoader.instance.loadingRequest = loadingRequest

        URLSession.shared.getAllTasks { tasks in
            let tasks = tasks.filter({$0.state == .running})
            tasks.forEach { task in
                let url = task.currentRequest?.url?.absoluteString ?? ""
                if(url.contains(".mp4")) {
                    let curPlayVideoId = KKResourceHelper.instance.getVideoId(urlPath: KKResourceLoader.instance.loadingRequest?.request.url?.absoluteString ?? "")
                    let videoId = KKResourceHelper.instance.getVideoId(urlPath: url)
                    if(task.state == .running && curPlayVideoId != videoId) {
                        if let _ = KKDownloadTask.instance.sessions[videoId] {
                            let downloadTask = KKDownloadTask.instance.sessions[videoId]
                            let data = downloadTask?.task?.data
                            if(data != nil && downloadTask?.startByte != nil && data?.count ?? 0 > 200_000) {
                                let mediaInfo = KKDownloadTask.instance.mediaInfoList[videoId]
                                KKResourceHelper.instance.writeTmpBuffer(data: data!, urlPath: mediaInfo?.urlToDownload.absoluteString ?? "", requestOffset: downloadTask!.startByte)
                                task.cancel()
                            }
                        }
                    }
                } else {
                    task.cancel()
                }
            }
        }
        
        let reqUrl = loadingRequest.request.url
        let reqUrlString = reqUrl?.absoluteString ?? ""

//        print("KKResourceLoader partially load \(reqUrl)")
        if reqUrl!.absoluteString.contains(".mp4") {
            // replace the fakeScheme and get the original video url
            guard var httpsUrl = URL(string: loadingRequest.request.url?.absoluteString.replacingOccurrences(of: customPlaylistScheme, with: httpsScheme) ?? "") else {
                self.reportError(loadingRequest, withErrorCode: badRequestErrorCode)
                return true
            }
            
            let requestOffset = loadingRequest.dataRequest?.requestedOffset
            let avReqLength = loadingRequest.dataRequest?.requestedLength
            var startByte = Int(requestOffset ?? 0)
            let videoId = KKResourceHelper.instance.getVideoId(urlPath: httpsUrl.absoluteString)
            DispatchQueue.main.async {
                KKDownloadTask.instance.getDownloadInfo(url: httpsUrl, videoId: videoId) {
                    var mediaInfo = KKDownloadTask.instance.mediaInfoList[videoId]
                    let tmpData = KKResourceHelper.instance.readTmpBuffer(urlPath: mediaInfo!.urlToDownload.absoluteString)
                    if(tmpData.count > 0 && tmpData.count > startByte ) {
                        if(loadingRequest.contentInformationRequest != nil) {
                            loadingRequest.contentInformationRequest?.contentType = "video/mp4"
                            loadingRequest.contentInformationRequest?.isByteRangeAccessSupported = true
                            loadingRequest.contentInformationRequest?.contentLength = Int64(self.contentLength)
                            loadingRequest.finishLoading()
                        } else {
        //                        print("chunk is exist, load from local", httpsUrl.absoluteString)
                            loadingRequest.dataRequest?.respond(with: tmpData)
                            if(!KKResourceLoader.instance.isDownloadHasStart) {
                                KKResourceLoader.instance.isDownloadHasStart = true
                                KKResourceLoader.instance.lastWriteByte = 0
                                let key = UUID().uuidString
                                KKResourceLoader.instance.curKey = key
                                self.doDownload(url: mediaInfo!.urlToDownload)
                                self.doPlayImmediately(url: mediaInfo!.urlToDownload, loadingRequest: loadingRequest, key: key)
                            }
                        }
                    } else {
                        if(KKResourceLoader.instance.loadingRequest?.contentInformationRequest != nil) {
                            KKResourceLoader.instance.loadingRequest?.contentInformationRequest?.contentType = "video/mp4"
                            KKResourceLoader.instance.loadingRequest?.contentInformationRequest?.isByteRangeAccessSupported = true
                            KKResourceLoader.instance.loadingRequest?.contentInformationRequest?.contentLength = mediaInfo!.size
                            KKResourceLoader.instance.loadingRequest?.finishLoading()
                        } else {
                            if(!KKResourceLoader.instance.isDownloadHasStart) {
                                KKResourceLoader.instance.isDownloadHasStart = true
                                KKResourceLoader.instance.lastWriteByte = 0
                                let key = UUID().uuidString
                                KKResourceLoader.instance.curKey = key
                                self.doDownload(url: mediaInfo!.urlToDownload)
                                self.doPlayImmediately(url: mediaInfo!.urlToDownload, loadingRequest: loadingRequest, key: key)
                            }
                        }
                    }
                }
            }
            return true
        }
        return false
    }
        
    private func doDownload(url: URL, isFromError:Bool = false) {
        KKResourceLoader.instance.retry = 0
        let tmpData = KKResourceHelper.instance.readTmpBuffer(urlPath: url.absoluteString ?? "")
        let startByte = tmpData.count
        var request = URLRequest(url: url)
        let videoIdFromLoadingRequest = KKResourceHelper.instance.getVideoId(urlPath: KKResourceLoader.instance.loadingRequest?.request.url?.absoluteString ?? "")
        let videoId = KKResourceHelper.instance.getVideoId(urlPath: url.absoluteString)
        var mediaInfo = KKDownloadTask.instance.mediaInfoList[videoId]
        let size = mediaInfo!.size
        var endByte = String(size)

        request.setValue("bytes=" + String(startByte) + "-" + endByte, forHTTPHeaderField: "Range")
        if(videoIdFromLoadingRequest == videoId && startByte < size) {
            KKResourceLoader.instance.curStartByte = startByte
            let downloadTask = KKDownloadTask.instance.sessions[videoId]
            if(downloadTask == nil) {
                KKResourceLoader.instance.lastWriteByte = 0
                KKResourceLoader.instance.startByte = startByte
                KKDownloadTask.instance.download(request: request, isLowRes: true, isFromError: isFromError) { dataResponse in
                    KKPreload.instance.isCanPreload = true
                }
            }
        } else {
            if(videoIdFromLoadingRequest == videoId && startByte >= size) {
                if(!KKVersaVideoPlayer.instance.isPaused) {
                    KKVersaVideoPlayer.instance.play()
                }
            }
        }
    }
        
    private func doPlayImmediately(url: URL, loadingRequest: AVAssetResourceLoadingRequest, key: String, prevTimePlaying: Float64 = 0.0, loopCount: Int = 0) {
        guard let player = KKVersaVideoPlayer.instance as? KKVersaVideoPlayer else { return }
        let videoId = KKResourceHelper.instance.getVideoId(urlPath: url.absoluteString)
        var interval = 2.0
        if(key == KKResourceLoader.instance.curKey) {
            var mediaInfo = KKDownloadTask.instance.mediaInfoList[videoId]
            let downloadTask = KKDownloadTask.instance.sessions[videoId]
            if(loadingRequest.request.url?.absoluteString == KKResourceLoader.instance.loadingRequest?.request.url?.absoluteString ?? "") {
                downloadTask?.task?.task?.priority = 1.0
                let taskData = downloadTask?.task?.data
                let localData = KKResourceHelper.instance.readTmpBuffer(urlPath: url.absoluteString ?? "")
                let localStartByte = localData.count
                let size = mediaInfo!.size
                
                if(taskData != nil) {
                    print("resourceLoader", videoId, localStartByte, taskData?.count, size, KKResourceLoader.instance.retry)
                    if(KKResourceLoader.instance.lastWriteByte != taskData!.count && localStartByte < size) {
                        let data = taskData![KKResourceLoader.instance.lastWriteByte..<taskData!.count]
                        if(data.count != 0 && taskData!.count != localStartByte) {
                            if(loadingRequest.request.url?.absoluteString == KKResourceLoader.instance.loadingRequest?.request.url?.absoluteString ?? "") {
                                let itemDuration = CMTimeGetSeconds(player.player?.currentItem?.duration ?? .zero)
                                print("resourceLoader sent data", mediaInfo?.urlToDownload.absoluteString, KKResourceLoader.instance.lastWriteByte, taskData!.count, data.count, localStartByte, size, KKResourceLoader.instance.retry, itemDuration)
                                KKResourceLoader.instance.lastWriteByte = taskData!.count
                                KKResourceLoader.instance.retry = 0
                                
                                KKResourceHelper.instance.writeTmpBuffer(data: data, urlPath: url.absoluteString, requestOffset: localStartByte)
                                
                                let recheckLocalData = KKResourceHelper.instance.readTmpBuffer(urlPath: url.absoluteString ?? "")
                                let recheckLocalStartByte = recheckLocalData.count
                                if(recheckLocalStartByte != localStartByte) {
                                    KKResourceLoader.instance.loadingRequest?.dataRequest?.respond(with: data)
                                }
                                
                                let request = downloadTask?.task?.request
                                let range = request?.value(forHTTPHeaderField: "Range")?.replacingOccurrences(of: "bytes=", with: "")
                                let rangeSplit = range?.split(separator: "-")
                                var endByte = -1
                                if(rangeSplit?.count ?? 0 > 1) {
                                    endByte = Int(rangeSplit?[1] ?? "-") ?? -1
                                }
                                if(endByte != size) {
                                    KKDownloadTask.instance.sessions[videoId]?.task?.cancel()
                                    KKDownloadTask.instance.sessions[videoId] = nil
                                    self.doDownload(url: url)
                                }
                            }
                        } else {
                            if(localStartByte < size) {
                                KKDownloadTask.instance.sessions[videoId]?.task?.cancel()
                                KKDownloadTask.instance.sessions[videoId] = nil
                                self.doDownload(url: url)
                            }
                        }
                    } else {
                        if(localStartByte < size) {
                            KKDownloadTask.instance.sessions[videoId]?.task?.cancel()
                            KKDownloadTask.instance.sessions[videoId] = nil
                            self.doDownload(url: url)
                        }
                    }
                } else {
                    if(localStartByte < size) {
                        self.doDownload(url: url)
                    }
                }
                
                let timePlaying = CMTimeGetSeconds(player.player?.currentTime() ?? .zero)
                if(timePlaying > 0.0 && localStartByte < size) {
                    interval = 5.0
                    let isFinish = downloadTask?.task?.isFinished ?? false
                    if(isFinish && localStartByte < size) {
                        KKDownloadTask.instance.sessions[videoId]?.task?.cancel()
                        KKDownloadTask.instance.sessions[videoId] = nil
                        self.doDownload(url: url)
                    }
                    
                    let timeRange = player.player?.currentItem?.loadedTimeRanges.first?.timeRangeValue
                    var loadedTime = CMTimeGetSeconds(timeRange?.duration ?? CMTime())
                    if(timePlaying > 0.0 && loadedTime - timePlaying < 3) {
                         if(!KKVersaVideoPlayer.instance.isPaused) {
                             KKPreload.instance.isCanPreload = false
                             KKResourceLoader.instance.manyStall += 1
                             KKPreload.instance.resetPreload()
                         }
                    } else {
                        if(KKResourceLoader.instance.manyStall > 0 && KKPreload.instance.downloadDone > 5) {
                            KKPreload.instance.isCanPreload = false
                        } else {
                            KKPreload.instance.isCanPreload = true
                        }
                    }
                    
                    if(KKResourceLoader.instance.manyStall > 2) {
                        interval = 7.0
                    }
                    
                    let recheckLocalData = KKResourceHelper.instance.readTmpBuffer(urlPath: url.absoluteString ?? "")
                    let recheckLocalStartByte = recheckLocalData.count
                    if(recheckLocalStartByte >= size) {
                        KKPreload.instance.isCanPreload = true
                    }

                    if(KKResourceLoader.instance.prevTimePlaying == timePlaying && recheckLocalStartByte >= size) {
                        if(!KKVersaVideoPlayer.instance.isPaused) {
                            print("resourceLoader sent data reset 3", KKResourceLoader.instance.manyStall)
                            KKVersaVideoPlayer.instance.isFailed = true
                        }
                    }
                    
                    KKResourceLoader.instance.prevLoadedTime = loadedTime
                }
                KKResourceLoader.instance.prevTimePlaying = timePlaying

                if(interval == 2.0) {
                    if(timePlaying - prevTimePlaying < 1.5 && loopCount % 3 == 0 && localStartByte <= size) {
                        if(!KKVersaVideoPlayer.instance.isPaused) {
                            print("resourceLoader sent data reset 1", KKResourceLoader.instance.manyStall)
                            KKVersaVideoPlayer.instance.isFailed = true
                        }
                    }
                } else {
                    if(timePlaying - prevTimePlaying < 1.5 && localStartByte <= size) {
                        if(!KKVersaVideoPlayer.instance.isPaused) {
                            print("resourceLoader sent data reset 2", KKResourceLoader.instance.manyStall)
                            KKVersaVideoPlayer.instance.isFailed = true
                        }
                    }
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + interval, execute: {
                    if(key == KKResourceLoader.instance.curKey) {
                        self.doPlayImmediately(url: url, loadingRequest: loadingRequest, key: key, prevTimePlaying: timePlaying, loopCount: loopCount+1)
                    }
                })
            } else {
                KKDownloadTask.instance.sessions[videoId]?.task?.cancel()
                KKDownloadTask.instance.sessions[videoId] = nil
            }
        } else {
            KKDownloadTask.instance.sessions[videoId]?.task?.cancel()
            KKDownloadTask.instance.sessions[videoId] = nil
        }
    }
    
    private func notifySlowNetwork() {
//        DispatchQueue.main.async {
//            self.displayToast("Your network is unstable")
//        }
    }
    
    private func displayToast(_ message : String) {
        guard let delegate = UIApplication.shared.delegate, let window = delegate.window else {
            return
        }
        if let toast = window?.subviews.first(where: { $0 is UILabel && $0.tag == -1001 }) {
            toast.removeFromSuperview()
        }

        let toastView = UILabel()
        toastView.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        toastView.textColor = UIColor.white
        toastView.textAlignment = .center
        toastView.font = UIFont(name: "Font-name", size: 17)
        toastView.layer.cornerRadius = 25
        toastView.text = message
        toastView.numberOfLines = 0
        toastView.alpha = 0
        toastView.translatesAutoresizingMaskIntoConstraints = false
        toastView.tag = -1001

        window?.addSubview(toastView)

        let horizontalCenterContraint: NSLayoutConstraint = NSLayoutConstraint(item: toastView, attribute: .centerX, relatedBy: .equal, toItem: window, attribute: .centerX, multiplier: 1, constant: 0)
        
        let widthContraint: NSLayoutConstraint = NSLayoutConstraint(item: toastView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1, constant: (self.view.frame.size.width-25) )
            
        let verticalContraint: [NSLayoutConstraint] = NSLayoutConstraint.constraints(withVisualFormat: "V:|-(>=250)-[toastView(==80)]-500-|", options: [.alignAllCenterX, .alignAllCenterY], metrics: nil, views: ["toastView": toastView])

        NSLayoutConstraint.activate([horizontalCenterContraint, widthContraint])
        NSLayoutConstraint.activate(verticalContraint)

        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseIn, animations: {
            toastView.alpha = 1
        }, completion: nil)

        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(3), execute: {
            UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseIn, animations: {
                toastView.alpha = 0
            }, completion: { finished in
                toastView.removeFromSuperview()
            })
        })
    }
    
    func getMaxBytesSize(startByte: Int) -> Int {
        var result = smallestChunk
        if(startByte == 0) {
            result = headerChunk
        }
        if(startByte > 500_000) {
            result = biggestChunk
        }
        return result
    }
    
    public func resourceLoader(_ resourceLoader: AVAssetResourceLoader, didCancel loadingRequest: AVAssetResourceLoadingRequest) {
        print("KKResourceLoader cancel request ", loadingRequest.request.url)
        KKVersaVideoPlayer.instance.isFailed = true
    }
}

extension FileManager {
    func moveItem(at url: URL, toUrl: URL, completion: @escaping (Bool, Error?) -> ()) {
        DispatchQueue.global(qos: .utility).async {

            do {
                try self.moveItem(at: url, to: toUrl)
            } catch {
                // Pass false and error to completion when fails
                DispatchQueue.main.async {
                   completion(false, error)
                }
            }

            // Pass true to completion when succeeds
            DispatchQueue.main.async {
                completion(true, nil)
            }
        }
    }
}

extension AVURLAsset {
    var fileSize: Int? {
        let keys: Set<URLResourceKey> = [.totalFileSizeKey, .fileSizeKey]
        let resourceValues = try? url.resourceValues(forKeys: keys)

        return resourceValues?.fileSize ?? resourceValues?.totalFileSize
    }
}
