import Foundation
import AVFoundation
import Photos

final class CameraPhotoSession: CameraSession {
    
    private let output = AVCapturePhotoOutput()

    private lazy var temporaryFilePath: URL = URL.temporaryImagePath
    
    private var photoData: Data?
    
    override init(session: AVCaptureSession, options: CameraOptions = CameraOptions()) {
        super.init(session: session, options: options)
        self.options.captureMode = .photo
    }
    
    override func createSession(completion: @escaping (CameraSetupResult) -> Void) {
        super.createSession(completion: completion)
        addOutput()
    }
    
    override func toggleCapture() {
        guard let currentInput = currentVideoInput else { return }
        
        var photoSettings = AVCapturePhotoSettings()

        if  output.availablePhotoCodecTypes.contains(.jpeg) {
            photoSettings = AVCapturePhotoSettings(
                format: [
                    AVVideoCodecKey: AVVideoCodecType.jpeg
                ])
        }
        
        if currentInput.device.isFlashAvailable {
            photoSettings.flashMode = options.flashMode
        }
        
        //photoSettings.isHighResolutionPhotoEnabled = true
        photoSettings.isHighResolutionPhotoEnabled = false
        
        if !photoSettings.__availablePreviewPhotoPixelFormatTypes.isEmpty {
            photoSettings.previewPhotoFormat = [kCVPixelBufferPixelFormatTypeKey as String: photoSettings.__availablePreviewPhotoPixelFormatTypes.first!]
        }
        
        photoSettings.photoQualityPrioritization = output.maxPhotoQualityPrioritization
        
        
        output.capturePhoto(with: photoSettings, delegate: self)
    }
 
    private func addOutput() {
        if session.canAddOutput(output) {
            output.maxPhotoQualityPrioritization = .quality
            #warning("[BEKA] Change this property with maxPhotoDimension")
            output.isHighResolutionCaptureEnabled = true
            
            session.sessionPreset = .photo
            session.addOutput(output)
        }
    }
}

// MARK: AVCaptureFileOutputRecordingDelegate
extension CameraPhotoSession: AVCapturePhotoCaptureDelegate {
    func photoOutput(
        _ output: AVCapturePhotoOutput,
        willCapturePhotoFor resolvedSettings: AVCaptureResolvedPhotoSettings
    ) {
        delegates.invokeForEachDelegate { [weak self] delegate in
            guard let self = self else { return }
            delegate.cameraSession(self, onStartCapturingWith: .photo)
        }
    }
    
    func photoOutput(
        _ output: AVCapturePhotoOutput,
        didFinishProcessingPhoto photo: AVCapturePhoto,
        error: Error?
    ) {
        guard error == nil else { return }
        
        photoData = photo.fileDataRepresentation()
    }
    
    func photoOutput(
        _ output: AVCapturePhotoOutput,
        didFinishCaptureFor resolvedSettings: AVCaptureResolvedPhotoSettings,
        error: Error?
    ) {
        guard error == nil else { return }
        
        let path = temporaryFilePath.path
        
        if FileManager.default.fileExists(atPath: path) {
            do {
                try FileManager.default.removeItem(atPath: path)
            } catch {
                print("Could not remove file at url: \(path)")
            }
        }
        
        if let photoData = photoData {
            do {
                let url = try photoData.writeToTemporaryImagePath()
                delegates.invokeForEachDelegate { [weak self] delegate in
                    guard let self = self else { return }
                    delegate.cameraSession(self, mode: .photo, onFinishedCapturingWith: url)
                }
            } catch {
                print("[BEKA] error", #function, error)
            }
        }
    }
}
