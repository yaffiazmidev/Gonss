import Foundation

public class SingleVideoPreloadManager: NSObject {
    
    private static var _shared: SingleVideoPreloadManager?
    
    private let MAX_SIZE_COUNT: Int = 1024 * 1024 * 1000
    private var MAX_OFFSET_SLICE: Double = 1
    
    public static var shared: SingleVideoPreloadManager {
        if let instance = _shared {
            return instance
        } else {
            let instance = SingleVideoPreloadManager()
            _shared = instance
            return instance
        }
    }
    
    var isFinished: Bool = false
    
    public static func nullify() {
        _shared = nil
    }
    
    private var downloader: VideoDownloader?
    private var currentURL: URL?
    
    func start(for url: URL) {
        guard let cacheHandler = try? VideoCacheHandler(url: url),
              isFinished == false else {
            return
        }
        
        isFinished = false
        currentURL = url
        
        downloader = VideoDownloader(url: url, cacheHandler: cacheHandler)
        downloader?.delegate = self
        
        downloader?.download(from: 0, length: MAX_SIZE_COUNT)
    }
    
    func pause() {
        downloader?.suspend()
    }
    
    public func destroy() {
        downloader?.cancel()
        downloader?.delegate = nil
        downloader = nil
        currentURL = nil
    }
    
    private func maxPreloadedLength(_ length: Int) -> Double {
        let lengthInMB = length / (1024 * 1024)
        
        if lengthInMB > 150 {
            MAX_OFFSET_SLICE = 0.5
        } else if lengthInMB > 100 {
            MAX_OFFSET_SLICE = 0.4
        } else if lengthInMB > 50 {
            MAX_OFFSET_SLICE = 0.7
        } else if lengthInMB > 25 {
            MAX_OFFSET_SLICE = 0.6
        } else if lengthInMB > 10 {
            MAX_OFFSET_SLICE = 0.8
        }
        
        return MAX_OFFSET_SLICE * Double(length)
    }
}

extension SingleVideoPreloadManager: VideoDownloaderDelegate {
    
    public func downloader(_ downloader: VideoDownloader, didReceive response: URLResponse) {}
    
    public func downloader(_ downloader: VideoDownloader, didReceive data: Data, offset: Int) {
        guard let length = downloader.info?.contentLength else { return }
        
        isFinished = Double(offset) >= maxPreloadedLength(length)
        
        if isFinished {
            destroy()
        }
    }
    
    public func downloader(_ downloader: VideoDownloader, didFinished error: Error?) {
        self.downloader = nil
        self.currentURL = nil
        self.isFinished = true
    }
}
