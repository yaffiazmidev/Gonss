//
//  CameraVerifyIdentityPhotoController.swift
//  KipasKipasCamera
//
//  Created by DENAZMI on 03/06/24.
//

import UIKit
import KipasKipasShared

public final class CameraVerifyIdentityPhotoController: CameraBaseViewController, NavigationAppearance {
    
    private lazy var mainView: CameraVerifyIdentityPhotoView = {
        let view = CameraVerifyIdentityPhotoView()
        view.delegate = self
        return view
    }()
    
    public var didSelectMediaItem: ((KKMediaItem) -> Void)?
    public var onSessionRunning: ((Bool) -> Void)?
    public var handleDidClickGuideline: (() -> Void)?
    
    private let cameraType: VerifyIdentityCameraType
    
    private lazy var manager = {
        let manager = KKCameraManager(
            defaultMode: .photo,
            preview: mainView.cameraPreviewView
        )
        manager.addDelegate(self)
        manager.defaultCameraPosition = cameraType == .identity ? .back : .front
        return manager
    }()
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavigationBar(title: "", backIndicator: .iconChevronLeft)
        configureCameraManager()
        startCameraSession()
    }
    
    public init(cameraType: VerifyIdentityCameraType) {
        self.cameraType = cameraType
        super.init(nibName: nil, bundle: nil)
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        observe()
    }
    
    public override func loadView() {
        view = mainView
        mainView.updatePreviewHeight(by: cameraType)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func observe() {
        mainView.captureButton.didTapButton = { [weak self] in
            self?.checkPermission()
            self?.manager.toggleCapture()
        }
    }

    private func configureCameraManager() {
        manager.requestCameraAccess()
    }
    
    private func startCameraSession() {
        DispatchQueue.global().async {
            self.manager.startSession { [weak self] error in
                guard let self = self else { return }
                switch error {
                case .notAuthorized, .configurationFailed:
                    self.isAuthorized = false
                }
            }
        }
    }
}

extension CameraVerifyIdentityPhotoController: CameraVerifyIdentityPhotoViewDelegate {
    func didClickClose() {
        dismiss(animated: true)
    }
    
    func didClickGuideline() {
        handleDidClickGuideline?()
    }
}

extension CameraVerifyIdentityPhotoController: CameraSessionDelegate {
    public func cameraSession(_ session: CameraSession, onRuntimeError errorCode: Int) {
        print("[BEKA] error", errorCode)
    }
    
    public func cameraSession(_ session: CameraSession, onSessionRunning isRunning: Bool) {
        onSessionRunning?(isRunning)
    }
    
    public func cameraSession(_ session: CameraSession, didUpdateConfiguration options: CameraOptions) {
        
    }

    public func cameraSession(_ session: CameraSession, mode: CameraMode, onFinishedCapturingWith temporaryFileURL: URL) {
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

