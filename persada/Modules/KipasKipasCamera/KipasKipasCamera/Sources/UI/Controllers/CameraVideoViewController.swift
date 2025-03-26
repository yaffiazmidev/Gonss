import UIKit
import Combine
import KipasKipasShared
import AVFoundation

extension  Notification.Name {
    static let pushNotifForLiveStart = Notification.Name("pushNotifForLiveStart")
}

public final class CameraVideoViewController: CameraBaseViewController {
    
    private lazy var previewView = KKCameraPreviewView()
    
    private let closeButton = KKBaseButton()
    private let flashButton = KKBaseButton()
    private let captureButton = VideoCaptureButton()
    private let timerLabel = UILabel()
    private var isRecording: Bool = false
    
    public var didSelectMediaItem: ((KKMediaItem) -> Void)?
    
    private var stopwatch: AnyCancellable?
    
    private lazy var manager = {
        let manager = KKCameraManager(
            defaultMode: .dual,
            preview: previewView
        )
        manager.addDelegate(self)
        manager.captureMode = .video
        manager.defaultCameraPosition = .front
        return manager
    }()
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        startCameraSession()
    }
    
    public override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        stopCameraSession()
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        
        KKLogFile.instance.log(label:"CameraVideoViewController", message: "open")

        configureUI()
        observe()
        addObserver()
    }
    
    
    @objc func liveStart(){
        self.manager.stopSession()
        stopStopwatch()
    }
    
    func addObserver(){
        NotificationCenter.default.addObserver(
                    self, selector: #selector(liveStart),
                    name:.pushNotifForLiveStart, object: nil
                )
    }
    
    private func observe() {
        captureButton.didTapButton = { [weak self] in
            guard let self = self else { return }
            checkPermission()
            
            if !isRecording {
                checkAudioPermission() { [weak self] in
                    self?.manager.toggleCapture()
                }
            } else {
                manager.toggleCapture()
            }
        }
    }
    
    private func startCameraSession() {
        DispatchQueue.global(qos: .userInitiated).async {
            self.manager.requestCameraAccess()
            self.manager.startSession(errorCompletion: { [weak self] _ in
                self?.isAuthorized = false
            })
        }
    }
    
    private func stopCameraSession() {
        DispatchQueue.global(qos: .userInitiated).async {
            self.manager.stopSession()
        }
    }
    
    @objc public override func toggleFlash() {
        checkPermission()
        
        switch manager.flashMode {
        case .off:
            manager.flashMode = .auto
        case .auto:
            manager.flashMode = .on
        default:
            manager.flashMode = .off
        }
    }
    
    @objc private func didTapClose() {
        dismiss(animated: true)
    }
    
    public override func switchCamera() {
        checkPermission()
        manager.switchCamera()
    }
    
    // MARK: Stopwatch
    private func startStopwatch() {
        timerLabel.isHidden = false
        stopwatch = StopwatchPublisher()
            .sink(receiveValue: { [weak self] elapsedTime in
                self?.timerLabel.text = elapsedTime.formattedOutput
            })
    }
    
    private func stopStopwatch() {
        stopwatch?.cancel()
        stopwatch = nil
        timerLabel.isHidden = true
    }
    
    private func checkAudioPermission(ignoreCompletion: @escaping () -> Void) {
        if AVAudioSession.sharedInstance().recordPermission != .granted {
            let settings = UIAlertAction(
                title: "Pengaturan",
                style: .default,
                handler: { _ in UIViewController.openSettings() }
            )
            settings.titleTextColor = .night
            
            let cancel = UIAlertAction(
                title: "Oke",
                style: .default, 
                handler: { _ in
                    ignoreCompletion()
                }
            )
            
            showAlertController(
                title: "Akses mikrofon tidak diizinkan",
                titleFont: .roboto(.bold, size: 17),
                message: "\nAkses mikrofon tidak diizinkan menyebabkan video yang dihasilkan akan tanpa suara. \n\nKamu bisa mengubah izin akses mikrofon di pengaturan.\n",
                messageFont: .roboto(.regular, size: 14),
                backgroundColor: .white,
                actions: [settings, cancel]
            )
        } else {
            ignoreCompletion()
        }
    }
}

// MARK: UI
private extension CameraVideoViewController {
    func configureUI() {
        configureCameraContainerView()
        configureCloseButton()
        configureTimerLabel()
        configureFlashButton()
        configureCaptureButton()
    }
    
    func configureCameraContainerView() {
        previewView.backgroundColor = .clear
        previewView.clipsToBounds = true
        previewView.layer.cornerRadius = 16
        
        view.addSubview(previewView)
        previewView.anchors.edges.pin()
    }
    
    func configureCaptureButton() {
        captureButton.buttonColor = .brightRed
        
        previewView.addSubview(captureButton)
        captureButton.anchors.width.equal(80)
        captureButton.anchors.height.equal(80)
        captureButton.anchors.bottom.pin(inset: 20)
        captureButton.anchors.centerX.align()
    }
    
    func configureTimerLabel() {
        timerLabel.isHidden = true
        timerLabel.font = .roboto(.regular, size: 16)
        timerLabel.textColor = .whiteSnow
        
        previewView.addSubview(timerLabel)
        timerLabel.anchors.centerX.align()
        timerLabel.anchors.centerY.equal(closeButton.anchors.centerY)
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
    
    func updateFlashButton(options: CameraOptions) {
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
}

extension CameraVideoViewController: CameraSessionDelegate {
    public func cameraSession(_ session: CameraSession, onRuntimeError errorCode: Int) {
        print("[BEKA] error", errorCode)
    }
    
    public func cameraSession(_ session: CameraSession, onStartCapturingWith cameraMode: CameraMode) {
        isRecording = true
        captureButton.isRecording = true
        startStopwatch()
    }
    
    
    public func cameraSession(_ session: CameraSession, didUpdateConfiguration options: CameraOptions) {
        DispatchQueue.main.async {
            self.updateFlashButton(options: options)
        }
    }

    public func cameraSession(_ session: CameraSession, mode: CaptureMode, onFinishedCapturingWith temporaryFileURL: URL) {
        isRecording = false
        captureButton.isRecording = false
        stopStopwatch()
        
        let item = KKMediaItem(
            data: try? Data(contentsOf: temporaryFileURL),
            path: temporaryFileURL.absoluteString,
            type: .video,
            videoThumbnail: UIImage.videoThumbnail(temporaryFileURL.absoluteString)
        )
        didSelectMediaItem?(item)
    }
}
