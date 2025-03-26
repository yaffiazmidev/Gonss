import UIKit
import AVFoundation
import MobileCoreServices
import KipasKipasShared
import Photos

public struct ImagePickerMediaFile {
    public let data: Data
    public let name: String
    public let mimeType: String
    public let isVideo: Bool
    public let thumbnail: UIImage?
    
    
    public init(data: Data, name: String, mimeType: String, isVideo: Bool, thumbnail: UIImage?) {
        self.data = data
        self.name = name
        self.mimeType = mimeType
        self.isVideo = isVideo
        self.thumbnail = thumbnail
    }
}

public protocol ImagePickerRouterDelegate: AnyObject {
    func imagePickerRouter(_ imagePickerRouter: ImagePickerRouter, didFinishPickingMediaFile mediaFile: ImagePickerMediaFile)
}

public class ImagePickerRouter: NSObject {
    
    typealias MediaFile = ImagePickerMediaFile
    
    public enum SourceType {
        case photoLibrary
        case photoCamera
        case videoCamera
    }
    
    public weak var delegate: ImagePickerRouterDelegate?
    
    private unowned let target: UIViewController
    
    private let sourceTypes: Set<SourceType>
    
    public var didFinishPickingMediaFile: ((ImagePickerMediaFile) -> Void)?
    
    public init(target: UIViewController, sourceTypes: Set<SourceType>) {
        self.target = target
        self.sourceTypes = sourceTypes
        super.init()
    }
    
    public func presentAlert(completion: (() -> Void)? = nil) {
        let alert = UIAlertController(title: "Attach file", message: nil, preferredStyle: .actionSheet)
        
        if sourceTypes.contains(.photoLibrary) {
            alert.addAction(UIAlertAction(title: "Choose from Library", style: .default) { [weak self] _ in
                self?.presentMediaFilePicker(sourceType: .photoLibrary)
            })
        }
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            if sourceTypes.contains(.photoCamera) {
                alert.addAction(UIAlertAction(title: "Take Photo", style: .default) { [weak self] _ in
                    self?.presentMediaFilePicker(sourceType: .photoCamera)
                })
            }
            
            if sourceTypes.contains(.videoCamera) {
                alert.addAction(UIAlertAction(title: "Take Video", style: .default) { [weak self] _ in
                    self?.presentMediaFilePicker(sourceType: .videoCamera)
                })
            }
        }
        
        alert.addAction(UIAlertAction(title: "Close", style: .cancel))
        
        target.present(alert, animated: true, completion: completion)
    }
    
//    private func presentMediaFilePicker(sourceType: SourceType) {
//        let imagePicker = UIImagePickerController()
//
//        switch sourceType {
//        case .photoLibrary:
//            imagePicker.sourceType = .photoLibrary
//            imagePicker.mediaTypes = [String(kUTTypeImage), String(kUTTypeMovie)]
//        case .photoCamera:
//            imagePicker.sourceType = .camera
//            imagePicker.mediaTypes = [String(kUTTypeImage)]
//        case .videoCamera:
//            imagePicker.sourceType = .camera
//            imagePicker.mediaTypes = [String(kUTTypeMovie)]
//        }
//        
//        imagePicker.delegate = self
//        
//        target.present(imagePicker, animated: true)
//    }
    
    private func presentMediaFilePicker(sourceType: SourceType) {
        switch sourceType {
        case .photoLibrary:
            PHPhotoLibrary.requestAuthorization { status in
                if status == .authorized {
                    DispatchQueue.main.async {
                        let imagePicker = UIImagePickerController()
                        imagePicker.sourceType = .photoLibrary
                        imagePicker.mediaTypes = [String(kUTTypeImage), String(kUTTypeMovie)]
                        imagePicker.delegate = self
                        self.target.present(imagePicker, animated: true)
                    }
                } else {
                    self.showAlertForAskPhotoPermisson(in: self.target)
                }
            }
            
        case .photoCamera:
            let imagePicker = KKCameraViewController(type: .photo, canPickFromGallery: false)
            imagePicker.modalPresentationStyle = .fullScreen
            imagePicker.handleMediaSelected = { [weak self] item in
                guard let self = self else { return }
                
                let media = ImagePickerMediaFile(data: item.data ?? Data(), name: item.path.components(separatedBy: "/").last ?? "image.jpeg", mimeType: "image/jpeg", isVideo: false, thumbnail: item.photoThumbnail)
                
                self.didFinishPickingMediaFile?(media)
                self.delegate?.imagePickerRouter(self, didFinishPickingMediaFile: media)
            }
            target.present(imagePicker, animated: true)
        case .videoCamera:
            let imagePicker = KKCameraViewController(type: .video, canPickFromGallery: false)
            imagePicker.modalPresentationStyle = .fullScreen
            imagePicker.handleMediaSelected = { [weak self] item in
                guard let self = self else { return }
                
                let media = ImagePickerMediaFile(data: item.data ?? Data(), name: item.path.components(separatedBy: "/").last ?? "video.mp4", mimeType: "video/mp4", isVideo: true, thumbnail: item.videoThumbnail)
                
                self.didFinishPickingMediaFile?(media)
                self.delegate?.imagePickerRouter(self, didFinishPickingMediaFile: media)
            }
            target.present(imagePicker, animated: true)
        }
    }
    
    private func showAlertForAskPhotoPermisson(in controller: UIViewController) {
        let actionSheet = UIAlertController(title: "", message: "Select more photos or go to Settings to allow access to all photos.", preferredStyle: .alert)
        
        let allowFullAccessAction = UIAlertAction(title:  "Allow access to all photos", style: .default) { _ in
            if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(settingsUrl)
            }
        }
        actionSheet.addAction(allowFullAccessAction)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        actionSheet.addAction(cancelAction)
        
        DispatchQueue.main.async { controller.present(actionSheet, animated: true) }
    }

}

