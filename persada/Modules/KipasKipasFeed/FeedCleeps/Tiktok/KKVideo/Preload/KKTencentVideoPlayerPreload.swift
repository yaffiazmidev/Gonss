//
//  KKTencentVideoPlayerPreload.swift
//  KKPlayerApp
//
//  Created by Rahmat Trinanda Pramudya Amar on 12/07/23.
//


import Foundation
import TXLiteAVSDK_Professional
import Queuer

struct KKTencentVideoPlayerPreloadQueue {
    let videoId: String
    var taskId: Int32
    var status: KKTencentVideoPlayerPreloadQueueStatus
    let description: String
    
    init(videoId: String, taskId: Int32 = -100, status: KKTencentVideoPlayerPreloadQueueStatus = .waiting, description: String = "") {
        self.videoId = videoId
        self.taskId = taskId
        self.status = status
        self.description = description
    }
}

enum KKTencentVideoPlayerPreloadQueueStatus {
    case waiting
    case progress
    case completed
    case error
}

enum KKTencentVideoPlayerPreloadPriority {
    case downUp
    case downCompleteUpComplete
    case fifo
}

public class KKTencentVideoPlayerPreload: NSObject {
    public static let instance: KKTencentVideoPlayerPreload = KKTencentVideoPlayerPreload()
    
    private let preloader: TXVodPreloadManager
    
    let LOG_ID = "====KKTencentVideoPlayerPreload "

    
    private var queueInactive: [KKTencentVideoPlayerPreloadQueue]
    
    private var onPreload: Bool
    
    private var onPreloadId = ""
    
    var currentIndex: Int {
        didSet {

        }
    }
    
    
    
    var isPaused: Bool {
        didSet {
            if (isPaused){
                self.pauseAll()
            } else {
                self.resumeAll()
            }
        }
    }
    
    
    //let queue = Queuer(name: "KKPreloadQueue", maxConcurrentOperationCount: 1, qualityOfService: .default)
    var queues:[(id: String, queue: Queuer)] = []


    var queueActives: [String]
    
    //    var priority: KKTencentVideoPlayerPreloadPriority = .downCompleteUpComplete
    var priority: KKTencentVideoPlayerPreloadPriority = .fifo
    
    var lastUpdate = NSDate()
    
    private override init () {
        self.preloader = TXVodPreloadManager.shared()
        //self.queue = []
        //let queue = OperationQueue()
        self.isPaused = false
        
        self.lastUpdate = NSDate()
        
        self.queueInactive = []
        
        self.queueActives = []
        
        self.currentIndex = 0
        self.onPreload = false
        super.init()
        self.configure()
        
        
        
        KKTencentVideoPlayerHelper.instance.setupLicense()

        //queue.maxConcurrentOperationCount = 1
        //queue.waitUntilAllOperationsAreFinished()

        KKBenchmark.instance.start()
        self.printTotalCached()
    }
    
    private func configure() {
        // Set the global cache directory of the playback engine
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentsDirectory = paths[0]
        let preloadDataPath = (documentsDirectory as NSString).appendingPathComponent("/preload")
        if !FileManager.default.fileExists(atPath: preloadDataPath) {
            try? FileManager.default.createDirectory(atPath: preloadDataPath, withIntermediateDirectories: false, attributes: nil)
        }
        TXPlayerGlobalSetting.setCacheFolderPath(preloadDataPath)
        
        // Set the playback engine cache size
        TXPlayerGlobalSetting.setMaxCacheSize(200)
    }
    
    public func addQueue(videos id: [String], queueId: String){
        id.forEach { id in
            self.addQueue(video: id, queueId: queueId)
        }
    }
    
    func getQueue(queueId: String) -> Queuer {
        if let queue = self.queues.first(where: { $0.id == queueId }){
            //print(self.LOG_ID, "getQueue OLD")
            return queue.queue
        }
        let queueName = "KKPreloadQueue" + queueId
        let queueNew = Queuer(name: queueName , maxConcurrentOperationCount: 1, qualityOfService: .default)

        self.queues.append((id: queueId, queue: queueNew))
        
        //print(self.LOG_ID, "getQueue NEW", queueName)
        return queueNew
    }
    
    public func addQueue(video id: String, queueId: String, description: String = "") {
        let queue = self.getQueue(queueId: queueId)
                    
        //self.queue.addOperations([KKTencentPreloadOperation(videoUrl: id)], waitUntilFinished: false)
    
        //https://persada-entertainment.atlassian.net/browse/PE-11192
        // Preload only for HLS
        if(!id.lowercased().contains(".m3u8")) { return }
        
        let isQueueExist = self.queueActives.first(where: { $0 == id })
        if(isQueueExist == nil){
            self.queueActives.append(id)
            //self.checkQueue()
            let operation = KKTencentPreloadOperation(videoUrl: id)
                queue.addOperation(operation)
                
                print(self.LOG_ID, "ADD video ID:", KKVideoId().getId(urlString: id), "queueId:",queueId, "queue.count", queue.operationCount)
        } else {
            //print("KKTencentPreloadOperation onIgnored..", KKVideoId().getId(urlString: id) )
        }
    }
    

