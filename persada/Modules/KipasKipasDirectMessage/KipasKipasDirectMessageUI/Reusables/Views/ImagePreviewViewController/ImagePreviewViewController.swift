//
//  ImagePreviewViewController.swift
//  KipasKipasDirectMessageUI
//
//  Created by DENAZMI on 20/07/23.
//

import UIKit

public class ImagePreviewViewController: UIViewController {
    
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.delegate = self
        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = 5.0
        scrollView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        return scrollView
    }()
    
    private lazy var previewImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.isUserInteractionEnabled = true
        return imageView
    }()
    
    private lazy var closeIconImageView: UIImageView = {
        let imageView = UIImageView(frame: CGRect(x: 24, y: 50, width: 40, height: 40))
        imageView.image = UIImage(systemName: "xmark")?.withTintColor(.white, renderingMode: .alwaysOriginal)
        imageView.contentMode = .center
        imageView.layer.cornerRadius = 20
        imageView.backgroundColor = UIColor(white: 0, alpha: 0.2)
        imageView.isUserInteractionEnabled = true
        return imageView
    }()
    
    private let image: UIImage?
    private let url: URL?

    public override func viewDidLoad() {
        super.viewDidLoad()
        handleViewDidLoad()
    }
    
    public init(url: URL?, image: UIImage? = nil) {
        self.url = url
        self.image = image
        super.init(nibName: nil, bundle: nil)
    }

    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        // Atur ukuran dan posisi imageView ketika tata letak berubah
        previewImageView.frame = scrollView.bounds

        // Atur skala zoom awal untuk memadukan gambar ke dalam scrollView
        scrollView.zoomScale = scrollView.minimumZoomScale
    }
    
    @objc private func handleDismiss() {
        dismiss(animated: true)
    }
    
    private func registerTapGesture() {
        let onTapGestureCloseIcon = UITapGestureRecognizer(target: self, action: #selector(handleDismiss))
        closeIconImageView.isUserInteractionEnabled = true
        closeIconImageView.addGestureRecognizer(onTapGestureCloseIcon)
    }
    
    private func handleViewDidLoad() {
        view.backgroundColor = .black.withAlphaComponent(0.9)
        navigationController?.isNavigationBarHidden = true
        scrollView.frame = view.bounds
        view.addSubview(scrollView)
        scrollView.addSubview(previewImageView)
        view.addSubview(closeIconImageView)
        if let image = image {
            previewImageView.image = image
        } else {
            previewImageView.loadImage(from: url)
        }
        
        setDoubleTapGesture()
        registerTapGesture()
    }
    
    private func setDoubleTapGesture() {
        // Tambahkan gesture recognizer untuk double tap
        let doubleTapGesture = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap(_:)))
        doubleTapGesture.numberOfTapsRequired = 2
        previewImageView.addGestureRecognizer(doubleTapGesture)
    }
    
    @objc private func handleDoubleTap(_ gestureRecognizer: UITapGestureRecognizer) {
        if scrollView.zoomScale > scrollView.minimumZoomScale {
            scrollView.setZoomScale(scrollView.minimumZoomScale, animated: true)
        } else {
            scrollView.setZoomScale(scrollView.maximumZoomScale, animated: true)
        }
    }
}

extension ImagePreviewViewController: UIScrollViewDelegate {
    public func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return previewImageView
    }
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // Black scrollnya ketika zoomScale sama dengan minimumZoomScale
        if scrollView.zoomScale == scrollView.minimumZoomScale {
            scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: false)
            scrollView.isScrollEnabled = false
        } else {
            scrollView.isScrollEnabled = true
        }
    }
}
