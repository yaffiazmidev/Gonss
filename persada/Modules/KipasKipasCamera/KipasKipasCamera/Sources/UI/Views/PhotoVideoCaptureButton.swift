import UIKit
import KipasKipasShared

public protocol PhotoVideoCaptureButtonDelegate: AnyObject {
    func startCapture()
    func startRecording()
    func stopRecording()
}

public final class PhotoVideoCaptureButton: CaptureButton {
    
    private let progressBarView = CircularProgressView()
    private var longpressGesture: UILongPressGestureRecognizer!
    
    public var progress: CGFloat = 0 {
        didSet {
            progressBarView.progress = progress
            
            if progress >= 1.0 {
                longpressGesture.state = .ended
                isRecording = false
            }
        }
    }
    
    public weak var delegate: PhotoVideoCaptureButtonDelegate?
    
    private var isRecording = false {
        didSet {
            if isRecording {
                animateStartRecording()
            } else {
                animateStopRecording()
            }
        }
    }
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        longpressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
        captureButton.addGestureRecognizer(longpressGesture)
        captureButton.addTarget(self, action: #selector(didTapCapture), for: .touchUpInside)
        
        configureProgressBarView()
    }
    
    private func configureProgressBarView() {
        progressBarView.color = .aquaBlue
        
        containerView.addSubview(progressBarView)
        progressBarView.anchors.edges.pin()
    }
    
    @objc private func didTapCapture() {
        delegate?.startCapture()
    }
    
    @objc private func handleLongPress(gesture: UILongPressGestureRecognizer) {
        if gesture.state == .began {
            isRecording = true
        } else if gesture.state == .ended {
            isRecording = false
        }
    }
    
    private func animateStartRecording() {
        delegate?.startRecording()
        
        UIView.animate(withDuration: 0.4) {
            self.borderColor = .clear
            
            self.containerView.backgroundColor = UIColor.white.withAlphaComponent(0.5)
            self.containerView.transform = .init(scaleX: 1.2, y: 1.2)
                        
            self.captureButton.backgroundColor = .aquaBlue
        }
    }
    
    private func animateStopRecording() {
        delegate?.stopRecording()
        
        UIView.animate(withDuration: 0.4) {
            self.borderColor = .white
            
            self.containerView.transform = .identity
            self.containerView.backgroundColor = .clear
            
            self.captureButton.transform = .identity
            self.captureButton.backgroundColor = .white
            self.progress = 0
            
            self.setNeedsLayout()
            self.layoutIfNeeded()
        }
    }
}
