//import GCDWebServer
//import Foundation
//
//open class HLSCachingProxy {
//    static let originURLKey = "__hls_origin_url"
//    
//    private let webServer: GCDWebServer
//    private let urlSession: URLSession
//    private var cache: DataCache!
//
//    private(set) var port: Int?
//    
//    var internetSpeedInKB = Double(1000)
//    var downloadTime = Double(0) // use to determine if internet speed slow or fast
//    
//    private let internetSpeedKey = "internetSpeedKey"
//    var IS_THROTTLE = true
//    
//    var queueDownload = 0
//    private var urlSessionsTs = [String: URLSessionDataTask]()
//    private var urlSessionsM3u8 = [String: URLSessionDataTask]()
//
//    private var beforeVideoId = "";
//    let backgroundQueue = DispatchQueue(label: "com.app.kipaskipas.queue", qos: .background)
//    
//    let MAX_QUEUE_DOWNLOAD = 6
//    
//    public init(webServer: GCDWebServer, urlSession: URLSession, cache: DataCache) {
//        self.webServer = webServer
//        self.urlSession = urlSession
//        self.cache = cache
//        self.addRequestHandlers()
//    }
//    
//    
//    // MARK: Starting and Stopping Server
//    
//    open func start(port: UInt) {
//        guard !self.webServer.isRunning else { return }
//        self.port = Int(port)
//        self.webServer.start(withPort: port, bonjourName: nil)
//        
//        
//        print("====== IS_THROTTLE", IS_THROTTLE)
//        
//    }
//    
//    open func stop() {
//        guard self.webServer.isRunning else { return }
//        self.port = nil
//        self.webServer.stop()
//    }
//    
//
//    
//    // MARK: Resource URL
//    
//    open func reverseProxyURL(from originURL: URL) -> URL? {
//        guard let port = self.port else { return nil }
//        
//        guard var components = URLComponents(url: originURL, resolvingAgainstBaseURL: false) else { return nil }
//        components.scheme = "http"
//        components.host = "127.0.0.1"
//        components.port = port
//        
//        let originURLQueryItem = URLQueryItem(name: Self.originURLKey, value: originURL.absoluteString)
//        components.queryItems = (components.queryItems ?? []) + [originURLQueryItem]
//        
//        return components.url
//    }
//    
//    
//    // MARK: Request Handler
//    
//    private func addRequestHandlers() {
//        self.addPlaylistHandler()
//        self.addSegmentHandler()
//    }
//    
//    private func addPlaylistHandler() {
//        self.webServer.addHandler(forMethod: "GET", pathRegex: "^/.*\\.m3u8$", request: GCDWebServerRequest.self) { [weak self] request, completion in
//            guard let self = self else {
//                return completion(GCDWebServerDataResponse(statusCode: 500))
//            }
//            
//            guard let originURL = self.originURL(from: request) else {
//                return completion(GCDWebServerErrorResponse(statusCode: 400))
//            }
//            
//            let task = self.urlSession.dataTask(with: originURL) { data, response, error in
//                guard let data = data, let response = response else {
//                    return completion(GCDWebServerErrorResponse(statusCode: 500))
//                }
//                //print("=====data", data)
//                let playlistData = self.reverseProxyPlaylist(with: data, forOriginURL: originURL)
//                let contentType = response.mimeType ?? "application/x-mpegurl"
//                completion(GCDWebServerDataResponse(data: playlistData, contentType: contentType))
//            }
//            
//            task.resume()
//        }
//    }
//    
//    private func addSegmentHandler() {
//        self.webServer.addHandler(forMethod: "GET", pathRegex: "^/.*\\.ts$", request: GCDWebServerRequest.self) { [weak self] request, completion in
//            
//            //let internetSpeed = self?.internetSpeed
//    
//            if(KKVideoCache.shared.priorityVideoId != self?.beforeVideoId && self?.beforeVideoId != "") {
//                self?.cancelAllSessionsTs()
//            }
//            self?.beforeVideoId = KKVideoCache.shared.priorityVideoId
//
//            
//            guard let self = self else {
//                return completion(GCDWebServerDataResponse(statusCode: 500))
//            }
//            
//            guard let originURL = self.originURL(from: request) else {
//                return completion(GCDWebServerErrorResponse(statusCode: 400))
//            }
//            
//            
//            let priorityVideoId = KKVideoCache.shared.priorityVideoId
//            
//            var priority:Float = 0.0
//
//            let mediaNameCache = TSCacheProvider.shared.getMediaName(url: originURL.absoluteString)
//            let mediaName = mediaNameCache.mediaName
//            
//            //print("===mediaName:", mediaName, " priorityVideoId", priorityVideoId)
//
//            if(priorityVideoId != ""){
//                if(mediaName == priorityVideoId){
//                    priority = 1.0
//                    //print("===mediaName:", mediaName, " IS priority")
//                }
//            }
//
//            var newResolution = ""
//            
//            if(self.IS_THROTTLE){
////                if(self.internetSpeedInKB < 150){
////                    newResolution = KKVideoResolution.P480.rawValue
////                } else if(self.internetSpeedInKB < 300){
////                    newResolution = KKVideoResolution.P720.rawValue
////                } else {
////                    newResolution =  TSCacheProvider.shared.getPlaylistMax(mediaName: mediaName)
////                }
//                
//                if(self.downloadTime < 0.6){
//                    newResolution =  TSCacheProvider.shared.getPlaylistMax(mediaName: mediaName)
//                } else if(self.downloadTime < 1){
//                    newResolution = KKVideoResolution.P720.rawValue
//                } else {
//                    newResolution = KKVideoResolution.P480.rawValue
//                }
//                
//                if((originURL.absoluteString.contains("000.ts")) || (originURL.absoluteString.contains("001.ts"))){
//                    //print("=== originURL.absoluteString contains 0 or 1 TS ", originURL.absoluteString)
//                    newResolution = ""
//                }
//            }
//            
//            //print("====== newResolution", mediaName, newResolution)
//            let urlConvert = TSCacheProvider.shared.convertSegmentTo(url: originURL.absoluteString, newResolution: newResolution)
//                                    
//            
//            //print("===proxy queue:", self.queueDownload)
//            
//            TSCacheProvider.shared.find(url: urlConvert, completionHasCache: { hasCache, tsCache in
//                if(hasCache){
//
//                    if let cachedData = self.cachedData(for: URL(string: tsCache.url)!) {
//                        print("okesips zsss if")
//                        return completion(GCDWebServerDataResponse(data: cachedData, contentType: "video/mp2t"))
//                    } else {
//                        print("=== okesips zss ALERT cacheData, not found urlConvert:\(urlConvert.suffix(25)) tsCache.url:\(tsCache.url.suffix(25))")
//
//                        // by physic, object is not found, so remove from cache list..
//                        TSCacheProvider.shared.delete(url: tsCache.url)
//                        return completion(GCDWebServerErrorResponse(statusCode: 500))
//                    }
//                } else {
//                    print("okesips zsss else")
//
////                    if( priority < 1 ) {
////                        if( (tsCache.segment == "000.ts") || (tsCache.segment == "001.ts")){
////                            //print("===mediaName:", mediaName, " priority NO, but head TS")
////                        } else {
////                            //print("===mediaName:", mediaName, tsCache.segment," discard")
////                            return completion(GCDWebServerErrorResponse(statusCode: 500))
////                        }
////                    }
////                    else {
////                        //print("===mediaName:", mediaName, " priority YES")
////                    }
//                    
//                    // ignore if already downloading
//                    if(self.chunkIsDownloading(url: tsCache.url)){
//                        print("=== chunkDownload Already downloading, Ignore", tsCache.url)
//                        return completion(GCDWebServerErrorResponse(statusCode: 500))
//                    } else {
//                        
////                        if(self.queueDownload >= self.MAX_QUEUE_DOWNLOAD){
////                            print("okesips zsss 1")
////                            return completion(GCDWebServerErrorResponse(statusCode: 500))
////                        }
//
//                        //print("=== chunkDownload WRITE ", tsCache.url)
//                        //print("=== chunkDownload Will download", tsCache.url)
//                        DataCache.instance.write(string: tsCache.url, forKey: self.KEY_DOWNLOAD + tsCache.url)
//                        
//                        self.queueDownload = self.queueDownload + 1
//                    }
//                                        
//                    //print("====proxy orig: \(originURL.absoluteString.suffix(25)), conv:\(urlConvert.suffix(25))", "speed \(String(format: "%.0f", self.internetSpeed))")
//
//                    let startTime = CFAbsoluteTimeGetCurrent()
//                    let task = self.urlSession.dataTask(with: URL(string: urlConvert)!) { data, response, error in
//                        guard let data = data, let response = response else {
//                            return completion(GCDWebServerErrorResponse(statusCode: 500))
//                        }
//                        
//                        let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime
//                        
//                        let sizeData = response.expectedContentLength
//                        
//                        let avg = Double(sizeData) / Double(timeElapsed)
//                        let avgKb =  avg / 1000
//                        
//                        self.downloadTime = timeElapsed
//                        
//                        let timeElapsedString = String(format: "%.1f", timeElapsed)
//                        self.internetSpeedInKB = avgKb
//                        
//                        
//                        let isConvert = originURL.absoluteString == urlConvert ? "no-change" : urlConvert.suffix(25)
//
//                        self.queueDownload = self.queueDownload - 1
//                        
//                        print("===proxy chunkDownload orig:\(originURL.absoluteString.suffix(25))", "queue:", self.queueDownload,"time:", timeElapsedString, " size:\(sizeData/1000) kb", " debug-inet speed:\(String(format: "%.0f", self.internetSpeedInKB))" , isConvert)
//                        
//                        TSCacheProvider.shared.add(url: urlConvert)
//                        self.saveCacheData(data, for: URL(string: urlConvert)!)
//                        
//                        //print("=== chunkDownload DELETE", tsCache.url)
//                        DataCache.instance.clean(byKey: self.KEY_DOWNLOAD + urlConvert)
//                        
//                        let contentType = response.mimeType ?? "video/mp2t"
//                        completion(GCDWebServerDataResponse(data: data, contentType: contentType))
//                    }
//                    task.priority = priority
//                    
//                    self.urlSessionsTs[originURL.path] = task
//                    task.resume()
//                }
//            })
//        }
//    }
//    
//    private func originURL(from request: GCDWebServerRequest) -> URL? {
//        guard let encodedURLString = request.query?[Self.originURLKey] else { return nil }
//        guard let urlString = encodedURLString.removingPercentEncoding else { return nil }
//        let url = URL(string: urlString)
//        return url
//    }
//    
//    
//    // MARK: Manipulating Playlist
//    
//    private func reverseProxyPlaylist(with data: Data, forOriginURL originURL: URL) -> Data {
//
//        //print("====outputStr", outputStr)
//        
//        var playlists = [String]()
//                
//        String(data: data, encoding: .utf8)!
//            .components(separatedBy: .newlines)
//            .map { line in
//                if line.contains(".m3u8") {
//                    let playlist = line.replacingOccurrences(of: ".m3u8", with: "")
//
//                    playlists.append(playlist)
//                    //print("====== playlist: ", originURL.absoluteString, line)
//                }
//            }
//        
//        if(playlists.count > 0){
//            
//            //print("====== playlists: ", originURL.absoluteString, playlists[playlists.count - 1])
//
//            let mediaSegments = originURL.absoluteString.split(separator: "/")
//            let mediaNameFull = mediaSegments[mediaSegments.count - 1]
//            let mediaName = mediaNameFull.replacingOccurrences(of: ".m3u8", with: "")
//            
//            //print("==== ediaName-save", mediaName)
//            
//            TSCacheProvider.shared.setPlaylistMax(mediaName: mediaName, playlists: playlists[playlists.count - 1])
//        }
//        
//        return String(data: data, encoding: .utf8)!
//            .components(separatedBy: .newlines)
//            .map { line in self.processPlaylistLine(line, forOriginURL: originURL) }
//            .joined(separator: "\n")
//            .data(using: .utf8)!
//    }
//    
//    private func processPlaylistLine(_ line: String, forOriginURL originURL: URL) -> String {
//        guard !line.isEmpty else { return line }
//        
//        if line.hasPrefix("#") {
//            return self.lineByReplacingURI(line: line, forOriginURL: originURL)
//        }
//        
//        if let originalSegmentURL = self.absoluteURL(from: line, forOriginURL: originURL),
//           let reverseProxyURL = self.reverseProxyURL(from: originalSegmentURL) {
//            return reverseProxyURL.absoluteString
//        }
//        
//        return line
//    }
//    
//    private func lineByReplacingURI(line: String, forOriginURL originURL: URL) -> String {
//        let uriPattern = try! NSRegularExpression(pattern: "URI=\"(.*)\"")
//        let lineRange = NSMakeRange(0, line.count)
//        guard let result = uriPattern.firstMatch(in: line, options: [], range: lineRange) else { return line }
//        
//        let uri = (line as NSString).substring(with: result.range(at: 1))
//        guard let absoluteURL = self.absoluteURL(from: uri, forOriginURL: originURL) else { return line }
//        guard let reverseProxyURL = self.reverseProxyURL(from: absoluteURL) else { return line }
//        
//        return uriPattern.stringByReplacingMatches(in: line, options: [], range: lineRange, withTemplate: "URI=\"\(reverseProxyURL.absoluteString)\"")
//    }
//    
//    private func absoluteURL(from line: String, forOriginURL originURL: URL) -> URL? {
//        guard ["m3u8", "ts"].contains(originURL.pathExtension) else { return nil }
//        
//        if line.hasPrefix("http://") || line.hasPrefix("https://") {
//            return URL(string: line)
//        }
//        
//        guard let scheme = originURL.scheme, let host = originURL.host else { return nil }
//        
//        let path: String
//        if line.hasPrefix("/") {
//            path = line
//        } else {
//            path = originURL.deletingLastPathComponent().appendingPathComponent(line).path
//        }
//        
//        return URL(string: scheme + "://" + host + path)?.standardized
//    }
//    
//    
//    // MARK: Caching
//    
//    private func cachedData(for resourceURL: URL) -> Data? {
//        let key = self.cacheKey(for: resourceURL)
//        //return self.cache.object(forKey: key) as? Data
//        return self.cache.readData(forKey: key)
//
//    }
//    
//    private func saveCacheData(_ data: Data, for resourceURL: URL) {
//        let key = self.cacheKey(for: resourceURL)
//        //self.cache.setObject(data, forKey: key)
//        self.cache.write(data: data, forKey: key)
//
//    }
//    
//    private func cacheKey(for resourceURL: URL) -> String {
//        return resourceURL.absoluteString.data(using: .utf8)!.base64EncodedString()
//    }
//    
//    let KEY_DOWNLOAD = "DOWNLOAD_"
//    private func chunkIsDownloading(url: String) -> Bool{
//        
//        let key = KEY_DOWNLOAD + url
//            
//        let chunkCache = DataCache.instance.readString(forKey: key)
//        
//        if(chunkCache == nil){
//            return false
//        }
//        
//        return true
//    }
//    
//    private func cancelAllSessionsTs() {
//        urlSessionsTs.forEach { (key: String, value: URLSessionDataTask) in
//            if(KKVideoCache.shared.priorityVideoId != KKVideoCache.shared.getVideoId(urlPath: key)){
//                print("okesips zs cancel ts ", key)
//                value.cancel()
//                urlSessionsTs[key] = nil
//            } else {
//                print("okesips zs cancel no")
//            }
//        }
//    }
//}
