//
//  KKMediaPicker.swift
//  KipasKipasShared
//
//  Created by Rahmat Trinanda Pramudya Amar on 19/12/23.
//

import UIKit
import Photos

public protocol KKMediaPickerDelegate: AnyObject {
    func didPermissionRejected()
    func didLoading(isLoading: Bool)
    func didSelectMedia(media item: KKMediaItem)
    func didSelectMedia(originalUrl: URL, type: KKMediaItemType)
    func didError(_ message: String)
    func videoNeedTrim(url: URL)
}

public extension KKMediaPickerDelegate {
    func didSelectMedia(media item: KKMediaItem) {
        didSelectMedia(media: item)
    }
    
    func didSelectMedia(originalUrl: URL, type: KKMediaItemType) {
        didSelectMedia(originalUrl: originalUrl, type: type)
    }
    
    func didError(_ message: String) {
        didError(message)
    }
    
    func videoNeedTrim(url: URL) {
        videoNeedTrim(url: url)
    }
}

public class KKMediaPicker: UIViewController {
    
    public weak var delegate: KKMediaPickerDelegate?
    
    public var presentationStyle: UIModalPresentationStyle = .overFullScreen
    /// This for array of media item type, value: photo, video
    public var types: [KKMediaItemType] = [.photo, .video]
    /// This for type of post. Feed or Story
    public var postType: KKMediaPostType = .feed
    /// This for delegate function, if the value true (default),  then the return is KKMediaItem. If not, the return is original URL
    public var useCallbackKKMedia: Bool = true
    /// This for max duration(seconds) of video. Set value if you want to show video only in duration
    public var videoMaxDuration: Double? = nil
    
    public init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension KKMediaPicker {
    public func show(in controller: UIViewController) {
        self.delegate?.didLoading(isLoading: true)
        //        requestPermission { // Di set off, karena permission dibutuhkan ketika mau write/edit
        DispatchQueue.main.async {
            self.openPicker(in: controller)
        }
        //        } onRejected: {
        //            self.delegate?.didLoading(isLoading: false)
        //            self.delegate?.didPermissionRejected()
        //        }
    }
    
    public static func showAlertForAskPhotoPermisson(in controller: UIViewController) {
        let actionSheet = UIAlertController(title: "", message: .get(.photosask), preferredStyle: .alert)
        
        let allowFullAccessAction = UIAlertAction(title: .get(.photosaccessall), style: .default) { _ in
            if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(settingsUrl)
            }
        }
        actionSheet.addAction(allowFullAccessAction)
        
        let cancelAction = UIAlertAction(title: .get(.cancel), style: .cancel, handler: nil)
        actionSheet.addAction(cancelAction)
        
        DispatchQueue.main.async { controller.present(actionSheet, animated: true) }
    }
    
}

// MARK: - Helper
private extension KKMediaPicker {
    private func openPicker(in controller: UIViewController) {
        modalPresentationStyle = presentationStyle
        controller.present(self, animated: false) {
            var mediaTypes: [String] = []
            
            if self.types.contains(.photo) {
                mediaTypes.append("public.image")
            }
            
            if self.types.contains(.video) {
                mediaTypes.append("public.movie")
            }
            KKLogFile.instance.log(label:"KKMediaPicker", message: "openPicker")
            
            let picker = UIImagePickerController()
            picker.sourceType = .photoLibrary
            picker.mediaTypes = mediaTypes
            picker.delegate = self
            picker.modalPresentationStyle = self.presentationStyle
            picker.videoExportPreset = AVAssetExportPresetPassthrough
            self.present(picker, animated: true) {
                self.delegate?.didLoading(isLoading: false)
            }
        }
    }
    
    private func requestPermission(onGranted: @escaping (() -> Void), onRejected:  @escaping (() -> Void)) {
        PHPhotoLibrary.requestAuthorization { status in
            if status == .authorized {
                onGranted()
            } else {
                onRejected()
            }
        }
    }
    
