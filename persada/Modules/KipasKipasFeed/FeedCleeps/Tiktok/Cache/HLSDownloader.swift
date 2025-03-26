//
//  HLSDownloader.swift
//  KipasKipas
//
//  Created by PT.Koanba on 11/01/22.
//  Copyright © 2022 Koanba. All rights reserved.
//

import Foundation
import AVFoundation

class HLSDownloader : NSObject {
    static let instance = HLSDownloader()
    private var downloadSession : AVAssetDownloadURLSession!
    private let configuration : URLSessionConfiguration = URLSessionConfiguration.background(withIdentifier: "hlsDownloader")
    private let cache : TiktokCache!
    
    private var mediaSelectionMap = [AVAssetDownloadTask : AVMediaSelection]()
    
    private let urlSessionIdentifier = "hlsDownloaderBackgroundIdentifier"
    
    private var tasks = [String: AVAssetDownloadTask]()
    
    private let requiredAssetKeys = [
        "playable",
        "hasProtectedContent"
    ]
        
    var bindError : ((Error) -> Void)?
    
    private override init(){
        self.cache = TiktokCache.instance
        super.init()
        self.downloadSession = AVAssetDownloadURLSession(
            configuration: configuration,
            assetDownloadDelegate: self,
            delegateQueue: .main)
    }
    
//    private func setURL(url: String){
//        self.urlKeyString = url
//    }
    
