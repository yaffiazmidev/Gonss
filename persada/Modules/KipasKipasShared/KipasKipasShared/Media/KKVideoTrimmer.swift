//
//  KKVideoTrimmer.swift
//  KipasKipasShared
//
//  Created by Rahmat Trinanda Pramudya Amar on 20/06/24.
//

import UIKit

public protocol KKVideoTrimmerDelegate: AnyObject {
    func didLoading(_ trimmer: KKVideoTrimmer, isLoading: Bool)
    func didSelectMedia(_ trimmer: KKVideoTrimmer, media item: KKMediaItem)
    func didSelectMedia(_ trimmer: KKVideoTrimmer, originalUrl: URL, type: KKMediaItemType)
    func didError(_ trimmer: KKVideoTrimmer, message: String)
}

public extension KKVideoTrimmerDelegate {
    func didSelectMedia(_ trimmer: KKVideoTrimmer, media item: KKMediaItem) {
        didSelectMedia(trimmer, media: item)
    }
    
    func didSelectMedia(_ trimmer: KKVideoTrimmer, originalUrl: URL, type: KKMediaItemType) {
        didSelectMedia(trimmer, originalUrl: originalUrl, type: type)
    }
}

public class KKVideoTrimmer: UIViewController {
    
    public weak var delegate: KKVideoTrimmerDelegate?
    
    public var presentationStyle: UIModalPresentationStyle = .overFullScreen
    /// This for delegate function, if the value true (default),  then the return is KKMediaItem. If not, the return is original URL
    public var useCallbackKKMedia: Bool = true
    /// This for max duration(seconds) of video. Set value if you want to show video only in duration
    public var maxDuration: Double? = nil
    /// This for type of post. Feed or Story
    public var postType: KKMediaPostType = .feed
    public let videoUrl: URL
    
    public init(videoUrl: URL) {
        self.videoUrl = videoUrl
        super.init(nibName: nil, bundle: nil)
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension KKVideoTrimmer {
    public func show(in controller: UIViewController) {
        self.delegate?.didLoading(self, isLoading: true)
        DispatchQueue.main.async {
            self.openPicker(in: controller)
        }
    }
}

// MARK: - Helper
private extension KKVideoTrimmer {
    private func openPicker(in controller: UIViewController) {
        modalPresentationStyle = presentationStyle
        controller.present(self, animated: false) {
            
            let editor = UIVideoEditorController()
            editor.videoPath = self.videoUrl.path
            editor.videoMaximumDuration = self.maxDuration ?? 0
            editor.delegate = self
            editor.modalPresentationStyle = self.presentationStyle
            editor.videoQuality = .typeHigh
            self.present(editor, animated: true) {
                self.delegate?.didLoading(self, isLoading: false)
            }
        }
    }
    
    private func handleVideo(url: URL) {
        delegate?.didLoading(self, isLoading: true)
        
        KKMediaHelper.instance.video(url: url, postType: postType) { [weak self] item, _  in
            guard let self = self, let item = item else { return }
            
            DispatchQueue.main.async {
                self.dismiss(animated: false) {
                    self.delegate?.didLoading(self, isLoading: false)
                    
                    if self.useCallbackKKMedia {
                        self.delegate?.didSelectMedia(self, media: item)
                        return
                    }
                    
                    self.delegate?.didSelectMedia(self, originalUrl: URL(fileURLWithPath: item.path), type: .video)
                }
            }
        }
    }
}

extension KKVideoTrimmer: UIVideoEditorControllerDelegate & UINavigationControllerDelegate {
    public func videoEditorController(_ editor: UIVideoEditorController, didSaveEditedVideoToPath editedVideoPath: String) {
        editor.delegate = nil
        
        editor.dismiss(animated: true) {
            self.handleVideo(url: URL(fileURLWithPath: editedVideoPath))
        }
    }
    
    public func videoEditorController(_ editor: UIVideoEditorController, didFailWithError error: any Error) {
        editor.delegate = nil
        editor.dismiss(animated: true) {
            self.dismiss(animated: false) {
                self.delegate?.didError(self, message: "Gagal menyimpan video.")
            }
        }
    }
    
    public func videoEditorControllerDidCancel(_ editor: UIVideoEditorController) {
        editor.delegate = nil
        editor.dismiss(animated: true)
        dismiss(animated: false)
    }
}
