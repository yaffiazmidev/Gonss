//
//  KKTencentPreloadOperation.swift
//  FeedCleeps
//
//  Created by koanba on 07/09/23.
//


import Foundation
import TXLiteAVSDK_Professional

public class KKTencentPreloadOperation: Operation {
    private let preloader: TXVodPreloadManager

    private let lockQueue = DispatchQueue(label: "com.kipaskipas.preload.operation", attributes: .concurrent)

    private var _isExecuting: Bool = false

    public override var isAsynchronous: Bool {
        return true
    }
    
    
    let videoUrl: String

    let LOG_ID = "==KKTencentPreloadOperation-XX"
    
    public init(videoUrl: String) {
        self.preloader = TXVodPreloadManager.shared()
        self.videoUrl = videoUrl
        super.init()
        self.name = videoUrl
        print(self.LOG_ID, "onInit \(KKVideoId().getId(urlString: self.videoUrl))")

    }

    public override private(set) var isExecuting: Bool {
        get {
            return lockQueue.sync { () -> Bool in
                return _isExecuting
            }
        }
        set {
            willChangeValue(forKey: "isExecuting")
            lockQueue.sync(flags: [.barrier]) {
                _isExecuting = newValue
            }
            didChangeValue(forKey: "isExecuting")
        }
    }

    private var _isFinished: Bool = false
    public override private(set) var isFinished: Bool {
        get {
            return lockQueue.sync { () -> Bool in
                return _isFinished
            }
        }
        set {
            willChangeValue(forKey: "isFinished")
            lockQueue.sync(flags: [.barrier]) {
                _isFinished = newValue
            }
            didChangeValue(forKey: "isFinished")
        }
    }

    public override func start() {
        self.name = videoUrl
        
        //print(self.LOG_ID, "onStart-A ", KKVideoId().getId(urlString: self.videoUrl))

        guard !isCancelled else {
            finish()
            return
        }

        isFinished = false
        isExecuting = true
        //main()
        startPreload()
    }
    
    func finish() {
        print(self.LOG_ID, "onfinish \(KKVideoId().getId(urlString: self.videoUrl))")
        isExecuting = false
        isFinished = true
    }

    func startPreload() {
        self.preloader.startPreload(
            self.videoUrl,
            preloadSize: 1, //Megabyte
            preferredResolution: KKTencentVideoPlayerHelper.instance.preferredResolution,
            delegate: self
        )

    }

    public override func main() {
        //print(self.LOG_ID, "onMain \(KKVideoId().getId(urlString: self.videoUrl))")
        return
    }

    public override func cancel() {
        super.cancel()
        print(self.LOG_ID, "onCanceled ", KKVideoId().getId(urlString: self.videoUrl))
        if isExecuting {
            self.finish()
        }
        
    }
    
}

extension KKTencentPreloadOperation: TXVodPreloadManagerDelegate {
    
    
    public func onStart(_ taskID: Int32, fileId: String, url: String, param: [AnyHashable : Any]) {
        print(self.LOG_ID, "onStart  ", KKVideoId().getId(urlString: url))
    }

    public func onComplete(_ taskID: Int32, url: String) {
        print(self.LOG_ID, "onComplete", KKVideoId().getId(urlString: url))
            
        //KKTencentVideoPlayerPreload.instance.printTotalCached()
        //KKBenchmark.instance.show()
                
        self.finish()
    }

    public func onError(_ taskID: Int32, url: String, error: Error) {
        print(self.LOG_ID, "onError   ", KKVideoId().getId(urlString: url), error.localizedDescription)
        //self.finish()
        self.cancel()
    }
}
