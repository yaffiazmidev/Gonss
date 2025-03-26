import Foundation
import Dispatch
import AVFoundation

public typealias CameraSetupResult = Swift.Result<Void, CameraError>

public final class KKCameraManager: NSObject {
    
    /// Determine the default camera position. 
    /// **Default:  .back**
    public var defaultCameraPosition: CameraPosition {
        get { return options.defaultCameraPosition }
        set { options.defaultCameraPosition = newValue }
    }
    
    /// Determine the default camera flash mode
    /// **Default:  .off**
    public var flashMode: AVCaptureDevice.FlashMode {
        get { return options.flashMode }
        set { options.flashMode = newValue }
    }
    
    public var captureMode: CaptureMode {
        get { return options.captureMode }
        set {
            if options.cameraMode == .dual {
                options.captureMode = newValue
            } else {
                fatalError("Setting capture mode only for dual camera mode")
            }
        }
    }

    private let session = AVCaptureSession()
    private let sessionQueue = DispatchQueue(label: String(describing: KKCameraManager.self))
    private var sessionSetupResult: CameraSetupResult = .success(())

    private var preview: CameraPreview
    
    private(set) var options: CameraOptions {
        didSet {
            cameraSession.options = options
            cameraSession.delegates.invokeForEachDelegate { [weak self] delegate in
                guard let self, delegate !== self else { return }
                delegate.cameraSession(cameraSession, didUpdateConfiguration: options)
            }
        }
    }
    
    private lazy var cameraSession: CameraSession = {
        return CameraSession.create(
            session: session,
            with: options.cameraMode
        )
    }()
    
    public init(
        defaultMode: CameraMode,
        preview: CameraPreview,
        options: CameraOptions = CameraOptions()
    ) {
        self.preview = preview
        self.options = options
        self.options.cameraMode = defaultMode
        
        super.init()
        self.addDelegate(self)
    }

    // MARK: Privates
    private func configureSession() {
        session.beginConfiguration()
        guard case .success = sessionSetupResult else { return }
        cameraSession.createSession { [weak self] result in
            guard let self = self else { return }
            self.sessionSetupResult = result
        }
        preview.session = session
        session.commitConfiguration()
    }
}

extension KKCameraManager: CameraSessionDelegate {
    public func cameraSession(_ session: CameraSession, didUpdateConfiguration options: CameraOptions) {
        self.options = options
    }
}

// MARK: Public APIs
extension KKCameraManager {
    
    /// Check camera and microphone access
    public func requestCameraAccess() {
        // Setup preview
        
        // Check the video authorization status. Video access is required and
        // audio access is optional. If the user denies audio access, AVCam
        // won't record audio during movie recording.
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            // The user has previously granted access to the camera.
            break
            
        case .notDetermined:
            /*
             The user has not yet been presented with the option to grant
             video access. Suspend the session queue to delay session
             setup until the access request has completed.
             
             Note that audio access will be implicitly requested when we
             create an AVCaptureDeviceInput for audio during session setup.
             */
            sessionQueue.suspend()
            AVCaptureDevice.requestAccess(for: .video, completionHandler: { granted in
                if !granted {
                    self.sessionSetupResult = .failure(.notAuthorized)
                }
                self.sessionQueue.resume()
            })
            
        default:
            // The user has previously denied access.
            sessionSetupResult = .failure(.notAuthorized)
        }
    }
    
    private func startRunning(completion: @escaping (CameraError) -> Void) {
        guard session.isRunning == false else { return }
        
        switch self.sessionSetupResult {
        case .success:
            self.cameraSession.addObservers()
            self.session.startRunning()
            
        case let .failure(error):
            completion(error)
        }
    }
    
    public func startSession(errorCompletion: @escaping (CameraError) -> Void) {
        sessionQueue.async {
            self.configureSession()
            self.startRunning(completion: errorCompletion)
        }
    }
    
    public func stopSession() {
        sessionQueue.async {
            if case .success = self.sessionSetupResult {
                self.session.stopRunning()
                self.cameraSession.removeObservers()
                self.preview.session = nil
            }
        }
    }
    
    public func switchCamera() {
        sessionQueue.async {
            if case .success = self.sessionSetupResult {
                self.cameraSession.switchCamera()
            }
        }
    }
    
    public func toggleCapture() {
        sessionQueue.async {
            if case .success = self.sessionSetupResult {
                self.cameraSession.toggleCapture()
            }
        }
    }
    
    public func addDelegate(_ delegate: CameraSessionDelegate) {
        cameraSession.delegates.add(delegate: delegate)
    }
}
