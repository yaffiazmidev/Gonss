//
//  URLSessionMediaDownloadManager.swift
//  KipasKipas
//
//  Created by DENAZMI on 31/10/23.
//  Copyright © 2023 Koanba. All rights reserved.
//

import UIKit
import Photos
import AVFoundation

enum DownloadMediaType {
    case video
    case image
}

class URLSessionMediaDownloadManager: NSObject, ObservableObject, URLSessionDownloadDelegate {
    var progress: Float = 0
    
    let mediaType: DownloadMediaType
    
    init(mediaType: DownloadMediaType) {
        self.mediaType = mediaType
    }
    
    func downloadMedia(url: URL) {
        DispatchQueue.main.async { KKLoading.shared.show(message: "Please wait..") }
        
        let session = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
        let task = session.dataTask(with: url) { (data, response, error) in
            DispatchQueue.main.async { KKLoading.shared.hide() }
            guard error == nil else {
                return
            }
            
            let downloadTask = session.downloadTask(with: url)
            downloadTask.resume()
        }
        task.resume()
    }

    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        DispatchQueue.main.async { KKLoading.shared.hide() }
        guard let data = try? Data(contentsOf: location) else {
            return
        }

        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd-yyyy-HH:mm"
        let dateString = dateFormatter.string(from: Date())
        
        let fileType = mediaType == .video ? ".mp4" : ".jpg"
        let destinationURL = documentsURL.appendingPathComponent("KK-\(dateString)\(fileType)")
        
        do {
            try data.write(to: destinationURL)
            saveVideoToAlbum(videoURL: destinationURL, albumName: "KipasKipas")
        } catch {
            print("azmiiii", "Error saving file:", error)
        }
    }

    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        DispatchQueue.main.async { KKLoading.shared.show(message: "Downloading..") }
        print("azmiiii", Float(totalBytesWritten) / Float(totalBytesExpectedToWrite))
        DispatchQueue.main.async {
            self.progress = (Float(totalBytesWritten) / Float(totalBytesExpectedToWrite))
        }
    }

    private func saveVideoToAlbum(videoURL: URL, albumName: String) {
        DispatchQueue.main.async { KKLoading.shared.show(message: "Saving to gallery..") }
        if albumExists(albumName: albumName) {
            let fetchOptions = PHFetchOptions()
            fetchOptions.predicate = NSPredicate(format: "title = %@", albumName)
            let collection = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: fetchOptions)
            if let album = collection.firstObject {
                saveVideo(videoURL: videoURL, to: album)
            }
        } else {
            var albumPlaceholder: PHObjectPlaceholder?
            PHPhotoLibrary.shared().performChanges({
                let createAlbumRequest = PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: albumName)
                albumPlaceholder = createAlbumRequest.placeholderForCreatedAssetCollection
            }, completionHandler: { success, error in
                if success {
                    guard let albumPlaceholder = albumPlaceholder else { return }
                    let collectionFetchResult = PHAssetCollection.fetchAssetCollections(withLocalIdentifiers: [albumPlaceholder.localIdentifier], options: nil)
                    guard let album = collectionFetchResult.firstObject else { return }
                    self.saveVideo(videoURL: videoURL, to: album)
                } else {
                    print("azmiiii", "Error creating album: \(error?.localizedDescription ?? "")")
                }
            })
        }
    }

    private func albumExists(albumName: String) -> Bool {
        let fetchOptions = PHFetchOptions()
        fetchOptions.predicate = NSPredicate(format: "title = %@", albumName)
        let collection = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: fetchOptions)
        return collection.firstObject != nil
    }
    
    func getMediaIfExist(url: URL) -> URL? {
        guard let docFolderURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return nil
        }
        
        let fileName = url.lastPathComponent
        let fileURL = docFolderURL.appendingPathComponent(fileName)
        
        if FileManager.default.fileExists(atPath: fileURL.path) {
            return fileURL
        } else {
            print("azmiiii", "Tidak Ada")
            return nil
        }
    }

    private func saveVideo(videoURL: URL, to album: PHAssetCollection) {
        PHPhotoLibrary.shared().performChanges({
            
            if let filepath = self.getMediaIfExist(url: videoURL) {
                if filepath.absoluteString.contains(".jpg") {
                    let assetChangeRequest = PHAssetChangeRequest.creationRequestForAssetFromImage(atFileURL: videoURL)
                    let albumChangeRequest = PHAssetCollectionChangeRequest(for: album)
                    let enumeration: NSArray = [assetChangeRequest!.placeholderForCreatedAsset!]
                    albumChangeRequest?.addAssets(enumeration)
                } else {
                    let assetChangeRequest = PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: videoURL)
                    let albumChangeRequest = PHAssetCollectionChangeRequest(for: album)
                    let enumeration: NSArray = [assetChangeRequest!.placeholderForCreatedAsset!]
                    albumChangeRequest?.addAssets(enumeration)
                }
            }
        }, completionHandler: { success, error in
            DispatchQueue.main.async { KKLoading.shared.hide() }
            if success {
                
                DispatchQueue.main.async { Toast.share.show(message: "Successfully saved media to album") }
                print("azmiiii", "Successfully saved video to album")
            } else {
                DispatchQueue.main.async { Toast.share.show(message: "Error saving media to album") }
                print("azmiiii", "Error saving video to album: \(error?.localizedDescription ?? "")")
            }
        })
    }
    
    // Function to save a photo to the Photos library
    func savePhotoToAlbum(photoImage: UIImage, albumName: String) {
        if albumExists(albumName: albumName) {
            let fetchOptions = PHFetchOptions()
            fetchOptions.predicate = NSPredicate(format: "title = %@", albumName)
            let collection = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: fetchOptions)
            if let album = collection.firstObject {
                saveImage(photoImage, to: album)
            }
        } else {
            var albumPlaceholder: PHObjectPlaceholder?
            PHPhotoLibrary.shared().performChanges({
                let createAlbumRequest = PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: albumName)
                albumPlaceholder = createAlbumRequest.placeholderForCreatedAssetCollection
            }, completionHandler: { success, error in
                if success {
                    guard let albumPlaceholder = albumPlaceholder else { return }
                    let collectionFetchResult = PHAssetCollection.fetchAssetCollections(withLocalIdentifiers: [albumPlaceholder.localIdentifier], options: nil)
                    guard let album = collectionFetchResult.firstObject else { return }
                    self.saveImage(photoImage, to: album)
                } else {
                    print("azmiiii", "Error creating album: \(error?.localizedDescription ?? "")")
                }
            })
        }
    }

    // Function to save an image to an album
    private func saveImage(_ photoImage: UIImage, to album: PHAssetCollection) {
        PHPhotoLibrary.shared().performChanges({
            let assetChangeRequest = PHAssetChangeRequest.creationRequestForAsset(from: photoImage)
            let albumChangeRequest = PHAssetCollectionChangeRequest(for: album)
            if let assetPlaceholder = assetChangeRequest.placeholderForCreatedAsset {
                let enumeration: NSArray = [assetPlaceholder]
                albumChangeRequest?.addAssets(enumeration)
            }
        }, completionHandler: { success, error in
            DispatchQueue.main.async { KKLoading.shared.hide() }
            if success {
                print("azmiiii", "Successfully saved photo to album")
            } else {
                print("azmiiii", "Error saving photo to album: \(error?.localizedDescription ?? "")")
            }
        })
    }
}
