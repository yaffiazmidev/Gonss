//
//  AVPlayerItem+Extensions.swift
//  GSPlayer
//
//  Created by Gesen on 2019/4/21.
//  Copyright © 2019 Gesen. All rights reserved.
//

import AVFoundation

public extension AVPlayerItem {
    
    var bufferProgress: Double {
        return currentBufferDuration / totalDuration
    }
    
    var currentBufferDuration: Double {
        guard let range = loadedTimeRanges.first else { return 0 }
        return Double(CMTimeGetSeconds(CMTimeRangeGetEnd(range.timeRangeValue)))
    }
    
    var currentDuration: Double {
        return Double(CMTimeGetSeconds(currentTime()))
    }
    
    var playProgress: Double {
        return currentDuration / totalDuration
    }
    
    var totalDuration: Double {
        return Double(CMTimeGetSeconds(asset.duration))
    }
    
}

extension AVPlayerItem {
    
    static var loaderPrefix: String = "loader-"
    
    var url: URL? {
        guard
            let urlString = (asset as? AVURLAsset)?.url.absoluteString,
            urlString.hasPrefix(AVPlayerItem.loaderPrefix)
            else { return nil }
        
        return urlString.replacingOccurrences(of: AVPlayerItem.loaderPrefix, with: "").url?.deletingPathExtension()
    }
    
    var isEnoughToPlay: Bool {
        guard
            let url = url,
            let configuration = try? VideoCacheManager.cachedConfiguration(for: url)
            else { return false }
    
        
        return configuration.progress >= 0.7
    }
    
    convenience init(loader url: URL) {
        if url.isFileURL || url.pathExtension == "m3u8" {
            self.init(url: url)
            return
        }
        
        guard let loaderURL = (AVPlayerItem.loaderPrefix + url.absoluteString + ".mp4").url else {
            VideoLoadManager.shared.reportError?(NSError(
                domain: "me.gesen.player.loader",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "Wrong url \(url.absoluteString)，unable to initialize Loader"]
            ))
            self.init(url: url)
            return
        }
        
        let urlAsset = AVURLAsset(url: loaderURL)
        urlAsset.resourceLoader.setDelegate(VideoLoadManager.shared, queue: .main)
        
        self.init(asset: urlAsset)
    }
    
}
