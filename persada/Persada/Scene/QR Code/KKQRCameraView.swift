//
//  KKQRCameraView.swift
//  KipasKipas
//
//  Created by Rahmat Trinanda Pramudya Amar on 27/01/23.
//  Copyright © 2023 Koanba. All rights reserved.
//

import UIKit
import AVFoundation
import KipasKipasShared

class KKQRCameraView: UIView {
    
    lazy var previewView: KKCameraLivePreviewView = {
        let view = KKCameraLivePreviewView()
        view.layer.cornerRadius = 20
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
    
    
    lazy var pickFromGalleryLabel: UILabel = {
        let label = UILabel()
        label.text = "Pilih dari Galeri"
        label.font = UIFont(name: "AirbnbCerealApp-Medium", size: 14)
        label.textAlignment = .center
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .black
        
        addSubViews([previewView, closeView, flashView, pickFromGalleryLabel])
        
        previewView.anchor(top: safeAreaLayoutGuide.topAnchor, left: leftAnchor, bottom: pickFromGalleryLabel.topAnchor, right: rightAnchor, paddingBottom: 32)
        closeView.anchor(top: safeAreaLayoutGuide.topAnchor, left: leftAnchor, paddingTop: 12, paddingLeft: 12, width: 42, height: 42)
        flashView.anchor(top: safeAreaLayoutGuide.topAnchor, right: rightAnchor, paddingTop: 12, paddingRight: 12, width: 42, height: 42)
        pickFromGalleryLabel.anchor(bottom: safeAreaLayoutGuide.bottomAnchor, paddingBottom: 16, height: 42)
        pickFromGalleryLabel.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateFlashButton(_ mode: AVCaptureDevice.FlashMode){
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
    
    func addFocusLayer(){
        let squareSize = previewView.bounds.width - 44
        let rect = CGRect(x: 22, y: (previewView.bounds.height - squareSize) / 2, width: squareSize, height: squareSize)
        let squarePathCenter = CGMutablePath()
        squarePathCenter.addRect(previewView.bounds)
        squarePathCenter.addRoundedRect(in: rect, cornerWidth: 16.0, cornerHeight: 16.0)

        let maskLayer = CAShapeLayer()
        maskLayer.path = squarePathCenter
        maskLayer.fillColor = UIColor.black.withAlphaComponent(0.6).cgColor
        maskLayer.fillRule = .evenOdd

        previewView.layer.addSublayer(maskLayer)
    }
}
