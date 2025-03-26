import UIKit
import AVFoundation

public class KKCameraPreviewView: UIView, CameraPreview {
    
    private let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .systemThinMaterialDark))
    
    public var previewLayer: AVCaptureVideoPreviewLayer {
        guard let layer = layer as? AVCaptureVideoPreviewLayer else {
            fatalError("Expected `AVCaptureVideoPreviewLayer` type for layer. Check KKCameraLivePreviewView.layerClass implementation.")
        }
        return layer
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        addBlur()
    }
    
    public required init?(coder: NSCoder) {
        return nil
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        blurView.frame = bounds
    }
    
    public var session: AVCaptureSession? {
        get {
            return previewLayer.session
        }
        set {
            DispatchQueue.main.async {
                if newValue == nil {
                    self.blurView.alpha = 1
                }
                
                self.previewLayer.session = newValue
                self.previewLayer.videoGravity = .resizeAspectFill
            }
            
            animateBlur()
        }
    }
    
    public override class var layerClass: AnyClass {
        return AVCaptureVideoPreviewLayer.self
    }
    
    private func addBlur() {
        blurView.alpha = 0
        addSubview(blurView)
    }
    
    private func animateBlur() {
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.3, animations: {
                self.blurView.alpha = 1.0
            }) { _ in
                UIView.animate(withDuration: 0.5, delay: 1, options: [], animations: {
                    self.blurView.alpha = 0
                }, completion: nil)
            }
        }
    }
}