    func downloadAsset(url: String){
        if let tasks = tasks[url] {
            tasks.resume()
            print("Download downloadAsset from Variabel \(downloadSession?.delegate)")
        } else {
            let asset = AVURLAsset(url: URL(string: url)!)
            var downloadTask : AVAssetDownloadTask?
            if #available(iOS 14.0, *) {
                downloadTask = downloadSession.makeAssetDownloadTask(
                    asset: asset,
                    assetTitle: url,
                    assetArtworkData: nil,
                    options: [AVAssetDownloadTaskPrefersHDRKey : 0])
            } else {
                downloadTask = downloadSession.makeAssetDownloadTask(
                    asset: asset,
                    assetTitle: url,
                    assetArtworkData: nil,
                    options: [AVAssetDownloadTaskMinimumRequiredMediaBitrateKey: 0])
            }
            downloadTask?.resume()
            tasks[url] = downloadTask
            print("Download downloadAsset \(downloadSession?.delegate)")
        }
    }
    
    private func downloadAndPlayAsset(url: String, completion : @escaping (AVPlayerItem) -> Void) {
        if let tasks = tasks[url] {
            tasks.resume()
            let asset = tasks.urlAsset
            loadAssetAsync(asset: asset) { item in
                completion(item)
            }
            print("Download downloadAndPlayAsset NETWORK from Variabel \(downloadSession?.delegate)")
        } else {
            let asset = AVURLAsset(url: URL(string: url)!)
            let downloadTask = downloadSession.makeAssetDownloadTask(
                asset: asset,
                assetTitle: url,
                assetArtworkData: nil,
                options: nil)
            downloadTask?.resume()
            tasks[url] = downloadTask
            guard let asset = downloadTask?.urlAsset else { return }

            loadAssetAsync(asset: asset) { item in
                completion(item)
            }
            print("Download downloadAndPlayAsset NETWORK \(downloadSession?.delegate)")
        }
    }
    
    private func loadAsset(asset: AVURLAsset, completion : @escaping (AVPlayerItem) -> Void) {
        let _ = asset.observe(\AVURLAsset.isPlayable, options: [.new, .initial]) { [weak self] (urlAsset, _) in
            guard let self = self, urlAsset.isPlayable == true else { return }
            
            
            let playerItem = AVPlayerItem(asset: asset, automaticallyLoadedAssetKeys: self.requiredAssetKeys)
            
            completion(playerItem)
            print("Download Play from network")
        }
    }
    
    func loadAssetAsync(asset: AVURLAsset, completion : @escaping (AVPlayerItem) -> Void){
        let key = "commonMetadata"
        asset.loadValuesAsynchronously(forKeys: [key]) {
            var error: NSError? = nil
            switch asset.statusOfValue(forKey: key, error: &error) {
            case .loaded:
                // The property successfully loaded. Continue processing.
                let _ = asset.observe(\AVURLAsset.isPlayable, options: [.new, .initial]) { [weak self] (urlAsset, _) in
                    guard let self = self, urlAsset.isPlayable == true else { return }
                    
                    
                    let playerItem = AVPlayerItem(asset: asset, automaticallyLoadedAssetKeys: self.requiredAssetKeys)
                    
                    completion(playerItem)
                    print("Download Play from network")
                }
            case .failed:
                // Examine the NSError pointer to determine the failure.
                guard let error = error else { return }
                print("Failed load asset failed : \(error)")
            case .cancelled:
                // The asset canceled loading.
                guard let error = error else { return }
                print("Failed load asset cancelled : \(error)")
            default:
                // Handle all other cases.
                guard let error = error else { return }
                print("Failed load asset default : \(error)")
            }
        }
    }
    
    func suspend(url: String){
        if let task = tasks[url] {
            task.suspend()
        }
    }
    
    func resume(url: String){
        if let task = tasks[url] {
            task.resume()
        }
    }
    
    func cancel(url: String){
        if let task = tasks[url] {
            task.cancel()
        }
    }
    
    func playOfflineAssetWithFallbackIfNotAvailable(url: String, completion : @escaping (AVPlayerItem) -> Void){
        print("Download Init \(url) cache \(cache.getValue(key: url))")
        guard let assetPath = cache.getValue(key: url) else {
            downloadAndPlayAsset(url: url, completion: completion)
            return
        }
        
        let baseURL = URL(fileURLWithPath: NSHomeDirectory())
        let assetURL = baseURL.appendingPathComponent(assetPath)
        let asset = AVURLAsset(url: assetURL)
        
        print("Download asset info \(asset.assetCache) offline \(asset.assetCache?.isPlayableOffline)")
        if let cache = asset.assetCache, cache.isPlayableOffline {
            loadAssetAsync(asset: asset) { item in
                completion(item)
                
                print("Download asset LOCAL \(asset.assetCache) offline \(asset.assetCache?.isPlayableOffline)")
            }
        } else {
            downloadAndPlayAsset(url: url, completion: completion)
        }
    }
    
    func restorePendingDownloads(){
        downloadSession = AVAssetDownloadURLSession(
            configuration: configuration,
            assetDownloadDelegate: self,
            delegateQueue: .main)
        
        downloadSession.getAllTasks { tasks in
            for task in tasks {
                guard let downloadTask = task as? AVAssetDownloadTask else { break }
                downloadTask.resume()
            }
        }
        
        print("Download restorePendingDownloads")
    }
    
    func deleteOfflineAsset(url: String){
        do {
            if let assetPath = cache.getValue(key: url) {
                let baseURL = URL(fileURLWithPath: NSHomeDirectory())
                let assetURL = baseURL.appendingPathComponent(assetPath)
                try FileManager.default.removeItem(at: assetURL)
                cache.removeObject(key: url)
            }
        } catch {
            print("An error occured deleting offline asset: \(error)")
        }
    }
}


extension HLSDownloader : AVAssetDownloadDelegate {
    func urlSession(_ session: URLSession, assetDownloadTask: AVAssetDownloadTask, didFinishDownloadingTo location: URL) {
        guard assetDownloadTask.error == nil else { return }
//            cache.saveValue(key: assetDownloadTask.urlAsset.url.absoluteString, value: location.relativePath)
//            print("Download Success \(assetDownloadTask.urlAsset.url)")
    }
    
    func urlSession(_ session: URLSession, didBecomeInvalidWithError error: Error?) {
        print("Download didBecomeInvalidWithError \(error)")
        guard let error = error else { return }
        bindError?(error)
    }
    
