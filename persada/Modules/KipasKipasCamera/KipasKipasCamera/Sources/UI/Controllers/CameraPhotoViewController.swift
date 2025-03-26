import UIKit
import KipasKipasShared

open class CameraBaseViewController: UIViewController {
    
    public var isAuthorized: Bool = true

    open func switchCamera() {
        fatalError("Must be implemented")
    }
    
    open func toggleFlash() {
        fatalError("Must be implemented")
    }
    
    public func checkPermission() {
        guard isAuthorized == false else { return }
        
        let settings = UIAlertAction(
            title: "Pengaturan",
            style: .default,
            handler: { _ in UIViewController.openSettings() }
        )
        settings.titleTextColor = .night
        
        let cancel = UIAlertAction(title: "Batal", style: .destructive)
        
        showAlertController(
            title: "Akses kamera tidak diizinkan",
            titleFont: .roboto(.bold, size: 18),
            message: "\nUntuk menggunakan kamera, akses kamera harus diizinkan. \n\nKamu bisa mengubah izin akses kamera di pengaturan.\n",
            messageFont: .roboto(.regular, size: 14),
            backgroundColor: .white,
            actions: [settings, cancel]
        )
    }
}

public final class CameraPhotoViewController: CameraBaseViewController {
    
    private lazy var previewView = KKCameraPreviewView()
    
    private let closeButton = KKBaseButton()
    private let flashButton = KKBaseButton()
    private let captureButton = CaptureButton()
    
    public var didSelectMediaItem: ((KKMediaItem) -> Void)?
    public var onSessionRunning: ((Bool) -> Void)?
    
    private lazy var manager = {
        let manager = KKCameraManager(
            defaultMode: .dual,
            preview: previewView
        )
        manager.addDelegate(self)
        manager.captureMode = .photo
        manager.defaultCameraPosition = .front
        return manager
    }()
    
   
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        
        configureUI()
        observe()
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        startCameraSession()
    }
    
    public override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        stopCameraSession()
    }

    private func observe() {
        captureButton.didTapButton = { [weak self] in
            self?.checkPermission()
            self?.manager.toggleCapture()
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
}

// MARK: UI
private extension CameraPhotoViewController {
    func configureUI() {
        configureCameraContainerView()
        configureCloseButton()
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
        previewView.addSubview(captureButton)
        captureButton.anchors.width.equal(80)
        captureButton.anchors.height.equal(80)
        captureButton.anchors.bottom.pin(inset: 20)
        captureButton.anchors.centerX.align()
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

extension CameraPhotoViewController: CameraSessionDelegate {
    public func cameraSession(_ session: CameraSession, onRuntimeError errorCode: Int) {
        print("[BEKA] error", errorCode)
    }
    
    public func cameraSession(_ session: CameraSession, onSessionRunning isRunning: Bool) {
        onSessionRunning?(isRunning)
    }
    
    public func cameraSession(_ session: CameraSession, didUpdateConfiguration options: CameraOptions) {
        DispatchQueue.main.async {
            self.updateFlashButton(options: options)
        }
    }

    public func cameraSession(_ session: CameraSession, mode: CaptureMode, onFinishedCapturingWith temporaryFileURL: URL) {
        if let data = try? Data(contentsOf: temporaryFileURL) {
            let image: UIImage? = UIImage(data: data)
            let fixedOrientationImageData = image?.fixedOrientation()?.jpegData(compressionQuality: 0.9)
            let item = KKMediaItem(data: fixedOrientationImageData, path: temporaryFileURL.absoluteString, type: .photo, photoThumbnail: image)            
            self.dismiss(animated: true) { [weak self] in
                guard let self = self else { return }
                didSelectMediaItem?(item)
            }
            
        }
    }
}
