//
//  KKCameraPreviewViewController.swift
//  KipasKipas
//
//  Created by Rahmat Trinanda Pramudya Amar on 28/10/22.
//  Copyright © 2022 Koanba. All rights reserved.
//

import UIKit
import AVFoundation

public class KKCameraPreviewViewController: UIViewController{
    private let mainView: KKCameraPreviewView
    private let playerView = VideoPlayerView()
    
    private let item: KKMediaItem
    
    public var handleDoneTapped: (() -> Void)?
    
    public init(item: KKMediaItem){
        self.mainView = KKCameraPreviewView()
        self.item = item
        super.init(nibName: nil, bundle: nil)
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func loadView() {
        super.loadView()
        self.view = mainView
        setupOnTap()
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        KKLogFile.instance.log(label:"KKCameraPreviewViewController", message: "open \(item.type)")
        
        if item.type == .video {
            setVideo()
        }
        
        if item.type == .photo {
            mainView.imageView.image = UIImage(data: item.data ?? Data())
        }
    }
    
    public override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        playerView.destroy()
    }
}

// MARK: - OnTap Handler
private extension KKCameraPreviewViewController{
    private func setupOnTap(){
        mainView.closeView.onTap(action: handleClose)
        mainView.doneLabel.onTap(action: handleDone)
    }
    
    @objc private func handleClose(){
        dismiss(animated: true, completion: nil)
    }
    
    private func handleDone(){
        dismiss(animated: true) {
            self.handleDoneTapped?()
        }
    }
}

//MARK: - handler
private extension KKCameraPreviewViewController {
    @objc private func appMovedToBackground() {
        playerView.pause(reason: .userInteraction)
    }
    
    @objc private func appBecomeActive() {
        if item.type == .video {
            mainView.imageView.layer.sublayers?.removeAll()
            playerView.seek(to: .zero)
            playerView.resume()
        }
    }
    
    private func setVideo(){
        playerView.isAutoReplay = true
        playerView.shouldPlayAfterPreloadFinished = false
        
        let url = URL(fileURLWithPath: item.path)
        
        let asset = AVAsset(url: url)
        
        if isPortrait(asset) {
            playerView.contentMode = .scaleAspectFill
        } else {
            playerView.contentMode = .scaleAspectFit
        }
        
        playerView.play(for: url)

        mainView.imageView.addSubview(playerView)
        playerView.anchors.edges.pin()
    }
    
    private func isPortrait(_ asset: AVAsset) -> Bool {
        guard let videoTrack = asset.tracks(withMediaType: .video).first else {
            return false
        }
        
        let size = videoTrack.naturalSize
        let transform = videoTrack.preferredTransform
        
        // Determine the video orientation based on natural size and transform
        if size.width > size.height {
            // Landscape video
            if transform.a == 0 && abs(transform.b) == 1 && abs(transform.c) == 1 && transform.d == 0 {
                // 90° or 270° rotation
                return true
            } else {
                // No rotation or 180° rotation
                return false
            }
        } else {
            // Portrait video
            if transform.a == 0 && abs(transform.b) == 1 && abs(transform.c) == 1 && transform.d == 0 {
                // 90° or 270° rotation
                return false
            } else {
                // No rotation or 180° rotation
                return true
            }
        }
    }
}

