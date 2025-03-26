//
//  ProfilePicturePreviewController.swift
//  KipasKipas
//
//  Created by Rahmat Trinanda Pramudya Amar on 15/12/23.
//  Copyright © 2023 Koanba. All rights reserved.
//

import UIKit
import Kingfisher

class ProfilePicturePreviewController: UIViewController {
    
    private let mainView: ProfilePicturePreviewView
    private let image: UIImage?
    private let url: String?
    
    public init(image: UIImage? = nil, url: String? = nil) {
        mainView = ProfilePicturePreviewView()
        self.image = image
        self.url = url
        super.init(nibName: nil, bundle: nil)
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        super.loadView()
        view = mainView
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupOnTap()
    }
    
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        mainView.previewImageView.frame = mainView.scrollView.bounds
        mainView.scrollView.zoomScale = mainView.scrollView.minimumZoomScale
    }
}

//MARK: - Helper
private extension ProfilePicturePreviewController {
    private func setupView() {
        mainView.previewImageView.image = image // default thumbnail
        if let string = url, let url = URL(string: string) {
            mainView.previewImageView.kf.setImage(with: url) // load source
        }
        mainView.scrollView.delegate = self
    }
    
    private func setupOnTap() {
        let blurTap = UITapGestureRecognizer(target: self, action: #selector(handleBlurTap(_:)))
        blurTap.numberOfTapsRequired = 1
        mainView.addGestureRecognizer(blurTap)
        
        let doubleTapGesture = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap(_:)))
        doubleTapGesture.numberOfTapsRequired = 2
        mainView.previewImageView.addGestureRecognizer(doubleTapGesture)
        
        blurTap.require(toFail: doubleTapGesture)
    }
    
    @objc private func handleBlurTap(_ gestureRecognizer: UITapGestureRecognizer) {
        dismiss(animated: true)
    }
    
    @objc private func handleDoubleTap(_ gestureRecognizer: UITapGestureRecognizer) {
        if mainView.scrollView.zoomScale > mainView.scrollView.minimumZoomScale {
            mainView.scrollView.setZoomScale(mainView.scrollView.minimumZoomScale, animated: true)
        } else {
            mainView.scrollView.setZoomScale(mainView.scrollView.maximumZoomScale, animated: true)
        }
    }
}

extension ProfilePicturePreviewController: UIScrollViewDelegate {
    public func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return mainView.previewImageView
    }
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.zoomScale == scrollView.minimumZoomScale {
            scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: false)
            scrollView.isScrollEnabled = false
        } else {
            scrollView.isScrollEnabled = true
        }
    }
}
