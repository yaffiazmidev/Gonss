import UIKit
import KipasKipasShared
import KipasKipasCamera

final class CameraPostViewController: CameraBaseViewController {
    
    /// Max recording duration in seconds
    private let MAX_RECORDING_DURATION: Double = 120.0
    
    private lazy var previewView = KKCameraPreviewView()
    
    private let captureButton = PhotoVideoCaptureButton()
    private let closeButton = KKBaseButton()
    private let flashButton = KKBaseButton()
    private let timeLabel = UILabel()
    
    private var stopwatch: AnyStopwatch?
    
    var didCaptureMedia: Closure<KKMediaItem>?
    var onSessionRunning: Closure<Bool>?
    
    private lazy var cameraManager = {
        let manager = KKCameraManager(
            defaultMode: .dual,
            preview: previewView
        )
        manager.addDelegate(self)
        manager.defaultCameraPosition = .front
        return manager
    }()
   
    // MARK: Lifecycle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
        startCameraSession()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        stopCameraSession()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    override func switchCamera() {
        checkPermission()
        cameraManager.switchCamera()
    }
    
    // MARK: Private
    private func startStopwatch() {
        let interval = 0.1
        let maxRecordingDuration = MAX_RECORDING_DURATION
        let totalUpdates = maxRecordingDuration / interval
        let progressIncrement = 1.0 / totalUpdates
        
        timeLabel.isHidden = false
        stopwatch = StopwatchPublisher(interval: interval)
            .handleEvents(receiveOutput: { [weak self] elapsedTime in
                if elapsedTime.seconds >= Int(maxRecordingDuration) {
                    self?.stopRecording()
                    self?.captureButton.progress = 1.0
                }
            })
            .sink(receiveValue: { [weak self] elapsedTime in
                self?.captureButton.progress += progressIncrement
                self?.timeLabel.text = elapsedTime.formattedOutput
            })
    }
    
    private func endStopwatch() {
        stopwatch?.cancel()
        stopwatch = nil
        timeLabel.isHidden = true
        timeLabel.text = "00:00"
    }
    
    private func startCameraSession() {
        DispatchQueue.global(qos: .userInitiated).async {
            self.cameraManager.requestCameraAccess()
            self.cameraManager.startSession(errorCompletion: { [weak self] _ in
                self?.isAuthorized = false
            })
        }
    }
    
    private func stopCameraSession() {
        DispatchQueue.global(qos: .userInitiated).async {
            self.cameraManager.stopSession()
        }
    }
    
    private func updateFlashButton(options: CameraOptions) {
        var image: UIImage?
        var tintColor: UIColor?
        
        switch options.flashMode {
        case .off:
            image = UIImage.System.boltSlash
            tintColor = .white
        case .on:
            image = UIImage.System.boltFill
            tintColor = .yellow
        case .auto:
            image = UIImage.System.boltBadge
            tintColor = .yellow
        default:
            break
        }
        
        flashButton.setImage(image?.withTintColor(tintColor ?? .white))
    }
    
    @objc public override func toggleFlash() {
        checkPermission()
        
        switch cameraManager.flashMode {
        case .off:
            cameraManager.flashMode = .auto
        case .auto:
            cameraManager.flashMode = .on
        default:
            cameraManager.flashMode = .off
        }
    }
    
    @objc private func didTapClose() {
        dismiss(animated: true)
    }
    
    private func handleRecordedVideo(from url: URL) {
        let item = KKMediaItem(
            data: try? Data(contentsOf: url),
            path: url.absoluteString,
            type: .video,
            videoThumbnail: UIImage.videoThumbnail(url.absoluteString)
        )
        didCaptureMedia?(item)
    }
    
    private func handleCapturedImage(from url: URL) {
        if let data = try? Data(contentsOf: url),
           let image = UIImage(data: data),
           let fixedOrientationImageData = image.fixedOrientation()?.jpegData(compressionQuality: 0.9)
        {
            let item = KKMediaItem(
                data: fixedOrientationImageData,
                path: url.absoluteString,
                type: .photo,
                photoThumbnail: image
            )
            didCaptureMedia?(item)
        }
    }
}

