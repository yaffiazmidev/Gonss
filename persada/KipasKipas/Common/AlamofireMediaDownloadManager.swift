//
//  AlamofireMediaDownloadManager.swift
//  KipasKipas
//
//  Created by DENAZMI on 31/10/23.
//  Copyright © 2023 Koanba. All rights reserved.
//

import UIKit
import Photos
import Alamofire
import AVFoundation
import AVKit
import KipasKipasShared

class AlamofireMediaDownloadManager {
    static let shared = AlamofireMediaDownloadManager()
    
    private init() {}
    
    // Request authorization to access the photo library
    func requestPhotoLibraryAuthorization(completion: @escaping (Bool) -> Void) {
        PHPhotoLibrary.requestAuthorization { status in
            completion(status == .authorized)
        }
    }
    
    // Download and cache media (either image or video)
    func downloadAndCacheMedia(mediaURL: URL, progressHandler: ((Double) -> Void)?, completion: @escaping (Any?, Error?) -> Void) {
        if KKMediaItemExtension.isVideo(mediaURL.absoluteString) {
            // Download and cache video
            downloadAndCacheVideo(videoURL: mediaURL, progressHandler: progressHandler) { cachedURL, error in
                completion(cachedURL, error)
            }
        } else if KKMediaItemExtension.isPhoto(mediaURL.absoluteString) {
            // Download and cache image
            self.downloadAndCacheImage(imageURL: mediaURL, progressHandler: progressHandler) { image, error in
                completion(image, error)
            }
        } else {
            completion(nil, NSError(domain: "MediaDownloadManager", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid url."]))
        }
    }
    
    // Download and cache an image
    private func downloadAndCacheImage(imageURL: URL, progressHandler: ((Double) -> Void)?, completion: @escaping (UIImage?, Error?) -> Void) {
        let downloadRequest = AF.download(imageURL)
        
        downloadRequest.downloadProgress { progress in
            progressHandler?(progress.fractionCompleted)
        }
        
        downloadRequest.responseData { response in
            switch response.result {
            case .success(let data):
                if let image = UIImage(data: data) {
                    // Cache the image
                    self.cacheImage(image, imageURL: imageURL)
                    completion(image, nil)
                } else {
                    completion(nil, NSError(domain: "MediaDownloadManager", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to create image from data."]))
                }
            case .failure(let error):
                completion(nil, error)
            }
        }
    }
    
    // Cache an image
    private func cacheImage(_ image: UIImage, imageURL: URL) {
        let fileName = imageURL.lastPathComponent
        if let data = image.jpegData(compressionQuality: 1.0) {
            if let cachesDirectory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first {
                let fileURL = cachesDirectory.appendingPathComponent(fileName)
                do {
                    try data.write(to: fileURL)
                } catch {
                    print("azmiiiii", "Error caching image: \(error)")
                }
            }
        }
    }
    
    // Download and cache a video
    private func downloadAndCacheVideo(videoURL: URL, progressHandler: ((Double) -> Void)?, completion: @escaping (URL?, Error?) -> Void) {
        let downloadRequest = AF.download(videoURL)
        
        downloadRequest.downloadProgress { progress in
            progressHandler?(progress.fractionCompleted)
        }
        
        downloadRequest.responseData { response in
            switch response.result {
            case .success(let data):
                // Cache the video data to the device's cache directory
                let fileName = videoURL.lastPathComponent
                if let cachesDirectory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first {
                    let fileURL = cachesDirectory.appendingPathComponent(fileName)
                    do {
                        try data.write(to: fileURL)
                        completion(fileURL, nil)
                    } catch {
                        completion(nil, error)
                    }
                }
            case .failure(let error):
                completion(nil, error)
            }
        }
    }
    
    // Save media (either image or video) to the photo library
    func saveMediaToPhotoLibrary(mediaURL: URL, completion: @escaping (Error?) -> Void) {
        PHPhotoLibrary.shared().performChanges {
            if KKMediaItemExtension.isVideo(mediaURL.absoluteString) {
                PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: mediaURL)
            } else {
                let image = UIImage(contentsOfFile: mediaURL.path)
                PHAssetChangeRequest.creationRequestForAsset(from: image!)
            }
        } completionHandler: { success, error in
            if success {
                completion(nil)
            } else {
                completion(error ?? NSError(domain: "MediaDownloadManager", code: 1, userInfo: [NSLocalizedDescriptionKey: "Failed to save media to the photo library."]))
            }
        }
    }
    
    // Metode untuk menyimpan gambar sementara dalam berkas lokal
    func saveTemporaryImage(image: UIImage) -> URL? {
        do {
            let temporaryDirectoryURL = FileManager.default.temporaryDirectory
            let filename = UUID().uuidString + ".jpg"
            let temporaryFileURL = temporaryDirectoryURL.appendingPathComponent(filename)
            if let imageData = image.jpegData(compressionQuality: 0.8) {
                try imageData.write(to: temporaryFileURL)
                return temporaryFileURL
            } else {
                return nil
            }
        } catch {
            return nil
        }
    }
}

extension AlamofireMediaDownloadManager {
    
    func downloadMediaToCameraRoll(mediaURL: URL, progressHandler: ((Double) -> Void)?, completion: @escaping (Swift.Result<Any?, Error>) -> Void) {
        requestPhotoLibraryAuthorization { [weak self] isAuthorized in
            guard let self = self else { return }
            
            guard isAuthorized else {
                completion(.failure(NSError(domain: "Permission to access the photo library is not granted.", code: -1)))
                return
            }
            
            self.downloadAndCacheMedia(mediaURL: mediaURL, progressHandler: progressHandler) { media, error in
                
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                if let image = media as? UIImage {
                    print("Image downloaded and cached successfully.")
                    
                    // Simpan gambar sementara dalam berkas lokal
                    guard let temporaryImageURL = self.saveTemporaryImage(image: image) else {
                        completion(.failure(NSError(domain: "Error saving temporary image.", code: 0)))
                        return
                    }
                    
                    self.saveMediaToPhotoLibrary(mediaURL: temporaryImageURL) { saveError in
                        if let saveError = saveError {
                            completion(.failure(NSError(domain: "Error saving media to photo library: \(saveError)", code: 0)))
                            return
                        }
                        
                        print("Media saved to photo library.")
                        completion(.success(image))
                    }
                    
                    return
                }
                
                if let videoURL = media as? URL {
                    print("Video downloaded and cached successfully.")
                    
                    // Untuk menyimpan video ke galeri, gunakan metode berikut:
                    self.saveMediaToPhotoLibrary(mediaURL: videoURL) { saveError in
                        if let saveError = saveError {
                            completion(.failure(NSError(domain: "Error saving media to photo library: \(saveError)", code: 0)))
                            return
                        }
                        
                        print("Media saved to photo library.")
                        completion(.success(videoURL))
                    }
                    
                    return
                }
                
                completion(.failure(NSError(domain: "Error media not found..", code: 0)))
            }
        }
    }

    func downloadHLSAndSaveAsMP4(hlsStreamURL: URL, completion: @escaping (URL?, Error?) -> Void) {
        let avAsset = AVURLAsset(url: hlsStreamURL)
        
        let exportSession = AVAssetExportSession(asset: avAsset, presetName: AVAssetExportPresetPassthrough)
        
        guard let exportSession = exportSession else {
            completion(nil, NSError(domain: "HLSDownloadManager", code: 1, userInfo: [NSLocalizedDescriptionKey: "Failed to create AVAssetExportSession."]))
            return
        }
        
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let outputURL = documentsDirectory.appendingPathComponent("output.mp4")
        
        exportSession.outputURL = outputURL
        exportSession.outputFileType = .mp4
        
        exportSession.exportAsynchronously {
            switch exportSession.status {
            case .completed:
                completion(outputURL, nil)
            case .failed, .cancelled:
                completion(nil, exportSession.error)
            default:
                completion(nil, NSError(domain: "HLSDownloadManager", code: 2, userInfo: [NSLocalizedDescriptionKey: "AVAssetExportSession failed."]))
            }
        }
    }
}
