import UIKit
import KipasKipasShared
import KipasKipasCamera

public final class VerifyIdentityCameraController: CameraBaseViewController {
    
    private lazy var previewView = KKCameraPreviewView()
    
    private let captureButton = CaptureButton()
    private let closeButton = KKBaseButton()
    private let guidelineButton = KKBaseButton()
    private let titleLabel = UILabel()
    private let captureTitleLabel = UILabel()
    private let languageLabel = UILabel()
    private let cameraType: VerifyIdentityCameraType
    
    public var didSelectMediaItem: ((KKMediaItem) -> Void)?
    public var onSessionRunning: ((Bool) -> Void)?
    @objc public var handleDidClickGuideline: (() -> Void)?
    
    private lazy var cameraManager = {
        let manager = KKCameraManager(
            defaultMode: .photo,
            preview: previewView
        )
        manager.addDelegate(self)
        manager.defaultCameraPosition = cameraType == .identity ? .back : .front
        return manager
    }()
    
    public init(cameraType: VerifyIdentityCameraType) {
        self.cameraType = cameraType
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        return nil
    }
    
    // MARK: Lifecycle
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
        startCameraSession()
    }

    public override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        stopCameraSession()
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        observe()
    }
    
    public override func switchCamera() {
        checkPermission()
        cameraManager.switchCamera()
    }
    
    // MARK: Private
    private func observe() {
        captureButton.didTapButton = { [weak self] in
            self?.checkPermission()
            self?.cameraManager.toggleCapture()
        }
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
    
    @objc private func didTapClose() {
        dismiss(animated: true)
    }
    
    @objc private func didTapGuideline() {
        handleDidClickGuideline?()
    }
}

extension VerifyIdentityCameraController: CameraSessionDelegate {
    public func cameraSession(_ session: CameraSession, onRuntimeError errorCode: Int) {
        print("[BEKA] on runtime error", errorCode)
    }
    
    public func cameraSession(_ session: CameraSession, onSessionRunning isRunning: Bool) {
        DispatchQueue.main.async {
            self.onSessionRunning?(isRunning)
        }
    }
    
    public func cameraSession(_ session: CameraSession, didUpdateConfiguration options: CameraOptions) {
        
    }
    
    public func cameraSession(_ session: CameraSession, mode: CaptureMode, onFinishedCapturingWith temporaryFileURL: URL) {
        DispatchQueue.main.async {
            if let data = try? Data(contentsOf: temporaryFileURL),
               let image = UIImage(data: data),
               let fixedOrientationImageData = image.fixedOrientation()?.jpegData(compressionQuality: 0.9)
            {
                let item = KKMediaItem(data: fixedOrientationImageData, path: temporaryFileURL.absoluteString, type: .photo, photoThumbnail: image)
                self.dismiss(animated: true) { [weak self] in
                    guard let self = self else { return }
                    didSelectMediaItem?(item)
                }
            }
        }
    }
}

// MARK: UI
private extension VerifyIdentityCameraController {
    func configureUI () {
        view.backgroundColor = .black
        
        configureCloseButton()
        configureTitleLabel()
        configurePreviewView()
        configureCaptureTitleLabel()
        configureCaptureButton()
        configureGuidelineButton()
        configureLanguageLabel()
    }
    
    func configureTitleLabel() {
        if cameraType == .identity {
            titleLabel.text = "Tempatkan bagian depan kartu identitas dalam frame"
        } else {
            titleLabel.text = "Pastikan wajah kamu terlihat dengan jelas tidak terhalang kacamata hitam atau masker"
        }
        
        titleLabel.textColor = .white
        titleLabel.font = .systemFont(ofSize: 18, weight: .bold)
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0
        
        view.addSubview(titleLabel)
        titleLabel.anchors.top.equal(closeButton.anchors.bottom, constant: 32)
        titleLabel.anchors.leading.pin(inset: 12)
        titleLabel.anchors.trailing.pin(inset: 12)
    }
    
    func configurePreviewView() {
        previewView.backgroundColor = .clear
        previewView.clipsToBounds = true
        previewView.layer.cornerRadius = 16
        
        view.addSubview(previewView)
        previewView.anchors.top.equal(titleLabel.anchors.bottom, constant: 32)
        previewView.anchors.leading.pin()
        previewView.anchors.trailing.pin()
        previewView.anchors.height.equal(cameraType == .identity ? 250 : 380)
    }
    
    func configureCaptureTitleLabel() {
        captureTitleLabel.isHidden = cameraType == .selfie
        captureTitleLabel.text = "Bagian depan kartu"
        captureTitleLabel.textColor = .white
        captureTitleLabel.font = .systemFont(ofSize: 18, weight: .bold)
        captureTitleLabel.textAlignment = .center
        
        view.addSubview(captureTitleLabel)
        captureTitleLabel.anchors.top.equal(previewView.anchors.bottom, constant: 20)
        captureTitleLabel.anchors.centerX.align()
    }
    
    func configureCaptureButton() {
        captureButton.buttonColor = .white
        
        view.addSubview(captureButton)
        captureButton.anchors.top.equal(previewView.anchors.bottom, constant: cameraType == .identity ? 68 : 20)
        captureButton.anchors.width.equal(80)
        captureButton.anchors.height.equal(80)
        captureButton.anchors.centerX.align()
    }
    
    func configureCloseButton() {
        closeButton.setImage(.iconCloseWhite)
        closeButton.backgroundColor = UIColor.night.withAlphaComponent(0.2)
        closeButton.clipsToBounds = true
        closeButton.layer.cornerRadius = 40 / 2
        closeButton.addTarget(self, action: #selector(didTapClose), for: .touchUpInside)
        
        view.addSubview(closeButton)
        closeButton.anchors.width.equal(40)
        closeButton.anchors.height.equal(40)
        closeButton.anchors.top.pin(inset: safeAreaInsets.top)
        closeButton.anchors.leading.pin(inset: 12)
    }
    
    func configureGuidelineButton() {
        let questionmarkIcon = UIImage(systemName: "questionmark.circle")?.withTintColor(.white, renderingMode: .alwaysOriginal)
        guidelineButton.setImage(questionmarkIcon)
        guidelineButton.clipsToBounds = true
        guidelineButton.addTarget(self, action: #selector(didTapGuideline), for: .touchUpInside)
        
        view.addSubview(guidelineButton)
        guidelineButton.anchors.width.equal(40)
        guidelineButton.anchors.height.equal(40)
        guidelineButton.anchors.top.pin(inset: safeAreaInsets.top)
        guidelineButton.anchors.trailing.pin(inset: 16)
    }
    
    func configureLanguageLabel() {
        languageLabel.text = "ID"
        languageLabel.textColor = .white
        languageLabel.font = .systemFont(ofSize: 16, weight: .medium)
        languageLabel.textAlignment = .right
        
        view.addSubview(languageLabel)
        languageLabel.anchors.top.equal(guidelineButton.anchors.top, constant: 40 / 4)
        languageLabel.anchors.trailing.equal(guidelineButton.anchors.leading, constant: -4)
    }
}

