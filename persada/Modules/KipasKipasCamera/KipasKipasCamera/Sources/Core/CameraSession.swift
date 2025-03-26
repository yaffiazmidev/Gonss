import AVFoundation

public protocol CameraSessionDelegate: AnyObject {
    func cameraSession(_ session: CameraSession, didUpdateConfiguration options: CameraOptions)
    func cameraSession(_ session: CameraSession, onSessionRunning isRunning: Bool)
    func cameraSession(_ session: CameraSession, onRuntimeError errorCode: Int)
    func cameraSession(_ session: CameraSession, onSessionInterrupted reasonCode: Int)
    func cameraSession(_ session: CameraSession, onStartCapturingWith cameraMode: CameraMode)
    func cameraSession(_ session: CameraSession, mode: CaptureMode, onFinishedCapturingWith temporaryFileURL: URL)
    func cameraSessionOnSessionInteruptionEnded()
}

public extension CameraSessionDelegate {
    func cameraSession(_ session: CameraSession, onSessionRunning isRunning: Bool) {}
    func cameraSession(_ session: CameraSession, onRuntimeError errorCode: Int) {}
    func cameraSession(_ session: CameraSession, onSessionInterrupted reasonCode: Int) {}
    func cameraSession(_ session: CameraSession, onStartCapturingWith cameraMode: CameraMode) {}
    func cameraSession(_ session: CameraSession, mode: CaptureMode, onFinishedCapturingWith temporaryFileURL: URL) {}
    func cameraSessionOnSessionInteruptionEnded() {}
}

public class CameraSession: NSObject {
    
    private var observers = [NSKeyValueObservation]()
    
    var currentVideoInput: AVCaptureDeviceInput!
    
    var options: CameraOptions
    
    private lazy var backCamera = AVCaptureDevice.DiscoverySession(
        deviceTypes: [
            .builtInDualCamera,
            .builtInWideAngleCamera
        ],
        mediaType: .video,
        position: .back
    )
    
    private lazy var frontCamera = AVCaptureDevice.DiscoverySession(
        deviceTypes: [
            .builtInTrueDepthCamera,
            .builtInWideAngleCamera
        ],
        mediaType: .video,
        position: .front
    )
    
    private lazy var usedCamera: AVCaptureDevice.DiscoverySession = {
        switch options.defaultCameraPosition {
        case .front:
            return frontCamera
        case .back:
            return backCamera
        }
    }()
    
    public let delegates = MulticastDelegate<CameraSessionDelegate>()
    
    let session: AVCaptureSession
    
    init(
        session: AVCaptureSession,
        options: CameraOptions = CameraOptions()
    ) {
        self.session = session
        self.options = options
    }
    
    func createSession(completion: @escaping (CameraSetupResult) -> Void) {
        
        for currentInput in session.inputs {
            session.removeInput(currentInput)
        }
        
        do {
            if let device = usedCamera.devices.first {
                
                let input = try AVCaptureDeviceInput(device: device)
                
                if session.canAddInput(input) {
                    session.addInput(input)
                    self.currentVideoInput = input
                    
                } else {
                    completion(.failure(.configurationFailed))
                    return
                }
                
            } else {
                completion(.failure(.configurationFailed))
                return
            }
            
        } catch {
            completion(.failure(.configurationFailed))
            return
        }
    }
    