extension CameraPostViewController: PhotoVideoCaptureButtonDelegate {
    public func startRecording() {
        cameraManager.captureMode = .video
        cameraManager.toggleCapture()
        startStopwatch()
    }
    
    public func stopRecording() {
        cameraManager.toggleCapture()
        endStopwatch()
    }
    
    public func startCapture() {
        cameraManager.captureMode = .photo
        cameraManager.toggleCapture()
    }
}

extension CameraPostViewController: CameraSessionDelegate {
    func cameraSession(_ session: CameraSession, onRuntimeError errorCode: Int) {
        print("[BEKA] on runtime error", errorCode)
    }
    
    func cameraSession(_ session: CameraSession, onSessionRunning isRunning: Bool) {
        onSessionRunning?(isRunning)
    }
    
    func cameraSession(_ session: CameraSession, didUpdateConfiguration options: CameraOptions) {
        DispatchQueue.main.async {
            self.updateFlashButton(options: options)
        }
    }
    
    func cameraSession(_ session: CameraSession, mode: CaptureMode, onFinishedCapturingWith temporaryFileURL: URL) {
        DispatchQueue.main.async {
            self.dismiss(animated: true) { [weak self] in
                switch mode {
                case .video:
                    self?.handleRecordedVideo(from: temporaryFileURL)
                case .photo:
                    self?.handleCapturedImage(from: temporaryFileURL)
                }
            }
        }
    }
}

// MARK: UI
private extension CameraPostViewController {
    func configureUI () {
        view.backgroundColor = .clear
        
        configurePreviewView()
        configureCaptureButton()
        configureTimeLabel()
        configureCloseButton()
        configureFlashButton()
    }
    
    func configurePreviewView() {
        previewView.backgroundColor = .clear
        previewView.clipsToBounds = true
        previewView.layer.cornerRadius = 16
        
        view.addSubview(previewView)
        previewView.anchors.edges.pin()
    }
    
    func configureCaptureButton() {
        captureButton.delegate = self
        captureButton.buttonColor = .white
        
        previewView.addSubview(captureButton)
        captureButton.anchors.width.equal(80)
        captureButton.anchors.height.equal(80)
        captureButton.anchors.bottom.pin(inset: 20)
        captureButton.anchors.centerX.align()
    }
    
    func configureTimeLabel() {
        timeLabel.isHidden = true
        timeLabel.font = .roboto(.medium, size: 14)
        timeLabel.textColor = .whiteSnow
        
        previewView.addSubview(timeLabel)
        timeLabel.anchors.centerX.align()
        timeLabel.anchors.bottom.spacing(30, to: captureButton.anchors.top)
    }
    
    func configureFlashButton() {
        flashButton.backgroundColor = UIColor.night.withAlphaComponent(0.2)
        flashButton.clipsToBounds = true
        flashButton.layer.cornerRadius = 40 / 2
        flashButton.addTarget(self, action: #selector(toggleFlash), for: .touchUpInside)
        flashButton.setImage(UIImage.System.boltSlash?.withTintColor(.white))
        
        previewView.addSubview(flashButton)
        flashButton.anchors.width.equal(40)
        flashButton.anchors.height.equal(40)
        flashButton.anchors.top.pin(inset: safeAreaInsets.top)
        flashButton.anchors.trailing.pin(inset: 12)
    }
    
    func configureCloseButton() {
        closeButton.setImage(.iconCloseWhite)
        closeButton.backgroundColor = UIColor.night.withAlphaComponent(0.2)
        closeButton.clipsToBounds = true
        closeButton.layer.cornerRadius = 40 / 2
        closeButton.addTarget(self, action: #selector(didTapClose), for: .touchUpInside)
        
        previewView.addSubview(closeButton)
        closeButton.anchors.width.equal(40)
        closeButton.anchors.height.equal(40)
        closeButton.anchors.top.pin(inset: safeAreaInsets.top)
        closeButton.anchors.leading.pin(inset: 12)
    }
}