// MARK: - UIImagePickerControllerDelegate & UINavigationControllerDelegate

extension ImagePickerRouter: UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    
    public func imagePickerController(_ picker: UIImagePickerController,
                                      didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let mediaFile = extractMediaFile(from: info) else { return }
        
        picker.dismiss(animated: true) { [weak self] in
            guard let self = self else { return }
            self.didFinishPickingMediaFile?(mediaFile)
            self.delegate?.imagePickerRouter(self, didFinishPickingMediaFile: mediaFile)
        }
    }
    
    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    private func extractMediaFile(from info: [UIImagePickerController.InfoKey : Any]) -> MediaFile? {
        let mediaType = info[UIImagePickerController.InfoKey.mediaType] as! CFString
        
        if CFStringCompare(mediaType, kUTTypeImage, []) == .compareEqualTo {
            return extractImageFile(from: info)
        } else if CFStringCompare(mediaType, kUTTypeMovie, []) == .compareEqualTo {
            return extractVideoFile(from: info)
        }
        
        return nil
    }
    
    private func extractImageFile(from info: [UIImagePickerController.InfoKey : Any]) -> MediaFile? {
        if let imagePath = info[UIImagePickerController.InfoKey.imageURL] as? URL {
            let imageName = imagePath.lastPathComponent
            let ext = (imageName as NSString).pathExtension
            guard let UTI = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, ext as CFString, nil)?.takeRetainedValue() else { return nil }
            guard let retainedValueMimeType = UTTypeCopyPreferredTagWithClass(UTI, kUTTagClassMIMEType)?.takeRetainedValue() else { return nil }
            let mimeType = retainedValueMimeType as String
            guard let img = info[.originalImage] as? UIImage else { return nil }
            let orientedImage = img.fixedOrientation()
            guard let imageData = orientedImage?.pngData() else { return nil }
            
            return MediaFile(data: imageData, name: imageName, mimeType: mimeType, isVideo: false, thumbnail: orientedImage)
        } else {
            guard let originalImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else { return nil }
            guard let imageData = originalImage.jpegData(compressionQuality: 1.0) else { return nil }
            
            return MediaFile(data: imageData, name: "image.jpg", mimeType: "image/jpeg", isVideo: false, thumbnail: originalImage)
        }
    }
    
    private func extractVideoFile(from info: [UIImagePickerController.InfoKey : Any]) -> MediaFile? {
        guard let videoUrl = info[UIImagePickerController.InfoKey.mediaURL] as? URL,
              let videoFileData = try? Data(contentsOf: videoUrl) else { return nil }
        
        let videoName = videoUrl.lastPathComponent
        let ext = (videoName as NSString).pathExtension
        guard let UTI = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, ext as CFString, nil)?.takeRetainedValue(),
              let retainedValueMimeType = UTTypeCopyPreferredTagWithClass(UTI, kUTTagClassMIMEType)?.takeRetainedValue() else { return nil }

        let mimeType = retainedValueMimeType as String
        let videoThumbnail = videoThumbnail(videoUrl.absoluteString)
        
        return MediaFile(data: videoFileData, name: videoName, mimeType: mimeType, isVideo: true, thumbnail: videoThumbnail)
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
            print("Error generating thumbnail: \(error.localizedDescription)")
            return nil
        }
    }
    
}