    public func cancelPreload(video id: String, queueId: String, reason: String) {
        if(!id.lowercased().contains(".m3u8")) { return }
        
        var isCancel = false
        
        if let queue = self.queues.first(where: { $0.id == queueId }){
            queue.queue.operations.forEach { operation in
                if operation.name == id {
                    //DispatchQueue.main.async {
                        //print(self.LOG_ID, "Cancel video ID:", KKVideoId().getId(urlString: id), "queueId:", queueId)
                        operation.cancel()
                        isCancel = true

                    //}
                }
            }
        }
        
        if(isCancel){
            print(self.LOG_ID, "Cancel-yes video ID:", KKVideoId().getId(urlString: id))
        } else {
            //print(self.LOG_ID, "Cancel-NO video ID:", KKVideoId().getId(urlString: id))
        }
    }

    public func pauseAll() {
//        if(self.isCanPauseResume()){
//            if(self.queue.isExecuting){
//                self.lastUpdate = NSDate()
//                print(self.LOG_ID, "pauseAll")
//                //self.removeUnused()
//                self.queue.pause()
//            }
//        } else {
//            //print(self.LOG_ID, "pauseAll ignore")
//        }
    }
    
    public func resumeAll() {
//        if(!self.queue.isExecuting ){
//            if(self.isCanPauseResume()){
//
//                self.lastUpdate = NSDate()
//
//                print(self.LOG_ID, "resumeAll")
//                self.queue.resume()
//            }
//        }
    }

    private func removeUnused(){
//        self.queue.operations.forEach { operation in
//            if operation.isFinished || operation.isCancelled {
//                operation.cancel()
//            }
//        }
    }
    
    public func checkQueue() {
        self.queues.forEach { (id: String, queue: Queuer) in
            //print(self.LOG_ID, "oncheckQueue \(id) count:", queue.operations.count)
        }
        
    }


    
    func removeQueue(video id: String){
        //self.cancelPreload(video: id, reason: "removeQueue")
        //print(self.LOG_ID, "removing queue with video ID:", id)
    }
    
    func removeAllQueue(queueId: String) {
        self.queueActives = []
        self.queues.forEach { (id: String, queue: Queuer) in
            if(id == queueId){
                print(self.LOG_ID, "removing all queue", queueId)
                queue.cancelAll()
                //queue.queue.cancelAllOperations()                
            }
        }
        //print("operationCount", self.queue.operationCount)
    }
    
    public func clear() {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentsDirectory = paths[0]
        let preloadDataPath = (documentsDirectory as NSString).appendingPathComponent("/preload")
        
        do {
            try FileManager.default.removeItem(atPath: preloadDataPath)
        } catch {
            print(self.LOG_ID, "clear cache error", error)
        }
    }
    
    private func isCanPauseResume() -> Bool {
        let interval = -self.lastUpdate.timeIntervalSinceNow
        
        print(self.LOG_ID, "pauseAll interval :", interval)
        
        return interval > 2
        
    }
}


// MARK: - Helper
extension KKTencentVideoPlayerPreload {

    private func printPreload(function: String = #function) {

    }
    
    public func printTotalCached() {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentsDirectory = paths[0]
        let preloadDataPath = (documentsDirectory as NSString).appendingPathComponent("/preload")
        
        var size: UInt64 = 0
        
        let a = self.contents(of: preloadDataPath)
        a.forEach { p1 in
            let b = self.contents(of: preloadDataPath + "/" + p1)
            b.forEach { p2 in
                let c = self.contents(of: preloadDataPath + "/" + p1 + "/" + p2)
                c.forEach { p3 in
                    size += self.cacheSize(of: preloadDataPath + "/" + p1 + "/" + p2 + "/" + p3)
                }
            }
        }
        
        print(self.LOG_ID, "kkbenchmark print preload", "total cached", size.toFileSize())
    }
    
    private func contents(of path: String) -> [String] {
        var contents: [String] = []
        do {
            contents = try FileManager.default.contentsOfDirectory(atPath: path)
        } catch {
            print("error", error)
        }
        return contents
    }
    
    private func cacheSize(of path: String) -> UInt64 {
        //return [FileAttributeKey : Any]
        var fileSize : UInt64 = 0
        do {
            let attr = try FileManager.default.attributesOfItem(atPath: path)
            fileSize = attr[FileAttributeKey.size] as! UInt64
            
            //if you convert to NSDictionary, you can get file size old way as well.
            let dict = attr as NSDictionary
            fileSize = dict.fileSize()
        } catch {
            print("Error: \(error)")
        }
        
        return fileSize
    }
}

fileprivate extension UInt64 {
    func toFileSize() -> String {
        var convertedValue: Double = Double(self)
        var multiplyFactor = 0
        let tokens = ["bytes", "KB", "MB", "GB", "TB", "PB",  "EB",  "ZB", "YB"]
        while convertedValue > 1024 {
            convertedValue /= 1024
            multiplyFactor += 1
        }
        return String(format: "%4.2f %@", convertedValue, tokens[multiplyFactor])
    }
}