    private func handlePhoto(url: URL) {
        guard useCallbackKKMedia else {
            dismiss(animated: false) {
                self.delegate?.didSelectMedia(originalUrl: url, type: .photo)
            }
            return
        }
        
        if let item = KKMediaHelper.instance.photo(url: url, postType: postType) {
            dismiss(animated: false) {
                self.delegate?.didSelectMedia(media: item)
            }
        }
    }
    
    private func handleVideo(url: URL) {
        delegate?.didLoading(isLoading: true)
        
        let asset = AVAsset(url: url)
        let duration = asset.duration
        let durationSeconds = CMTimeGetSeconds(duration)
        
        let maxDuration = videoMaxDuration ?? 0
        
        if durationSeconds >= maxDuration && maxDuration != 0 {
            DispatchQueue.main.async {
                self.dismiss(animated: false) {
                    self.delegate?.didLoading(isLoading: false)
                    self.delegate?.videoNeedTrim(url: url)
                }
            }
            return
        }
        
        KKLogFile.instance.log(label:"KKMediaPicker", message: "handleVideo...1")
        
        guard useCallbackKKMedia else {
            dismiss(animated: false) {
                self.delegate?.didLoading(isLoading: false)
                self.delegate?.didSelectMedia(originalUrl: url, type: .video)
            }
            return
        }
        
        KKMediaHelper.instance.video(url: url, postType: postType) { [weak self] item, _  in
            guard let self = self, let item = item else { return }
            
            DispatchQueue.main.async {
                self.dismiss(animated: false) {
                    self.delegate?.didLoading(isLoading: false)
                    self.delegate?.didSelectMedia(media: item)
                }
            }
        }
    }
}

extension KKMediaPicker: UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    
    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
        dismiss(animated: false)
    }
    
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        KKLogFile.instance.log(label:"KKMediaPicker", message: "imagePickerController..finish")
        var hasMedia = false
        if let imageURL = info[.imageURL] as? URL {
            hasMedia = true
            picker.dismiss(animated: true) {
                self.handlePhoto(url: imageURL)
            }
        } else {
            KKLogFile.instance.log(label:"KKMediaPicker", message: "imagePickerController... no imageURL", level: .error)
        }
        
        func acceptVideo(_ url: URL) {
            picker.dismiss(animated: true) {
                self.handleVideo(url: url)
            }
        }
        
        if(!hasMedia){
            if let phAsset = info[.phAsset] as? PHAsset {
                switch phAsset.mediaType {
                case .image:
                    KKLogFile.instance.log(label:"KKMediaPicker", message: "imagePickerController... phAsset image")
                case .video:
                    KKLogFile.instance.log(label:"KKMediaPicker", message: "imagePickerController... phAsset Video")
                    PHImageManager.default()
                        .requestAVAsset(forVideo: phAsset,
                                        options: PHVideoRequestOptions(),
                                        resultHandler: {(asset: AVAsset?, audioMix: AVAudioMix?, info: [AnyHashable : Any]?) -> Void in
                        if let urlAsset = asset as? AVURLAsset {
                            DispatchQueue.main.async {
                                picker.dismiss(animated: true) { [weak self] in
                                    guard let self = self else { return }
                                    KKLogFile.instance.log(label:"KKMediaPicker", message: "imagePickerController... phAsset handleVideo-A")
                                    self.handleVideo(url: urlAsset.url)
                                }
                            }
                        }
                    })
                case .audio:
                    print("Audio")
                    KKLogFile.instance.log(label:"KKMediaPicker", message: "imagePickerController... phAsset Audio")
                default:
                    KKLogFile.instance.log(label:"KKMediaPicker", message: "imagePickerController... phAsset UNKNOWN", level: .error)
                }
            } else {
                KKLogFile.instance.log(label:"KKMediaPicker", message: "imagePickerController... NO phAsset", level: .error)
            }

        }
    }
}
