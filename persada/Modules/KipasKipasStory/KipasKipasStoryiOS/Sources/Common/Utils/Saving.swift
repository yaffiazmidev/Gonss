import Photos

extension URL {
    static var temporaryStoryPhotoPath: URL {
        return URL(fileURLWithPath: NSTemporaryDirectory())
            .appendingPathComponent("kipaskipas-temp-story-photo")
            .appendingPathExtension("jpeg")
    }
    
    static var temporaryStoryVideoPath: URL {
        return URL(fileURLWithPath: NSTemporaryDirectory())
            .appendingPathComponent("kipaskipas-temp-story-video")
            .appendingPathExtension("mp4")
    }
}

func saveStoryVideoToGallery(completion: @escaping (Bool, Error?) -> Void) {
    DispatchQueue.main.async {
        PHPhotoLibrary.requestAuthorization { status in
            if status == .authorized {
                PHPhotoLibrary.shared().performChanges( {
                    PHAssetChangeRequest.creationRequestForAssetFromVideo(
                        atFileURL: URL.temporaryStoryVideoPath
                    )
                }, completionHandler: { (isSaved, error) in
                    DispatchQueue.main.async {
                        completion(isSaved, error)
                    }
                })
            }
        }
    }
}

public extension Data {
    @discardableResult
    func writeToTemporaryStoryImagePath() -> URL {
        let url = URL.temporaryStoryPhotoPath
        
        if FileManager.default.fileExists(atPath: url.absoluteString) {
            try? FileManager.default.removeItem(atPath: url.absoluteString)
        }
        
        try? write(to: url)
        
        return url
    }
}

