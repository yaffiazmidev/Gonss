//
//  KKDownloadTask.swift
//  DesignKit
//
//  Created by koanba on 27/05/23.
//
import Alamofire
import AVFoundation

public class SessionDownloadTask {
    var id:String
    var task:DataRequest?
    var startByte:Int
    var endByte:Int
    var urlSessions:Session
    var startTime:Date
    
    
    init(id: String, task: DataRequest, startByte: Int, endByte: Int, urlSessions: Session, startTime: Date) {
        self.id = id
        self.task = task
        self.startByte = startByte
        self.endByte = endByte
        self.urlSessions = urlSessions
        self.startTime = startTime
    }
}

public class MediaInfo {
    var id:String
    var size:Int64
    var duration:Double
    var kbps:Int
    var urlToDownload:URL
    
    init(id: String, kbps: Int, duration: Double, urlToDownload: URL, size: Int64 = 9999999) {
        self.id = id
        self.duration = duration
        self.urlToDownload = urlToDownload
        self.kbps = kbps
        self.size = size
    }
}

public class KKDownloadTask:NSObject {
    public static let instance = KKDownloadTask()

    var sessions = [String:SessionDownloadTask]()
    var mediaInfoList = [String:MediaInfo]()
    
    let LOG_ID = "KKDownloadTask"
    
    func download(request: URLRequest, isLowRes: Bool, isFromPreload: Bool = false, isFromError: Bool = false, completionHandler: @escaping (AFDataResponse<Data?>) -> Void) -> Void {
        let id = KKResourceHelper.instance.getVideoId(urlPath: request.url?.absoluteString ?? "")
        let downloadTask = KKDownloadTask.instance.sessions[id]
        if(downloadTask == nil || Date().timeIntervalSince1970 - (downloadTask?.startTime ?? Date()).timeIntervalSince1970 > 5) {
            
            print(self.LOG_ID, "download ", id)

            
            var request = request
            let range = request.value(forHTTPHeaderField: "Range")?.replacingOccurrences(of: "bytes=", with: "")
            let rangeSplit = range?.split(separator: "-")
            let startByte = Int(rangeSplit?[0] ?? "-1") ?? -1
            var endByte = -1
            if(rangeSplit?.count ?? 0 > 1) {
                endByte = Int(rangeSplit?[1] ?? "-") ?? -1
            }
            var urlSession = createURLSession()
            let task = urlSession.request(request).onURLSessionTaskCreation(perform: { task in
                task.priority = 1.0
            }).response(completionHandler: completionHandler)
            let session = SessionDownloadTask(id: id, task: task, startByte: startByte, endByte: endByte, urlSessions: urlSession, startTime: Date())
            KKDownloadTask.instance.sessions[id]?.task?.cancel()
            KKDownloadTask.instance.sessions.removeValue(forKey: id)
            KKDownloadTask.instance.sessions[id] = session
            KKDownloadTask.instance.sessions[id]?.task?.resume()
        }
    }
    
    func createURLSession() -> Session {
        let config = URLSessionConfiguration.af.default
        config.timeoutIntervalForRequest = 10.0
        config.timeoutIntervalForResource = 10.0
        config.requestCachePolicy = .useProtocolCachePolicy
        config.tlsMinimumSupportedProtocolVersion = .TLSv13
        config.waitsForConnectivity = true
        config.multipathServiceType = .interactive
        config.httpMaximumConnectionsPerHost = 1_000_000
        config.allowsConstrainedNetworkAccess = true
        config.networkServiceType = .video
        return Session(configuration: config)
    }
    
    
    func getDownloadInfo(url: URL, videoId: String, retry: Int = 0, completion: @escaping () -> ()) {
        print(self.LOG_ID, "getDownloadInfo-1", videoId, "retry:", retry)
        if(url.absoluteString != "" && retry < 2) {
            var mediaInfo = KKDownloadTask.instance.mediaInfoList[videoId]
            if(mediaInfo == nil) {
                let urlToDownload = KKResourceHelper.instance.changeToH265(urlStr: url.absoluteString)
                mediaInfo = MediaInfo(id: videoId, kbps: 0, duration: 0, urlToDownload: urlToDownload, size: 0)
                KKDownloadTask.instance.mediaInfoList[videoId] = mediaInfo
            }
        
            print(self.LOG_ID, "getDownloadInfo-2", videoId,  "size:", KKDownloadTask.instance.mediaInfoList[videoId]!.size)
            
            if(KKDownloadTask.instance.mediaInfoList[videoId]!.size == 0) {
                print(self.LOG_ID, "getDownloadInfo-3", videoId)
                var request = URLRequest(url: mediaInfo!.urlToDownload)
                request.httpMethod = "HEAD"
                let task = URLSession.shared.downloadTask(with: request) { (data, response, error) in
                    
                    
                    
                    var contentLength = response?.expectedContentLength ?? -1
                    let statusCode = (response as? HTTPURLResponse)?.statusCode
                    let mimeType = response?.mimeType ?? ""
                    
                    print(self.LOG_ID, "getDownloadInfo-4", videoId, "statusCode:", statusCode ?? 0, "contentLength:", contentLength )
                    
                    if( statusCode == nil || (statusCode != 200 && statusCode != 206 && contentLength != -1)) {
                        print(self.LOG_ID, "getDownloadInfo-4-retry", videoId)
                        KKDownloadTask.instance.mediaInfoList[videoId]?.urlToDownload = url
                        self.getDownloadInfo(url: url, videoId: videoId, retry: retry+1, completion: completion)
                    }
                    
                    if(contentLength > 0) {
                        if let _ = KKDownloadTask.instance.mediaInfoList[videoId] {
                            print(self.LOG_ID, "getDownloadInfo-5", videoId, "contentLength:", contentLength)
                            KKDownloadTask.instance.mediaInfoList[videoId]?.size = contentLength
                            completion()
                        }
                    }
                }
                task.resume()
            } else {
                completion()
            }
        } else {
            completion()
        }
    }
        
    func parseXml(pattern: String, dataStr: String) -> String {
        var result = ""
        do {
            let regex = try NSRegularExpression(pattern: pattern, options: .caseInsensitive)
            let matches = regex.matches(in: dataStr, options: [], range: NSRange(location: 0, length: dataStr.utf16.count))
            for match in matches {
                if let range = Range(match.range, in: dataStr) {
                    if(dataStr.count > range.upperBound.hashValue) {
                        let value = dataStr[range]
                        result = String(value)
                    }
                }
            }
        } catch {
            
        }
        return result
    }
}
