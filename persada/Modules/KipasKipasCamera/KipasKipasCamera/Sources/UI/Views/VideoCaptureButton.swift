import UIKit

final class VideoCaptureButton: CaptureButton {
    
    var isRecording = false {
        didSet {
            if isRecording {
                animateStartRecording()
            } else {
                animateStopRecording()
            }
        }
    }
    
    private func animateStartRecording() {
        UIView.animate(withDuration: 0.4) {
            self.captureButton.transform = .init(scaleX: 0.75, y: 0.75)
            self.captureButton.layer.cornerRadius = 10
        }
    }
    
    private func animateStopRecording() {
        UIView.animate(withDuration: 0.4) {
            self.captureButton.transform = .identity
            self.setNeedsLayout()
            self.layoutIfNeeded()
        }
    }
}
