import Foundation
import AVFoundation

public struct CameraOptions {
    
    public var cameraMode: CameraMode
    public var defaultCameraPosition: CameraPosition
    public var flashMode: AVCaptureDevice.FlashMode
    public var captureMode: CaptureMode
    
    public init() {
        self.cameraMode = .video
        self.captureMode = .photo
        self.defaultCameraPosition = .back
        self.flashMode = .off
    }
}
