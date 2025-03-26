//
//  KKMediaHelper.swift
//  KipasKipasShared
//
//  Created by Rahmat Trinanda Pramudya Amar on 19/11/23.
//

import UIKit
import AVFoundation

public class KKMediaHelper {
    private static var _instance: KKMediaHelper?
    private static let lock = NSLock()
    
    private let identifier: String = "KKMediaHelper"
    
    public static var instance: KKMediaHelper {
        if _instance == nil {
            lock.lock()
            defer {
                lock.unlock()
            }
            if _instance == nil {
                _instance = KKMediaHelper()
            }
        }
        return _instance!
    }
    
    private init() {}
}

// MARK: - Converter
public extension KKMediaHelper {
    func photo(image: UIImage, postType: KKMediaPostType = .feed) -> KKMediaItem? {
        guard let imageURL = NSURL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("TempImage-\(NSUUID().uuidString).jpeg") else {
            return nil
        }
        
        let oriendtedImage = image.fixedOrientation()
        if let _ = try? oriendtedImage?.pngData()?.write(to: imageURL) {
            return photo(url: imageURL, postType: postType)
        }
        
        return nil
    }
    
    func photo(url: URL, postType: KKMediaPostType = .feed) -> KKMediaItem? {
        if let image = UIImage(contentsOfFile: url.path) {
            return KKMediaItem(data: image.jpegData(compressionQuality: 1), path: url.absoluteString, type: .photo, postType: postType, photoThumbnail: image)
        }
        
        return nil
    }
    
    func video(url: URL, postType: KKMediaPostType = .feed, completion: @escaping ((KKMediaItem?, String?) -> Void)) {
        let compressedURL = NSURL.fileURL(withPath: NSTemporaryDirectory() + NSUUID().uuidString + ".mp4")
        
        KKLogFile.instance.log(label:"KKMediaHelper", message: "video compressedURL: \(compressedURL.absoluteString)")

        compressVideo(inputURL: url, outputURL: compressedURL) { [weak self] session in
            KKLogFile.instance.log(label:"KKMediaHelper", message: "video.compressVideo..")
            
            guard let self = self, let session = session else {
                completion(nil, "")
                return
            }
            
            switch session.status {
            case .unknown:
                KKLogFile.instance.log(label:"KKMediaHelper", message: "video.compressVideo session.status UNKNOWN")
                break
            case .waiting:
                KKLogFile.instance.log(label:"KKMediaHelper", message: "video.compressVideo session.status Waiting")
                break
            case .exporting:
                KKLogFile.instance.log(label:"KKMediaHelper", message: "video.compressVideo session.status Exporting")
                break
            case .completed:
                KKLogFile.instance.log(label:"KKMediaHelper", message: "video.compressVideo session.status Completed")
                guard let compressedData = try? Data.init(contentsOf: compressedURL),
                      let thumbnail = self.videoThumbnail(compressedURL.absoluteString)
                else {
                    completion(nil,"Compress Error")
                    return
                }
                
                let item = KKMediaItem(data: compressedData, path: compressedURL.absoluteString, type: .video, postType: postType, videoThumbnail: thumbnail)
                completion(item, "")
            case .failed, .cancelled:
                completion(nil, "")
            @unknown default:
                break
            }
            
            return
        }
    }
}

// MARK: - Helper
public extension KKMediaHelper {
    func compressVideo(inputURL: URL, outputURL: URL, handler: @escaping (_ session: AVAssetExportSession?)-> Void) {
        let urlAsset = AVURLAsset(url: inputURL, options: nil)
        
        KKLogFile.instance.log(label:"KKMediaHelper", message: "compressVideo-start: \(urlAsset.url.absoluteString)")
                
        guard let exportSession = AVAssetExportSession(asset: urlAsset, presetName: AVAssetExportPresetHighestQuality) else {
            KKLogFile.instance.log(label:"KKMediaHelper", message: "compressVideo-failed", level: .error)
            handler(nil)
            return
        }
        exportSession.outputURL = outputURL
        exportSession.outputFileType = AVFileType.mp4
        exportSession.shouldOptimizeForNetworkUse = true
        
        exportSession.exportAsynchronously {
            DispatchQueue.main.async {
                KKLogFile.instance.log(label:"KKMediaHelper", message: "compressVideo-finished")
                
                handler(exportSession)
            }
        }
    }
    
    func videoThumbnail(_ path: String) -> UIImage? {
        do {
            let url = URL(fileURLWithPath: path)
            let asset = AVURLAsset(url: url, options: nil)
            let imgGenerator = AVAssetImageGenerator(asset: asset)
            imgGenerator.appliesPreferredTrackTransform = true
            let cgImage = try imgGenerator.copyCGImage(at: CMTimeMake(value: 0, timescale: 1), actualTime: nil)
            let thumbnail = UIImage(cgImage: cgImage)
            return thumbnail
        } catch let error {
            print(identifier, "Error generating thumbnail: \(error.localizedDescription)")
            return nil
        }
    }
}
