import UIKit
import Photos

public struct MediaLibraryFetcher {
    
   public static func fetchPhotos(
    targetSize: CGSize,
    fetchLimit: Int = 1
   ) async throws -> [UIImage] {
        // Request authorization
        guard let status = await getAuthorizationStatus(), status == .authorized else {
            throw MediaLibraryFetcherError.accessDenied
        }
        
        return try await withCheckedThrowingContinuation { continuation in
            fetchPhotosContinuation(
                targetSize: targetSize,
                fetchLimit: fetchLimit
            ) { result in
                continuation.resume(with: result)
            }
        }
    }
    
    public static func getAuthorizationStatus() async -> PHAuthorizationStatus? {
        var authorizationStatus: PHAuthorizationStatus?
        
        if #available(iOS 14, *) {
            authorizationStatus = await PHPhotoLibrary.requestAuthorization(for: .readWrite)
        } else {
            PHPhotoLibrary.requestAuthorization { status in authorizationStatus = status }
        }
        
        return authorizationStatus
    }

    private static func fetchPhotosContinuation(
        targetSize: CGSize,
        fetchLimit: Int,
        completion: @escaping (Result<[UIImage], Error>) -> Void
    ) {
        var images: [UIImage] = []
        
        // Fetch assets from the photo library
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        fetchOptions.fetchLimit = fetchLimit
        
        let assets = PHAsset.fetchAssets(with: .image, options: fetchOptions)
        
        let imageManager = PHCachingImageManager()
        
        let imageRequestOptions = PHImageRequestOptions()
        imageRequestOptions.isSynchronous = true
        imageRequestOptions.deliveryMode = .highQualityFormat
        
        let group = DispatchGroup()
        
        assets.enumerateObjects { (asset, _, _) in
            group.enter()
      
            let scale = UIScreen.main.scale
            let scaledSize = CGSize(
                width: targetSize.width * scale,
                height: targetSize.height * scale
            )
            imageManager.requestImage(for: asset, targetSize: scaledSize, contentMode: .default, options: imageRequestOptions) { image, _ in
                
                if let image = image {
                    images.append(image)
                }
                group.leave()
            }
        }
        
        group.notify(queue: .main) {
            completion(.success(images))
        }
    }
    
    @discardableResult
    public static func authorizationStatus() -> PHAuthorizationStatus {
        return PHPhotoLibrary.authorizationStatus()
    }
}

enum MediaLibraryFetcherError: Error {
    case accessDenied
}
