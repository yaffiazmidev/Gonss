//
//  KKResourceHelper.swift
//  KipasKipasFeed
//
//  Created by koanba on 27/07/23.
//

public class KKResourceHelper:NSObject, URLSessionDelegate {
    private var localPrefixCache = "kipas-cache"
    public static var instance = KKResourceHelper()
    lazy var urlSession = createURLSession()
    var writeProcess:[String] = []
    
    public func changeToH265(urlStr: String) -> URL {
        let url = urlStr.replacingOccurrences(of: getVideoId(urlPath: urlStr) + ".mp4", with: getVideoId(urlPath: urlStr) + "_h265.mp4")
        
        return URL(string: url)!
        //return URL(string: urlStr)!
    }
    
    public func getVideoId(urlPath: String) -> String {
        var isLowRes = false
        if(urlPath.contains("576p")) {
            isLowRes = true
        }
        var urlSplit = urlPath.components(separatedBy: "/")
        var pathOfUrl = urlSplit.last
        var videoId = pathOfUrl?.components(separatedBy: ".").first ?? ""
        
        if(isLowRes) {
            if(urlSplit.count > 2) {
                let index = urlSplit.count - 2
                videoId = urlSplit[index]
            }
        }
        if(videoId.contains("_")) {
            let split = videoId.components(separatedBy: "_")
            videoId = split[0]
        }
        return videoId
    }
    
    
    public func readTmpBuffer(urlPath: String) -> Data {
        var result = Data()
        var isLowRes = false
        if(urlPath.contains("576p")) {
            isLowRes = true
        }
        let lastPathOfUrl = urlPath.components(separatedBy: "/").last
        do {
            let savedURL = try getLocalFileURLPrefix(urlPath: urlPath, additionalStr: isLowRes ? "lowres/lowres.cache" : "origin/origin.cache")
            try result = Data(contentsOf: savedURL)
        } catch {
            return result
        }
        return result
    }
    
    public func writeTmpBuffer(data: Data, urlPath: String, requestOffset: Int) {
        var isLowRes = false
        if(urlPath.contains("576p")) {
            isLowRes = true
        }
        do {
            var localFile = self.readTmpBuffer(urlPath: urlPath)
            if(localFile.count == requestOffset) {
                let range = localFile.range(of: data, options: .backwards, in: 0..<localFile.count)
                if(range?.lowerBound == nil) {
                    //                    print("ongoing ==write chunk: \(urlPath), start: \(requestOffset)")
                    let savedURL = try getLocalFileURLPrefix(urlPath: urlPath, additionalStr: isLowRes ? "lowres/lowres.cache" : "origin/origin.cache")
                    //            print("write to: ", savedURL.absoluteString, isLowRes)
                    
                    let targetDir = savedURL.deletingLastPathComponent()
                    var isDirectory : ObjCBool = true
                    if FileManager.default.fileExists(atPath: targetDir.path, isDirectory: &isDirectory) {
                        if(!isDirectory.boolValue) {
                            print("exist but not directory, creating dir")
                            try FileManager.default.createDirectory(at:targetDir, withIntermediateDirectories: true, attributes: nil)
                        }
                    } else {
                        //print("directory not exist, creating dir \(targetDir)")
                        try FileManager.default.createDirectory(at:targetDir, withIntermediateDirectories: true, attributes: nil)
                    }
                    
                    if FileManager.default.fileExists(atPath: savedURL.path, isDirectory: &isDirectory) {
                        if(isDirectory.boolValue) {
                            //                        print("writing 1: ", savedURL.absoluteString, requestOffset, localFile.count, data.count, range?.lowerBound, range?.upperBound)
                            print("exist but not a file, creating file")
                            var localFile = self.readTmpBuffer(urlPath: urlPath)
                            if(localFile.count == requestOffset) {
                                localFile.append(contentsOf: data)
                                try localFile.write(to: savedURL)
                            }
                        } else {
                            //                        print("writing 2: ", savedURL.absoluteString, requestOffset, localFile.count, data.count, range?.lowerBound, range?.upperBound)
                            var localFile = self.readTmpBuffer(urlPath: urlPath)
                            if(localFile.count == requestOffset) {
                                localFile.append(contentsOf: data)
                                try localFile.write(to: savedURL)
                            }
                        }
                    } else {
                        //                    print("writing 3: ", savedURL.absoluteString, requestOffset, localFile.count, data.count, range?.lowerBound, range?.upperBound)
                        var localFile = self.readTmpBuffer(urlPath: urlPath)
                        if(localFile.count == requestOffset) {
                            localFile.append(contentsOf: data)
                            try localFile.write(to: savedURL)
                        }
                    }
                }
            }
        } catch {
            print ("file error: \(error)")
        }
    }

    public func getLocalFileURLPrefix(urlPath: String, additionalStr: String = "") -> URL {
        let prefixURL = localPrefixCache + "/" + getVideoId(urlPath: urlPath) + "/" + additionalStr
        var result = URL(string: "")
        do {
            let documentsURL = try
                FileManager.default.url(for: .documentDirectory,
                                        in: .userDomainMask,
                                        appropriateFor: nil,
                                        create: false)
            result = documentsURL.appendingPathComponent(prefixURL)
        } catch {
            print(error)
        }
        return result!
    }
        
    public func removeAllCache() {
        do {
            let documentsURL = try
                FileManager.default.url(for: .documentDirectory,
                                        in: .userDomainMask,
                                        appropriateFor: nil,
                                        create: false)
            let targetURL = documentsURL.appendingPathComponent(localPrefixCache)
            try FileManager.default.removeItem(at: targetURL)
        } catch {
            print("error failed remove all tmp", error)
        }
    }
        
    func createURLSession() -> URLSession {
        let config = URLSessionConfiguration.ephemeral
        config.timeoutIntervalForRequest = 10.0
        config.timeoutIntervalForResource = 10.0
        config.requestCachePolicy = .useProtocolCachePolicy
        config.tlsMinimumSupportedProtocolVersion = .TLSv13
        config.waitsForConnectivity = true
        let operationQueue = OperationQueue()
        operationQueue.maxConcurrentOperationCount = 1
        return URLSession(configuration: config, delegate: self, delegateQueue: operationQueue)
    }
}


