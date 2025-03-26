//
//  KKPlayerViewController.swift
//  KipasKipasDirectMessageUI
//
//  Created by Administer on 2024/7/13.
//


import AVKit
class KKPlayerViewController: AVPlayerViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(closeIconImageView)
        registerTapGesture()
    }
    
    private lazy var closeIconImageView: UIImageView = {
        let imageView = UIImageView(frame: CGRect(x: 24, y: 50, width: 40, height: 40))
        imageView.image = UIImage(systemName: "xmark")?.withTintColor(.white, renderingMode: .alwaysOriginal)
        imageView.contentMode = .center
        imageView.layer.cornerRadius = 20
        imageView.backgroundColor = UIColor(white: 0, alpha: 0.2)
        imageView.isUserInteractionEnabled = true
        return imageView
    }()
    
    private func registerTapGesture() {
        let onTapGestureCloseIcon = UITapGestureRecognizer(target: self, action: #selector(handleDismiss))
        closeIconImageView.isUserInteractionEnabled = true
        closeIconImageView.addGestureRecognizer(onTapGestureCloseIcon)
    }
    
    @objc private func handleDismiss() {
        dismiss(animated: true)
    }
}
