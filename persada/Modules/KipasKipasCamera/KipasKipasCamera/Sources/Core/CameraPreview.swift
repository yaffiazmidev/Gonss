import AVFoundation

public protocol CameraPreview {
    var session: AVCaptureSession? { get set }
    var previewLayer: AVCaptureVideoPreviewLayer { get }
}
