//
//  CameraVerifyIdentityPhotoView.swift
//  KipasKipasCamera
//
//  Created by DENAZMI on 02/06/24.
//

import UIKit
import KipasKipasShared

public enum VerifyIdentityCameraType {
    case identity
    case selfie
}

protocol CameraVerifyIdentityPhotoViewDelegate: AnyObject {
    func didClickClose()
    func didClickGuideline()
}

class CameraVerifyIdentityPhotoView: UIView {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var captureInfoLabel: UILabel!
    @IBOutlet weak var captureContainerView: UIView!
    @IBOutlet weak var guidelineContainerStack: UIStackView!
    @IBOutlet weak var cameraPreviewView: KKCameraPreviewView!
    @IBOutlet weak var cameraPreviewViewHeightConstraint: NSLayoutConstraint!
    
    weak var delegate: CameraVerifyIdentityPhotoViewDelegate?
    let captureButton = CaptureButton()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initSubViews()
        setupComponent()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initSubViews()
    }
    
    private func initSubViews() {
        let nib = UINib(nibName: String(describing: type(of: self)), bundle: Bundle(for: type(of: self)))
        nib.instantiate(withOwner: self, options: nil)
        containerView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(containerView)
        addConstraints()
    }
    
    private func addConstraints() {
        NSLayoutConstraint.activate([
            topAnchor.constraint(equalTo: containerView.topAnchor),
            bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
        ])
    }
    
    func setupComponent() {
        containerView.backgroundColor = .black
        backgroundColor = .black
        cameraPreviewView.backgroundColor = .clear
        cameraPreviewView.clipsToBounds = true
        cameraPreviewView.layer.cornerRadius = 16
        
        captureContainerView.addSubview(captureButton)
        captureButton.anchors.edges.pin()
        
        let onTapGuideLineIconGesture = UITapGestureRecognizer(target: self, action: #selector(handleOnTapGuideline))
        guidelineContainerStack.isUserInteractionEnabled = true
        guidelineContainerStack.addGestureRecognizer(onTapGuideLineIconGesture)
    }
    
    func updatePreviewHeight(by type: VerifyIdentityCameraType) {
        cameraPreviewViewHeightConstraint.constant = type == .identity ? 250 : 380
        titleLabel.text = type == .identity ? "Tempatkan bagian depan kartu identitas dalam frame" : "Pastikan wajah kamu terlihat dengan jelas dan tempatkan ID di depan."
        captureInfoLabel.isHidden = type == .selfie
    }
    
    @IBAction func didClickCloseButton(_ sender: Any) {
        delegate?.didClickClose()
    }
    
    @objc private func handleOnTapGuideline() {
        delegate?.didClickGuideline()
    }
}
