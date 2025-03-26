//
//  KKCameraView.swift
//  KipasKipas
//
//  Created by Rahmat Trinanda Pramudya Amar on 27/10/22.
//  Copyright © 2022 Koanba. All rights reserved.
//

import UIKit
import AVFoundation

class KKCameraView: UIView{
    var shootHeightAnchor = NSLayoutConstraint()
    var shootWidthAnchor = NSLayoutConstraint()
    
    lazy var previewView: KKCameraLivePreviewView = {
        let view = KKCameraLivePreviewView()
        view.layer.cornerRadius = 20
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var closeView: UIView = {
        let view = UIView()
        view.backgroundColor = .black.withAlphaComponent(0.12)
        view.layer.cornerRadius = 21
        
        let icon = UIImageView()
        icon.contentMode = .scaleAspectFit
        icon.image = UIImage(named: .get(.iconCameraClose))
        
        view.addSubview(icon)
        view.translatesAutoresizingMaskIntoConstraints = false
        icon.anchor(width: 32, height: 32)
        icon.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        icon.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        
        return view
    }()
    
    lazy var timerLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 17, weight: .semibold)
        label.textColor = .white
        return label
    }()
    
    lazy var timerView: UIView = {
        let view = UIView()
        view.backgroundColor = .red
        view.layer.cornerRadius = 4
        view.translatesAutoresizingMaskIntoConstraints = false
        view.alpha = 0
        view.addSubview(timerLabel)
        timerLabel.anchor(top: view.topAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 4, paddingLeft: 4, paddingBottom: 4, paddingRight: 4)
        
        return view
    }()
    
    private lazy var flashIcon: UIImageView = {
        let icon = UIImageView()
        icon.contentMode = .scaleAspectFit
        icon.anchor(width: 28, height: 28)
        return icon
    }()
    
    lazy var flashView: UIView = {
        let view = UIView()
        view.backgroundColor = .black.withAlphaComponent(0.12)
        view.layer.cornerRadius = 21
        
        view.addSubview(flashIcon)
        view.translatesAutoresizingMaskIntoConstraints = false
        
        flashIcon.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        flashIcon.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        
        return view
    }()
    
    lazy var videoSegmentLabel: UILabel = {
        let label = UILabel()
        label.text = "Video"
        label.font = .roboto(.medium, size: 18)
        label.textAlignment = .center
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var liveStreamingSegmentLabel: UILabel = {
        let label = UILabel()
        label.text = "Live"
        label.font = .roboto(.medium, size: 18)
        label.textAlignment = .center
        label.textColor = .whiteAlpha30
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var videoSegmentView: UIView = {
        let view = UIView()
        view.addSubview(videoSegmentLabel)
        videoSegmentLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        videoSegmentLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var photoSegmentLabel: UILabel = {
        let label = UILabel()
        label.text = "Foto"
        label.font = .roboto(.black, size: 18)
        label.textAlignment = .center
        label.textColor = .whiteAlpha30
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var liveStreamingSegmentView: UIView = {
        let view = UIView()
        view.addSubview(liveStreamingSegmentLabel)
        liveStreamingSegmentLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        liveStreamingSegmentLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var photoSegmentView: UIView = {
        let view = UIView()
        view.addSubview(photoSegmentLabel)
        photoSegmentLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        photoSegmentLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var segmentedStackView: UIStackView = {
        let view = UIStackView(arrangedSubviews: [photoSegmentView, videoSegmentView, liveStreamingSegmentView])
        view.translatesAutoresizingMaskIntoConstraints = false
        view.axis = .horizontal
        view.alignment = .fill
        view.distribution = .fill
        view.spacing = 20
        photoSegmentView.anchors.height.equal(32)
        photoSegmentView.anchors.width.equal(42)
        videoSegmentView.anchors.height.equal(32)
        videoSegmentView.anchors.width.equal(42)
        liveStreamingSegmentView.anchors.height.equal(32)
        liveStreamingSegmentView.anchors.width.equal(42)
        return view
    }()
    
    lazy var galleryImageView: UIImageView = {
        let view = UIImageView()
        view.backgroundColor = .black
        view.layer.borderWidth = 2
        view.layer.borderColor = UIColor.white.cgColor
        view.layer.cornerRadius = 4
        view.translatesAutoresizingMaskIntoConstraints = false
        view.contentMode = .scaleAspectFill
        view.clipsToBounds = true
        view.isUserInteractionEnabled = true
        return view
    }()
    
    lazy var shootView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.layer.cornerRadius = 32
        view.layer.borderWidth = 2
        view.layer.borderColor = UIColor.white.cgColor
        view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(shootButton)
        return view
    }()
    
    lazy var shootButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .red
        button.layer.cornerRadius = 27
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    lazy var flipButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: .get(.iconCameraChange)), for: .normal)
        button.tintColor = .white
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .black
        
        addSubviews([previewView, timerView, closeView, flashView, segmentedStackView, galleryImageView, shootView, flipButton])
        
        previewView.anchor(top: safeAreaLayoutGuide.topAnchor, left: leftAnchor, bottom: galleryImageView.topAnchor, right: rightAnchor, paddingBottom: 32)
        closeView.anchor(top: safeAreaLayoutGuide.topAnchor, left: leftAnchor, paddingTop: 12, paddingLeft: 12, width: 42, height: 42)
        timerView.anchor(top: safeAreaLayoutGuide.topAnchor, paddingTop: 12)
        timerView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        
        flashView.anchor(top: safeAreaLayoutGuide.topAnchor, right: rightAnchor, paddingTop: 12, paddingRight: 12, width: 42, height: 42)
        galleryImageView.anchor(left: leftAnchor, bottom: safeAreaLayoutGuide.bottomAnchor, paddingLeft: 32, paddingBottom: 16, width: 42, height: 42)
        flipButton.anchor(bottom: safeAreaLayoutGuide.bottomAnchor, right: rightAnchor, paddingBottom: 16, paddingRight: 32, width: 42, height: 42)
        segmentedStackView.anchor(bottom: safeAreaLayoutGuide.bottomAnchor, paddingBottom: 16, height: 42)
        segmentedStackView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        shootView.anchor(bottom: previewView.bottomAnchor, paddingBottom: 24, width: 64, height: 64)
        shootView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        shootWidthAnchor = shootButton.widthAnchor.constraint(equalToConstant: 54)
        shootHeightAnchor = shootButton.heightAnchor.constraint(equalToConstant: 54)
        shootWidthAnchor.isActive = true
        shootHeightAnchor.isActive = true
        shootButton.centerXAnchor.constraint(equalTo: shootView.centerXAnchor).isActive = true
        shootButton.centerYAnchor.constraint(equalTo: shootView.centerYAnchor).isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateFlashButton(_ mode: AVCaptureDevice.FlashMode) {
        var image = ""
        var color = UIColor.white
        
        switch mode {
        case .on:
            image = "bolt.fill"
            color = .yellow
        case .off:
            image = "bolt.slash"
            color = .white
        default:
            image = "bolt.badge.a"
            color = .white
        }
        
        flashIcon.image = UIImage(systemName: image)
        flashIcon.tintColor = color
    }
    
    func updateSegmentView(_ isVideo: Bool){
        if isVideo{
            videoSegmentLabel.font = .roboto(.black, size: 18)
            videoSegmentLabel.textColor = .white
            photoSegmentLabel.font = .roboto(.medium, size: 18)
            photoSegmentLabel.textColor = .whiteAlpha30
        }else{
            videoSegmentLabel.font = .roboto(.medium, size: 18)
            videoSegmentLabel.textColor = .whiteAlpha30
            photoSegmentLabel.font = .roboto(.black, size: 18)
            photoSegmentLabel.textColor = .white
        }
    }
    
    func updateLive(show: Bool) {
        liveStreamingSegmentView.isHidden = !show
    }
}