    func switchCamera() {
        let currentVideoDevice = currentVideoInput.device
        let currentPosition = currentVideoDevice.position
        let newVideoDevice: AVCaptureDevice?
        
        switch currentPosition {
        case .unspecified, .front:
            newVideoDevice = backCamera.devices.first
            
        case .back:
            newVideoDevice = frontCamera.devices.first
            
        @unknown default:
            print("Unknown capture position. Defaulting to back, dual-camera.")
            newVideoDevice = AVCaptureDevice.default(.builtInDualCamera, for: .video, position: .back)
        }
        
        delegates.invokeForEachDelegate { [weak self] delegate in
            guard let self = self else { return }
            delegate.cameraSession(self, didUpdateConfiguration: options)
        }
        
        if let videoDevice = newVideoDevice,
           let videoDeviceInput = try? AVCaptureDeviceInput(device: videoDevice) {
            
            session.beginConfiguration()
            session.removeInput(currentVideoInput)
            
            if session.canAddInput(videoDeviceInput) {
                session.addInput(videoDeviceInput)
                self.currentVideoInput = videoDeviceInput
            } else {
                session.addInput(currentVideoInput)
            }
            session.commitConfiguration()
        }
    }
    
    func toggleCapture() {
        fatalError("Need to be implemented")
    }
    
    func removeObservers() {
        NotificationCenter.default.removeObserver(self)
        
        for observer in observers {
            observer.invalidate()
        }
        
        observers.removeAll()
    }
    
}

// MARK: Factory
extension CameraSession {
    static func create(
        session: AVCaptureSession,
        with mode: CameraMode
    ) -> CameraSession {
        switch mode {
        case .dual:
            return MultiCameraSession(session: session)
        case .video:
            return CameraVideoSession(session: session)
        case .photo:
            return CameraPhotoSession(session: session)
        }
    }
}

// MARK: Observers
extension CameraSession {
    /// - Tag: ObserveInterruption
    func addObservers() {
        let keyValueObservation = session.observe(\.isRunning, options: .new) { [weak self] _, change in
            guard let self = self, let isSessionRunning = change.newValue else { return }
         
            DispatchQueue.main.async {
                self.delegates.invokeForEachDelegate { [weak self] delegate in
                    guard let self = self else { return }
                    delegate.cameraSession(self, onSessionRunning: isSessionRunning)
                }
            }
        }
        
        observers.append(keyValueObservation)
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(sessionRuntimeError),
            name: .AVCaptureSessionRuntimeError,
            object: session
        )
        
        // A session can only run when the app is full screen. It will be
        // interrupted in a multi-app layout, introduced in iOS 9, see also the
        // documentation of AVCaptureSessionInterruptionReason. Add observers to
        // handle these session interruptions and show a preview is paused
        // message. See `AVCaptureSessionWasInterruptedNotification` for other
        // interruption reasons.
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(sessionWasInterrupted),
            name: .AVCaptureSessionWasInterrupted,
            object: session
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(sessionInterruptionEnded),
            name: .AVCaptureSessionInterruptionEnded,
            object: session
        )
    }

    @objc private func sessionRuntimeError(notification: NSNotification) {
        guard let error = notification.userInfo?[AVCaptureSessionErrorKey] as? AVError else { return }
        delegates.invokeForEachDelegate { [weak self] delegate in
            guard let self = self else { return }
            delegate.cameraSession(self, onRuntimeError: error.code.rawValue)
        }
    }
    
    @objc private func sessionWasInterrupted(notification: NSNotification) {
        // In some scenarios you want to enable the user to resume the session.
        // For example, if music playback is initiated from Control Center while
        // using AVCam, then the user can let AVCam resume the session running,
        // which will stop music playback. Note that stopping music playback in
        // Control Center will not automatically resume the session. Also note
        // that it's not always possible to resume, see
        // `resumeInterruptedSession(_:)`.
        if let userInfoValue = notification.userInfo?[AVCaptureSessionInterruptionReasonKey] as AnyObject?,
           let reasonIntegerValue = userInfoValue.integerValue {
            delegates.invokeForEachDelegate { [weak self] delegate in
                guard let self = self else { return }
                delegate.cameraSession(self, onSessionInterrupted: reasonIntegerValue)
            }
        }
    }
    
    @objc private func sessionInterruptionEnded(notification: NSNotification) {
        delegates.invokeForEachDelegate { delegate in
            delegate.cameraSessionOnSessionInteruptionEnded()
        }
    }
}