    func urlSession(_ session: URLSession, taskIsWaitingForConnectivity task: URLSessionTask) {
        print("Download taskIsWaitingForConnectivity")
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        print("Download didCompleteWithError \(error)")

        guard error == nil else {
            guard let error = error else { return }
            bindError?(error)
            return
        }
        
        guard let task = task as? AVAssetDownloadTask else { return }
        
        // Determine the next available AVMediaSelectionOption to download
        let mediaSelectionPair = nextMediaSelection(task.urlAsset)
        
        // If an undownloaded media selection option exists in the group...
        if let group = mediaSelectionPair.mediaSelectionGroup,
           let option = mediaSelectionPair.mediaSelectionOption {
            
            // Exit early if no corresponding AVMediaSelection exists for the current task
            guard let originalMediaSelection = mediaSelectionMap[task] else { return }
            
            // Create a mutable copy and select the media selection option in the media selection group
            let mediaSelection = originalMediaSelection.mutableCopy() as! AVMutableMediaSelection
            mediaSelection.select(option, in: group)
            
            let url = task.urlAsset.url.absoluteString
            // Create a new download task with this media selection in its options
            let options = [AVAssetDownloadTaskMediaSelectionKey: mediaSelection]
            let task = downloadSession.makeAssetDownloadTask(asset: task.urlAsset,
                                                             assetTitle: url,
                                                             assetArtworkData: nil,
                                                             options: options)

            // Start media selection download
            task?.resume()
            tasks[url] = task
            
        } else {
            // All media selection downloads complete
        }
    }
    
    func urlSession(_ session: URLSession, assetDownloadTask: AVAssetDownloadTask, didLoad timeRange: CMTimeRange, totalTimeRangesLoaded loadedTimeRanges: [NSValue], timeRangeExpectedToLoad: CMTimeRange) {
        var percentComplete = 0.0
        // Iterate through the loaded time ranges
        for value in loadedTimeRanges {
            // Unwrap the CMTimeRange from the NSValue
            let loadedTimeRange = value.timeRangeValue
            // Calculate the percentage of the total expected asset duration
            percentComplete += loadedTimeRange.duration.seconds / timeRangeExpectedToLoad.duration.seconds
        }
        percentComplete *= 100
//        print("Download percentage \(percentComplete) url \(urlKeyString)")
    }
    
    func urlSession(_ session: URLSession, assetDownloadTask: AVAssetDownloadTask, didResolve resolvedMediaSelection: AVMediaSelection) {
        print("Download didResolve \(assetDownloadTask.urlAsset)")
        mediaSelectionMap[assetDownloadTask] = resolvedMediaSelection
    }
}

extension HLSDownloader {
    func nextMediaSelection(_ asset: AVURLAsset) -> (mediaSelectionGroup: AVMediaSelectionGroup?,
                                                     mediaSelectionOption: AVMediaSelectionOption?) {
     
        // If the specified asset has not associated asset cache, return nil tuple
        guard let assetCache = asset.assetCache else {
            return (nil, nil)
        }
     
        // Iterate through audible and legible characteristics to find associated groups for asset
        for characteristic in [AVMediaCharacteristic.audible, AVMediaCharacteristic.legible] {
     
            if let mediaSelectionGroup = asset.mediaSelectionGroup(forMediaCharacteristic: characteristic) {
     
                // Determine which offline media selection options exist for this asset
                let savedOptions = assetCache.mediaSelectionOptions(in: mediaSelectionGroup)
     
                // If there are still media options to download...
                if savedOptions.count < mediaSelectionGroup.options.count {
                    for option in mediaSelectionGroup.options {
                        if !savedOptions.contains(option) {
                            // This option hasn't been downloaded. Return it so it can be.
                            return (mediaSelectionGroup, option)
                        }
                    }
                }
            }
        }
        // At this point all media options have been downloaded.
        return (nil, nil)
    }
}
