////
////  WebServer.swift
////  AKPlayer
////
////  Created by ahya kamil on 03/03/22.
////
//
///**
// Notes:
// file name in local playlist is not valid for check quality, because it's pick first m3u8 as template
// so it is possible the name "1645277565832_480p_000.ts" is 1080 quality or else
// which choose from preferred by network speed
// */
//
//import GCDWebServer
//import RxRelay
//
//open class ProxyServer {
//    private var webServer: GCDWebServer!
//    public var downloadSpeed = 0
//    private var downloadTimePerTS = 0.0
//    private var downloadBytePerTS = 0
//    
//    private let prioritySpeedPercentage = 60
//    private let maxTsSegmentToPrepare = 1
//    private var isDoingThingWhenIdleDone = true
//    private var nowPlayingId = ""
//    private var urlSessionsTsPriority:URLSessionDownloadTask?
//    private var urlSessionsTsPrepare:URLSessionDownloadTask?
//    var urlSessionsM3u8 = [String: String]()
//    private let minCurPlayingSegments = 1
//    public var activeId = ""
//    private var maxTTL = 0.0003
//    private let prepareMaxTTL = 60
//    private let sessionNameIsPrepareFinish = "IS_PREPARE_FINISHED";
//    private var mediaFinishToProcess = 0
//    private let prepareLimit = 2
//    private var prepareCount = 0
//
//    
//    public var feeds = [String: [Feed?]]()
//    
//    let backgroundQueue = DispatchQueue(label: "com.app.kipaskipas", qos: .background)
//    var prepareRetry = 0
//    var serverStatus = ""
//    private var lastBiggestViewIndex = [String: Int]()
//
//    public static let shared = ProxyServer();
//    
//    var movingAverage = MovingAverage()
//    
//    public var queueDownloads = [String]()
//
//    public init() {
//        self.webServer = GCDWebServer()
//        GCDWebServer.setLogLevel(5)
//        self.serverHandler()
//    }
//    
//    open func reset(id: String) {
//        ProxyServer.shared.feeds[id] = []
//    }
//    
//    open func start() {
//        guard !self.webServer.isRunning else { return }
//        
//        let semaphore = DispatchSemaphore(value: 0)
//        self.webServer.start(withPort: 8080, bonjourName: giveSignal(semaphore: semaphore))
//        semaphore.wait()
//
//        print("proxy started")
//        ProxyServer.shared.serverStatus = "started"
//    }
//    
//    public func setLastBiggestViewIndex(id: String, index: Int) {
//        if let biggestIndex = ProxyServer.shared.lastBiggestViewIndex[id] {
//            if biggestIndex < index {
//                ProxyServer.shared.lastBiggestViewIndex[id]! = index
//            }
//        } else {
//            ProxyServer.shared.lastBiggestViewIndex[id] = 0
//        }
//    }
//    
//    private func giveSignal(semaphore: DispatchSemaphore) -> String {
//        semaphore.signal()
//        return "ok"
//    }
//    
//    private func serverHandler() {
//        let baseOrigin = "https://asset.kipaskipas.com/media/stream"
//        let this = self
//        self.webServer.addHandler(forMethod: "GET", pathRegex: "^/.*\\.m3u8$", request: GCDWebServerRequest.self) { [weak self] request, completion in
//            var origin:String?
//            var priority:String?
//            request.query.map { query in
//                origin = query["x"]
//                priority = query["priority"]
//            }
//                            
//            var data:Data = Data("".utf8)
//            let contentType = "application/x-mpegurl"
//            let mainPlaylist = this.readFile(url: request.path)
//            if(mainPlaylist != "") {
//                data = Data(mainPlaylist.utf8)
//                completion(GCDWebServerDataResponse(data: data, contentType: contentType))
//            } else {
//                if let origin = origin {
//                    this.createLocalMainPlaylist(url: origin, completion: completion)
////                    ProxyServer.shared.urlSessionsM3u8[ProxyServer.shared.getVideoId(urlPath: origin)] = "done"
//                }
////                completion(GCDWebServerResponse(statusCode: 500))
//            }
//        }
//
//        self.webServer.addHandler(forMethod: "GET", pathRegex: "^/.*\\.ts$", request: GCDWebServerRequest.self) { [weak self] request, completion in
//            let urlOrigin = baseOrigin + request.path
//            let fileName = request.path.components(separatedBy: "/").last
//            
//            var priority:String?
//            request.query.map { query in
//                priority = query["priority"]
//            }
//            
//            if let _ = priority {} else { priority = "true" }
//            let isPriority = priority == "true" ? true : false
//            
//            let mainPlaylist = this.readFile(url: this.getVideoId(urlPath: urlOrigin) + "/main.m3u8")
//            if(mainPlaylist != "" && request.path.contains(".ts")) {
//                
//                
//                //print("**debug-v", urlOrigin)
//                
//                let tsRegex = ".*ts"
//                let tsFiles = this.groups(text: mainPlaylist, regexPattern: tsRegex)
//
//
//                var savedFileName = ""
//                tsFiles.forEach { tsFile in
//                    let tsOrderedNumber = tsFile.first?.components(separatedBy: "_").last
//                    if(fileName!.contains(tsOrderedNumber!)) {
//                        savedFileName = tsFile.first!
//                    }
//                }
//
//                do {
//                    let savedFileNameArr = savedFileName.components(separatedBy: "_")
//                    let sessionName = savedFileNameArr[0] + savedFileNameArr[2]
//                    
//                    var data:Data = Data("".utf8)
//                    let localPath = this.toLocalPath(url: this.changeFileNameUrl(url: urlOrigin, updatedFile: savedFileName))
//                    let contentType = "video/mp2t"
//                    if(this.isFileExist(url: this.changeFileNameUrl(url: urlOrigin, updatedFile: savedFileName))) {
//                        data = try Data(contentsOf: localPath)
//                        //print("okesips ", data.count)
//                        if(data.count < 2048) {
//                            this.deleteFile(url: this.changeFileNameUrl(url: urlOrigin, updatedFile: savedFileName))
//                            self?.backgroundQueue.asyncAfter(deadline: .now() + 0.0003, execute: {
////                                completion(GCDWebServerResponse(statusCode: 500))
//                            })
//                        } else {
//                            completion(GCDWebServerDataResponse(data: data, contentType: contentType))
//                        }
//                    } else {
//                        let preferredTs = this.preferredTsQuality(url: urlOrigin, isPriority: isPriority)
//                        let updatedUrlOrigin = this.changeFileNameUrl(url: urlOrigin, updatedFile: preferredTs)
//                        var startTime: CFAbsoluteTime!
//                        var stopTime: CFAbsoluteTime!
//                        var bitReceived = 0
//                        startTime = CFAbsoluteTimeGetCurrent()
//                        stopTime = startTime
//                        //bitReceived = 0
//                        
//                        let priorityId = KKVideoManager.shared.getPriority()
//                        guard let tsUrl = URL(string: updatedUrlOrigin) else { return }
//                        
//                        if let canDownloadVideo: Bool = self?.canDownloadVideo(urlString: tsUrl.absoluteString) {
//                            
//                            if(!canDownloadVideo){
//                                //print("**DEBUG-V --TimePerTS IGN   ", self?.getVideoName(urlPath: updatedUrlOrigin) ?? "", "priorityId", priorityId)
//
//                                completion(GCDWebServerResponse(statusCode: 400))
//                                
//                            } else {
//                                self?.backgroundQueue.async {
//                                    let download = URLSession.shared.downloadTask(with: tsUrl) {
//                                        urlOrNil, responseOrNil, errorOrNil in
//                                        
//                                        guard let fileURL = urlOrNil else {
//                                            self?.backgroundQueue.asyncAfter(deadline: .now() + 0.0003, execute: {
//                                                //                                            completion(GCDWebServerResponse(statusCode: 500))
//                                            })
//                                            return
//                                        }
//                                        
//
//                                        self?.queueDownloads.removeAll(where: { $0 == tsUrl.absoluteString })
//
//                                        //print("====DEBUG-V --TimePerTS END  ", "tsUrl:", tsUrl, "allCount:", self?.queueDownloads.count ?? 0)
//
//                                        do {
//                                            let data = try Data(contentsOf: fileURL)
//                                            if(data.count > 2048) {
//                                                let contentType = "video/MP2T"
//                                                completion(GCDWebServerDataResponse(data: data, contentType: contentType))
//                                            } else {
//                                                self?.backgroundQueue.asyncAfter(deadline: .now() + 0.0003, execute: {
//                                                    //                                                completion(GCDWebServerResponse(statusCode: 500))
//                                                })
//                                            }
//                                        } catch {
//                                            // error
//                                            self?.backgroundQueue.asyncAfter(deadline: .now() + 0.0003, execute: {
//                                                //                                            completion(GCDWebServerResponse(statusCode: 500))
//                                            })
//                                        }
//                                        
//                                        self?.writeFromUrlToFile(urlPath: updatedUrlOrigin, updatedName: savedFileName, fileURL: fileURL)
//                                        
//                                        //responseOrNil in byte, 1 byte = 8 bit
//                                        //bitReceived = Int(truncatingIfNeeded: responseOrNil!.expectedContentLength)  * 8
//                                        
//                                        bitReceived = Int(responseOrNil?.expectedContentLength ?? 0)
//                                        stopTime = CFAbsoluteTimeGetCurrent()
//                                        let elapsed = stopTime - startTime
//                                        
//                                        //this.downloadSpeed = elapsed != 0 ? Int(Double(bitReceived) / elapsed) : -1
//                                        
//                                        this.downloadTimePerTS = elapsed
//                                        this.downloadBytePerTS = bitReceived
//                                        
//                                        this.downloadSpeed = Int(Double(bitReceived) / elapsed)
//                                                                        
//                                        let date = Date()
//                                        let formatter = DateFormatter()
//                                        formatter.timeZone = TimeZone(abbreviation: "GMT+7:00") //Current time zone
//                                        formatter.dateFormat = "HH:MM:ss"
//                                        let currentTime: String = formatter.string(from: date)
//
//                                        
//                                        //print("**DEBUG-V --TimePerTS FINIS ", currentTime, self?.getVideoName(urlPath: updatedUrlOrigin) ?? "")
//                                        
//                                        
//                                    }
//                                    if(self?.getVideoId(urlPath: request.path) != self?.nowPlayingId) {
//                                        if(isPriority) {
//                                            //                                        self?.urlSessionsTsPriority?.cancel()
//                                            self?.urlSessionsTsPriority = download
//                                        } else {
//                                            //                                        self?.urlSessionsTsPrepare?.cancel()
//                                            self?.urlSessionsTsPrepare = download
//                                        }
//                                    }
//                                    download.resume()
//                                    
//                                    let date = Date()
//                                    let formatter = DateFormatter()
//                                    formatter.timeZone = TimeZone(abbreviation: "GMT+7:00") //Current time zone
//                                    formatter.dateFormat = "HH:MM:ss"
//                                    let currentTime: String = formatter.string(from: date)
//
//                                    
//                                    self?.queueDownloads.append(updatedUrlOrigin)
//                                    
//                                    //print("====DEBUG-V --TimePerTS STRT  ", self?.getVideoName(urlPath: updatedUrlOrigin) ?? "", "updatedUrlOrigin:", updatedUrlOrigin)
//                                    
//                                }
//                            }
//                            
//                 
//                            
//                            
//                            
//                        }
//                        
//                    }
//                } catch {
//                    self?.backgroundQueue.asyncAfter(deadline: .now() + 0.0003, execute: {
//                        //                        completion(GCDWebServerResponse(statusCode: 500))
//                    })
//                }
//            } else {
//                self?.backgroundQueue.asyncAfter(deadline: .now() + 0.0003, execute: {
//                    //                    completion(GCDWebServerResponse(statusCode: 500))
//                })
//            }
//        }
//    }
//                           
//    private func canDownloadVideo(urlString: String) -> Bool {
//        
//        let priorityId = KKVideoManager.shared.getPriority()
//        
//        //print("**debug-v", "try", urlString, "priorityId", priorityId)
//        
//        if(urlString.contains(priorityId)){
//            //print("====debug-v", "yes", urlString)
//            return true
//        }
//        
//        if(urlString.contains("_000.ts")
//           || urlString.contains("_001.ts")
//           || urlString.contains("_002.ts")
//        ){
//            //print("====debug-v", "yes", urlString)
//            return true
//        }
//        
//        //print("====debug-v", "no", urlString, "priorityId", priorityId)
//        
//        //return false
//        return true // uncomment to by-pass
//        
//    }
//    
//    private func getVideoId(urlPath: String?) -> String {
//        var videoId = ""
//        if let urlPath = urlPath {
//            if urlPath != "" && urlPath != "null" {
//                let pathOfUrl = urlPath.components(separatedBy: "/")
//                videoId = pathOfUrl[pathOfUrl.count-1]
//            }
//        }
//        return videoId
//    }
//    
//    private func isMediaHasHls(feed: Feed) -> Bool {
//        for (_, media) in feed.post!.medias!.enumerated() {
//            if let hlsURL = media.hlsUrl, !hlsURL.isEmpty {
//                return true
//            }
//        }
//        return false
//    }
//    
//    private func isCanPrepareNext() -> Bool {
//        if(ProxyServer.shared.activeId == "PROFILE_SELF" ||
//                  ProxyServer.shared.activeId == "PROFILE_OTHER" ||
//                  ProxyServer.shared.activeId == "EXPLORE"
//        ) {
//            return true
//        }
//        
//        if(ProxyServer.shared.prepareCount >= (self.prepareLimit-1)) {
//            return false
//        }
//        return true
//
////        let tsRegex = ".*ts"
////        if(ProxyServer.shared.nowPlayingId == "nonhls" || ProxyServer.shared.nowPlayingId == ""){
////            //rony, force true, because if previous media is not video, it always false, because no video is playing
////            return true
////        }
//        
////        let curPlaylistUrl = "/" + ProxyServer.shared.nowPlayingId + "/main.m3u8"
////        let curPlaylist = readFile(url: curPlaylistUrl)
////        if(curPlaylist != "") {
////            var downloadedCurPlayingSegments = 0
////            let tsFiles = groups(text: curPlaylist, regexPattern: tsRegex)
////            var loopIndex = minCurPlayingSegments
////            if(tsFiles.count < minCurPlayingSegments) {
////                loopIndex = tsFiles.count
////            }
////            for i in 0..<loopIndex {
////                let tsFile = tsFiles[i][0]
////                if(isFileExist(url: tsFile)) {
////                    downloadedCurPlayingSegments += 1
////                } else {
////                    return false
////                }
////            }
////        } else {
////            return true
////        }
////        return true
//    }
//    
//    public func getNowPlayingId() -> String {
//        return ProxyServer.shared.nowPlayingId
//    }
//
//    public func setNowPlayingId(id: String) {
//        ProxyServer.shared.nowPlayingId = id
//    }
//    
//    public func resetPrepare() {
//        ProxyServer.shared.prepareCount = 0
//    }
//    
//    public func addFeeds(feeds: [Feed], id: String) {
//        if(ProxyServer.shared.feeds.index(forKey: id) == nil) {
//            ProxyServer.shared.feeds[id] = []
//        }
//        ProxyServer.shared.feeds[id]?.append(contentsOf: feeds)
//    }
//    
//    public func checkIfThereIsStillHaveDataInQueue(for id: String) -> Bool {
//        if let feeds = ProxyServer.shared.feeds[id] {
//            let result =  feeds.contains { feed in
//                if let feed = feed, feed.isReadyToShow == true {
//                    return false
//                }
//                return true
//            }
//            return result
//        } else {
//            return false
//        }
//    }
//
//    public func prepareNextVideo(medias: [Medias], feedId: String, id: String) {
//        mediaFinishToProcess = 0
//        for (index, media) in medias.enumerated() {
//            if let hlsUrl = media.hlsUrl, !hlsUrl.isEmpty {
//                let mainPlaylist = "http://127.0.0.1:8080/" + getVideoId(urlPath: hlsUrl) + "/main.m3u8?x=" + hlsUrl + "&priority=false"
//                //trigger download mainplaylist
//                let playlist = readFile(url: changeFileNameUrl(url: hlsUrl, updatedFile: "main.m3u8"))
//                var mainPlaylistLocal = playlist
//                if(playlist == "") {
//                    let url = URL(string: mainPlaylist)!
//                    print("----Downloading.. prepareNextVideo \(url.absoluteString)")
//                    let download = URLSession.shared.downloadTask(with: url) { [self]
//                        urlOrNil, responseOrNil, errorOrNil in
//                        print("----Downloaded prepareNextVideo \(url.absoluteString)")
//                        if(errorOrNil != nil) {
//                        } else {
//                            downloadTs(hlsUrl: hlsUrl, medias: medias, mainPlaylist: mainPlaylist, feedId: feedId, id: id)
//                        }
//                    }
//                    download.resume()
//                } else {
//                    downloadTs(hlsUrl: hlsUrl, medias: medias, mainPlaylist: mainPlaylist, feedId: feedId, id: id)
//                }
//            } else {
//                // if media is not hls
//                updateMediaFinishToProcess(medias: medias, id: id, feedId: feedId)
//            }
//        }
//    }
//        
//    private func downloadTs(hlsUrl: String, medias: [Medias], mainPlaylist: String, feedId: String, id: String) {
//        let mainPlaylistLocal = self.readFile(url: self.changeFileNameUrl(url: hlsUrl, updatedFile: "main.m3u8"))
//        let tsRegex = ".*ts"
//        let tsFiles = self.groups(text: mainPlaylistLocal, regexPattern: tsRegex)
//
//        var tsProcessed = 0
//        var tsComplete = 0
//        var maxTs = self.maxTsSegmentToPrepare
//        if(self.activeId == "PROFILE_OTHER" || self.activeId == "PROFILE_SELF" || self.activeId == "EXPLORE") {
//            maxTs = 1
//        }
//        if(tsFiles.count < self.maxTsSegmentToPrepare) {
//            maxTs = tsFiles.count
//        }
//        if(maxTs == 0) {
//            updateMediaFinishToProcess(medias: medias, id: id, feedId: feedId)
//        }
//        for (_, tsFile) in tsFiles.enumerated() {
//            if(tsProcessed < maxTs) {
//                let tsUrlStrOriginal = "http://127.0.0.1:8080/" + self.getVideoId(urlPath: hlsUrl) + "/" + tsFile.first!
//                let tsUrlStr =  tsUrlStrOriginal + "?priority=false"
//                if(!self.isFileExist(url: tsUrlStr)) {
//                    let tsUrl = URL(string: tsUrlStr)!
//                    print("----Downloading.. downloadTS \(tsUrl.absoluteString), id: \(id)")
//                    let downloadTs = URLSession.shared.downloadTask(with: tsUrl) {[self] url, urlresponse, error in
//                        //print("----Downloaded downloadTS \(tsUrl.absoluteString)")
//
//                        if error == nil {
//                            print("----Downloaded downloadTS \(tsUrl.absoluteString)")
//                            
//                            tsComplete += 1
//                            if(tsComplete == maxTs) {
//                                updateMediaFinishToProcess(medias: medias, id: id, feedId: feedId)
//                            }
//                        } else {
//                            print("----Download ERROR downloadTS \(tsUrl.absoluteString)", error)
//                        }
//                    }
//                    downloadTs.resume()
//                } else {
//                    tsComplete += 1
//                    if(tsComplete == maxTs) {
//                        updateMediaFinishToProcess(medias: medias, id: id, feedId: feedId)
//                    }
//                }
//            }
//            tsProcessed += 1
//        }
//    }
//    
//    private func updateMediaFinishToProcess(medias: [Medias], id: String, feedId: String) {
//        mediaFinishToProcess += 1
//        if(mediaFinishToProcess >= medias.count) {
//            if let _ = ProxyServer.shared.feeds[id] {
//                //print("----Downloading isReadyToShow data for URL \(tsUrl.absoluteString)")
//
//                let index = ProxyServer.shared.feeds[id]?.firstIndex(where: {$0?.id == feedId && $0?.isReadyToShow != true})
//
//                if let feeds = ProxyServer.shared.feeds[id], !feeds.isEmpty {
//                    ProxyServer.shared.feeds[id]?[index ?? 0]?.isReadyToShow = true
//                    if let feed = feeds[index ?? 0] {
//                        let sessionName = sessionNameIsPrepareFinish + "_" + (feed.id ?? "")
//                        if(index != nil) {
//                            ProxyServer.shared.prepareCount += 1
//                            NotificationCenter.default.post(name: .notifyReadyFeedKey, object: [id: feed])
//                        }
//                    }
//                }
//            }
//        }
//
//    }
//
//    private func preferredTsQuality(url: String, isPriority: Bool) -> String {
//        var result = url
//        let originPlaylist = readFile(url: changeFileNameUrl(url: url, updatedFile: getVideoId(urlPath: url) + ".m3u8"))
//        let bandwidthRegex = "BANDWIDTH=.*[0-9],AVERAGE"
//        let numberRegex = "[0-9]{1,20}"
//        let bandwidthFilter = groups(text: originPlaylist, regexPattern: bandwidthRegex)
//        let bandwidths = groups(text: bandwidthFilter.joined().joined(), regexPattern: numberRegex).reversed()
//
////        var bandwidthSelectedIndex = 0
//        let bandwithPercentage = isPriority ? prioritySpeedPercentage : 100 - prioritySpeedPercentage
//        
//        let averageDownloadSpeed = movingAverage.addSample(value: Double(downloadSpeed))
//        
//        let maxSpeed:Double = Double(averageDownloadSpeed) * (Double(bandwithPercentage) / 100)
////        var bandwithSelected: Double = 0
//        
//        //print("**--TimePerTS AFAS bandwidths \(bandwidths)")
////        for (index, bandwithStr) in bandwidths.enumerated() {
////            if let bandwithFirst = bandwithStr.first {
////                if let bandwith = Double(bandwithFirst) {
////                    print("**--TimePerTS AFAS OUT Selected bandwith \(bandwithSelected) index \(bandwidthSelectedIndex) band \(bandwith)")
////                    print("**--TimePerTS AFAS OUT bandwith < maxSpeed \(bandwith < maxSpeed) bandwithSelected < bandwith \(bandwithSelected < bandwith)")
////
////                    if(bandwith < maxSpeed) && bandwithSelected < bandwith {
////                        bandwithSelected = bandwith
////                        bandwidthSelectedIndex = index
////                        print("**--TimePerTS AFAS Selected bandwith \(bandwithSelected) index \(bandwidthSelectedIndex)")
////                    }
////                }
////            }
////        }
////        print("**--TimePerTS AFAS SPEEDY MaxSpeed \(maxSpeed) bandwidths \(bandwithSelected) selected \(bandwidthSelectedIndex)")
//
//        let m3u8Regex = ".*[0-9]p.m3u8"
//        let playlists = groups(text: originPlaylist, regexPattern: m3u8Regex)
//        var selectedQuality = playlists[0].first
//        
//        switch maxSpeed {
//        case 100_000...1_000_000_000:
//            selectedQuality = playlists.last?.first
//        case 70_000...99_999:
//            if playlists.count >= 3 {
//                selectedQuality = playlists[playlists.count - 2].first
//                break
//            }
//            fallthrough
//        case 50_000...69_999:
//            if playlists.count >= 4 {
//                selectedQuality = playlists[playlists.count - 3].first
//                break
//            }
//            fallthrough
//        default:
//            selectedQuality = playlists.first?.first
//        }
//        
//        let tsOrderedNumber = url.components(separatedBy: "_").last ?? ""
//        let qualityName = selectedQuality?.replacingOccurrences(of: ".m3u8", with: "") ?? ""
//        let selectedTsFileName = getVideoId(urlPath: url) + "_" + qualityName + "_" + tsOrderedNumber
//        result = selectedTsFileName
//        //print("**--TimePerTS", ": \(String(format: "%.1f", self.downloadTimePerTS)) s","byte:\(self.downloadBytePerTS / 1000) Kb" ,"speed:\(downloadSpeed / 1000) Kbps, " + selectedTsFileName + ", priority:\(isPriority)")
//        return result
//    }
//    
//    private func changeFileNameUrl(url: String, updatedFile: String) -> String {
//        let lastPath = url.components(separatedBy: "/").last ?? ""
//        let updatedUrl = url.replacingOccurrences(of: lastPath, with: updatedFile)
//        let final = String(updatedUrl.filter { !" \n\t\r".contains($0) })
//        return final
//    }
//
//    private func createLocalMainPlaylist(url: String, completion: @escaping GCDWebServerCompletionBlock) {
//        // download main playlists
//        let mainPlaylist = URL(string: url)!
//        let download = URLSession.shared.downloadTask(with: mainPlaylist) {
//            urlOrNil, responseOrNil, errorOrNil in
//            
//            guard let fileURL = urlOrNil else {
//                return
//            }
//            
//            self.writeFromUrlToFile(urlPath: url, updatedName: nil, fileURL: fileURL)
//            self.composeLocalMainPlaylist(url: url, completion: completion)
//        }
//        download.resume()
//    }
//    
//    private func composeLocalMainPlaylist(url: String, completion: @escaping GCDWebServerCompletionBlock) {
//        let mainPlaylist = readFile(url: url)
//        if(mainPlaylist.contains("<?xml")) {
//            completion(GCDWebServerResponse(statusCode: 408))
//        } else {
//            downloadAllPlaylistFromMainPlaylist(mainPlaylist: mainPlaylist, url: url, completion: completion)
//        }
//    }
//        
//    private func writeFromUrlToFile(urlPath: String, updatedName: String?, fileURL: URL) {
//        var lastPathOfUrl = urlPath.components(separatedBy: "/").last
//        if(updatedName != nil) {
//            lastPathOfUrl = updatedName
//        }
//        let savedPathUrl = getVideoId(urlPath: urlPath) + "/" + lastPathOfUrl!
//        
//       do {
//            let documentsURL = try
//                FileManager.default.url(for: .documentDirectory,
//                                        in: .userDomainMask,
//                                        appropriateFor: nil,
//                                        create: false)
//            let savedURL = documentsURL.appendingPathComponent(savedPathUrl)
//
//            let targetDir = savedURL.deletingLastPathComponent()
//            var isDirectory : ObjCBool = true
//            if FileManager.default.fileExists(atPath: targetDir.path, isDirectory: &isDirectory) {
//                if(!isDirectory.boolValue) {
//                    print("exist but not directory, creating dir")
//                    try FileManager.default.createDirectory(at:targetDir, withIntermediateDirectories: true, attributes: nil)
//                }
//            } else {
//                //print("directory not exist, creating dir \(targetDir)")
//                try FileManager.default.createDirectory(at:targetDir, withIntermediateDirectories: true, attributes: nil)
//            }
//
//            if FileManager.default.fileExists(atPath: savedURL.path, isDirectory: &isDirectory) {
//                if(isDirectory.boolValue) {
//                    print("exist but not a file, creating file")
//                    try FileManager.default.moveItem(at: fileURL, to: savedURL)
//                }
//            } else {
//                if(savedURL.absoluteString.contains(".ts")){
//                    let savedURLSplits = savedURL.absoluteString.split(separator: "/")
//                    
//                    let savedURLMinimize = savedURLSplits[savedURLSplits.count - 1]
//                    
//                    //print("--created \(savedURLMinimize)")
//                }
//                
//                try FileManager.default.moveItem(at: fileURL, to: savedURL)
//            }
//        } catch {
//            //error
//        }
//    }
//    
//    private func downloadAllPlaylistFromMainPlaylist(mainPlaylist: String, url: String, completion: @escaping GCDWebServerCompletionBlock) {
//        let m3u8Regex = ".*[0-9]p.m3u8"
//        let playlists = groups(text: mainPlaylist, regexPattern: m3u8Regex)
//        var processed = 0
//        let playlist = playlists.first
//        if(playlist != nil) {
//            guard let playlistUrl = URL(string: changeFileNameUrl(url: url, updatedFile: playlist!.first!)) else { return }
//            let download = URLSession.shared.downloadTask(with: playlistUrl) {
//                urlOrNil, responseOrNil, errorOrNil in
//                
//                guard let fileURL = urlOrNil else {
//                    return
//                }
//
//                self.writeFromUrlToFile(urlPath: playlistUrl.path, updatedName: nil, fileURL: fileURL)
//                self.createMain(playlists: playlists, url: url, completion: completion)
//            }
//            download.resume()
//        }
//    }
//    
//    private func createMain(playlists: [[String]], url: String, completion: @escaping GCDWebServerCompletionBlock) {
//        let firstPlaylist = playlists.first?.first
//        if(firstPlaylist != nil) {
//            let mainLocalPlaylist = readFile(url: changeFileNameUrl(url: url, updatedFile: firstPlaylist!))
//            writeFile(content: mainLocalPlaylist, url: changeFileNameUrl(url: url, updatedFile: "main.m3u8"))
//            var data = Data(mainLocalPlaylist.utf8)
//            let contentType = "application/x-mpegurl"
//            completion(GCDWebServerDataResponse(data: data, contentType: contentType))
//        }
//    }
//    
//    func deleteFile(url: String) {
//        let lastPathOfUrl = url.components(separatedBy: "/").last
//        let savedPathUrl = getVideoId(urlPath: url) + "/" + lastPathOfUrl!
//        
//        do {
//            let documentsURL = try
//                FileManager.default.url(for: .documentDirectory,
//                                        in: .userDomainMask,
//                                        appropriateFor: nil,
//                                        create: false)
//            let savedURL = documentsURL.appendingPathComponent(savedPathUrl)
//            try FileManager.default.removeItem(at: savedURL)
//        } catch {
//            print ("file error: \(error)")
//        }
//    }
//    
//    func writeFile(content: String, url: String) {
//        let lastPathOfUrl = url.components(separatedBy: "/").last
//        let savedPathUrl = getVideoId(urlPath: url) + "/" + lastPathOfUrl!
//        
//        do {
//            let documentsURL = try
//                FileManager.default.url(for: .documentDirectory,
//                                        in: .userDomainMask,
//                                        appropriateFor: nil,
//                                        create: false)
//            let savedURL = documentsURL.appendingPathComponent(savedPathUrl)
//            if let stringData = content.data(using: .utf8) {
//                try stringData.write(to: savedURL)
//            }
//        } catch {
//            print ("file error: \(error)")
//        }
//    }
//    
//    private func isFileExist(url: String) -> Bool {
//        do {
//            let lastPathOfUrl = url.components(separatedBy: "/").last
//            let path = getVideoId(urlPath: url) + "/" + lastPathOfUrl!
//            let documentsURL = try
//                FileManager.default.url(for: .documentDirectory,
//                                        in: .userDomainMask,
//                                        appropriateFor: nil,
//                                        create: false)
//            let checkedPath = documentsURL.appendingPathComponent(path)
//            if FileManager.default.fileExists(atPath: checkedPath.path) {
//                return true
//            }
//        } catch {
//            print(error)
//        }
//        return false
//    }
//    
//    private func toLocalPath(url: String) -> URL {
//        var localPath = URL(string: "")
//        do {
//            let lastPathOfUrl = url.components(separatedBy: "/").last
//            let path = getVideoId(urlPath: url) + "/" + lastPathOfUrl!
//            let documentsURL = try
//                FileManager.default.url(for: .documentDirectory,
//                                        in: .userDomainMask,
//                                        appropriateFor: nil,
//                                        create: false)
//            localPath = documentsURL.appendingPathComponent(path)
//        } catch {
//            print(error)
//        }
//        return localPath!
//    }
//
//    public func readFile(url: String) -> String {
//        let lastPathOfUrl = url.components(separatedBy: "/").last
//        let savedPathUrl = getVideoId(urlPath: url) + "/" + lastPathOfUrl!
//        var result = ""
//        
//        do {
//            let documentsURL = try
//                FileManager.default.url(for: .documentDirectory,
//                                        in: .userDomainMask,
//                                        appropriateFor: nil,
//                                        create: false)
//            let savedURL = documentsURL.appendingPathComponent(savedPathUrl)
//            result = try String(contentsOf: savedURL)
//        } catch {
//            // file not found
//        }
//        return result
//    }
//    
//    public func getVideoId(urlPath: String) -> String {
//        var pathOfUrl = urlPath.components(separatedBy: "/")
//        var videoId = ""
//        if(pathOfUrl.count == 1) {
//            pathOfUrl = urlPath.components(separatedBy: "_")
//            videoId = pathOfUrl[0]
//        } else {
//            videoId = pathOfUrl[pathOfUrl.count-2]
//        }
//        return videoId
//    }
//
//    public func getVideoName(urlPath: String) -> String {
//        var pathOfUrl = urlPath.components(separatedBy: "/")
//        var videoId = ""
//        if(pathOfUrl.count == 1) {
//            pathOfUrl = urlPath.components(separatedBy: "_")
//            videoId = pathOfUrl[0]
//        } else {
//            videoId = pathOfUrl[pathOfUrl.count-1]
//        }
//        return videoId
//    }
//    open func stop() {
//        guard self.webServer.isRunning else { return }
//        self.webServer.stop()
//        print("proxy stopped")
//      }
//    
//    private func groups(text: String, regexPattern: String) -> [[String]] {
//        do {
//            let regex = try NSRegularExpression(pattern: regexPattern)
//            let matches = regex.matches(in: text,
//                                        range: NSRange(text.startIndex..., in: text))
//            return matches.map { match in
//                return (0..<match.numberOfRanges).map {
//                    let rangeBounds = match.range(at: $0)
//                    guard let range = Range(rangeBounds, in: text) else {
//                        return ""
//                    }
//                    return String(text[range])
//                }
//            }
//        } catch let error {
//            print("invalid regex: \(error.localizedDescription)")
//            return []
//        }
//    }    
//}
//
//extension FileManager {
//    func moveItem(at url: URL, toUrl: URL, completion: @escaping (Bool, Error?) -> ()) {
//        DispatchQueue.global(qos: .utility).async {
//
//            do {
//                try self.moveItem(at: url, to: toUrl)
//            } catch {
//                // Pass false and error to completion when fails
//                DispatchQueue.main.async {
//                   completion(false, error)
//                }
//            }
//
//            // Pass true to completion when succeeds
//            DispatchQueue.main.async {
//                completion(true, nil)
//            }
//        }
//    }
//}
