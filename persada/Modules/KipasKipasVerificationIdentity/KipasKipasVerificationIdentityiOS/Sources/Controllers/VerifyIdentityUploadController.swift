import UIKit
import KipasKipasShared
import KipasKipasCamera
import KipasKipasNetworking
import KipasKipasVerificationIdentity
import PrivyLiveness

public class VerifyIdentityUploadController: UIViewController, NavigationAppearance {
    
    private lazy var mainView: VerifyIdentityUploadView = {
        let view = VerifyIdentityUploadView()
        view.delegate = self
        return view
    }()
    
    private var viewModel: IVerifyIdentityUploadViewModel
    private var handleBackToBalanceView: (() -> Void)?
    
    public init(
        viewModel: IVerifyIdentityUploadViewModel,
        handleBackToBalanceView: (() -> Void)?
    ) {
        self.viewModel = viewModel
        self.handleBackToBalanceView = handleBackToBalanceView
        super.init(nibName: nil, bundle: nil)
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        overrideUserInterfaceStyle = .light
    }
    
    public override func loadView() {
        view = mainView
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavigationBar(backIndicator: .iconChevronLeft)
    }
    
    @objc func presentLiveness() {
        let livenessVC = PrivyLivenessModule.create(with: .prod, showResultPage: true, callback: .delegate(self))
        let navigation = UINavigationController(rootViewController: livenessVC)
        navigation.modalPresentationStyle = .fullScreen
        present(navigation, animated: true)
    }
}

extension VerifyIdentityUploadController: LivenessDelegete {
    public func livenessResult(result: LivenessResult) {
        if case let .success(liveness) = result {
            print("⭐️ SUCCESS DETECT LIVENESS ⭐️")
            
            let prefixBase64 = liveness.face1Base64?.replacingOccurrences(of: "data:image/jpeg;base64,", with: "")
            if let image = UIImage(base64String: prefixBase64 ?? "") {
                mainView.selfieImage = image
            } else {
                print("[DENAZMI] - image not found..")
            }
            
            DispatchQueue.main.async { KKDefaultLoading.shared.show(message: "Uploading..") }
            mainView.setLoading(true)
            let data = convertBase64ToData(with: liveness.face1Base64 ?? "")
            let ext = extractImageFormat(from: liveness.face1Base64 ?? "")
            viewModel.uploadPicture(with: data, ext: ext, type: .selfie)
        }
        
        if case let .failure(failure) = result {
            
            if case let .failedDetect(liveness) = failure {
                print("‼️ FAILED DETECT LIVENESS ‼️")
            }
            
            if case .networkError = failure {
                print("‼️ FAILED DUE TO NETWORK ERROR ‼️")
            }
            
            if case .outOfBalance = failure {
                print("‼️ FAILED DUE TO OUT OF BALANCE ‼️")
            }
        }
    }
}

extension VerifyIdentityUploadController: VerifyIdentityUploadViewModelDelegate {
    
    public func displayUploadIdentity() {
        mainView.setLoading(false)
        let title = UploadStatus.success.title
        let description = UploadStatus.success.description
        presentAlert(config: .init(title: title, description: description, iconImage: .iconCircleCheckGreen), completion: navigateToUploadStatus)
    }
    
    public func displayUploadPicture() {
        DispatchQueue.main.async { KKDefaultLoading.shared.hide() }
        mainView.setLoading(false)
        mainView.nextButton.isEnabled = !viewModel.uploadIdentityParam.identityUrl.isEmpty && !viewModel.uploadIdentityParam.selfieUrl.isEmpty
    }
    public func displayErrorUploadPicture(with error: KKNetworkError, type: VerifyIdentityCameraType) {
        DispatchQueue.main.async { KKDefaultLoading.shared.hide() }
        self.mainView.setLoading(false)
        
        if case .connectivity = error {
            let noInternetConnection = UploadStatus.noInternetConnection
            presentAlert(
                config: .init(
                    title: noInternetConnection.title,
                    description: noInternetConnection.description,
                    iconImage: .iconCircleCloseFillRed
                )
            )
        } else {
            let title = "Gagal upload"
            let description = "Terjadi kesalahan saat upload foto \(type == .identity ? "identitas" : "Selfie"), silahkan coba lagi.."
            presentAlert(config: .init(title: title, description: description, iconImage: .iconCircleCloseFillRed))
        }
    }
    
    public func displayErrorUploadIdentity(with error: KKNetworkError) {
        mainView.setLoading(false)
        var status: UploadStatus = .failed
        
        if case .connectivity = error {
            status = .noInternetConnection
        }
        
        presentAlert(config: .init(title: status.title, description: status.description, iconImage: .iconCircleCloseFillRed))
    }
}

extension VerifyIdentityUploadController: VerifyIdentityUploadViewDelegate {
    func didClickCaptureIdentityButton() {
        presentCameraController(by: .identity)
    }
    
    func didClickCaptureSelfieButton() {
        presentLiveness()
    }
    
    func didClickGuideLine() {
        presentGuidelineController()
    }
    
    func didClickNext() {
        mainView.setLoading(true)
        viewModel.uploadIdentity()
    }
}

// MARK: Private zone
private extension VerifyIdentityUploadController {
    
    private func presentGuidelineController() {
        let view = VerifyIdentityGuidelineView()
        let configureItem = KKBottomSheetConfigureItem(viewHeight: self.view.frame.height - 200, canSlideUp: false)
        let vc = KKBottomSheetController(view: view, title: "Cara mengambil foto ID", configure: configureItem)
        vc.handleDraggingDirection = { _ in view.pageControl.isHidden = true }
        vc.handleDidEndDraggingDirection = { _ in view.pageControl.isHidden = false }
        vc.modalPresentationStyle = .overFullScreen
        present(vc, animated: false)
    }
    
    private func navigateToUploadStatus() {
        let statusLoader: VerifyIdentityStatusLoader = VerifyIdentityLoaderFactory.shared.get(.verificationStatus)
        let viewModel = VerifyIdentityUploadStatusViewModel(statusLoader: statusLoader)
        let vc = VerifyIdentityUploadStatusController(
            isFromUploadView: true,
            viewModel: viewModel,
            handleBackToBalanceView: handleBackToBalanceView
        )
        viewModel.delegate = vc
        push(vc)
    }
    
    private func presentCameraController(by type: VerifyIdentityCameraType) {
        let vc = VerifyIdentityCameraController(cameraType: type)
        vc.didSelectMediaItem = { [weak self] item in
            guard let self = self else { return }
            if type == .identity {
                self.mainView.identityImage = item.photoThumbnail
            } else {
                self.mainView.selfieImage = item.photoThumbnail
            }
            
            DispatchQueue.main.async { KKDefaultLoading.shared.show(message: "Uploading..") }
            self.mainView.setLoading(true)
            self.viewModel.uploadPicture(with: item, type: type)
        }
        
        let guidelineController = makeGuideLineController(
            configure: .init(viewHeight: self.view.frame.height - 200, canSlideUp: false, canSlideDown: false)
        )
        
        vc.handleDidClickGuideline = {
            vc.add(guidelineController)
        }
        vc.modalPresentationStyle = .overFullScreen
        present(vc, animated: true)
        
//        let cameraController = makeVerifyIdentityCameraController(with: type)
//        cameraController.modalPresentationStyle = .overFullScreen
//        present(cameraController, animated: true)
    }
    private func makeGuideLineController(configure: KKBottomSheetConfigureItem) -> VerifyIdentityGuidelineController {
        let view = VerifyIdentityGuidelineView()
        let configureItem = KKBottomSheetConfigureItem(viewHeight: self.view.frame.height - 200, canSlideUp: false, canSlideDown: false)
        let vc = VerifyIdentityGuidelineController(view: view, title: "Cara mengambil foto ID", configure: configureItem)
        vc.handleDraggingDirection = { _ in view.pageControl.isHidden = true }
        vc.handleDidEndDraggingDirection = { _ in view.pageControl.isHidden = false }
        return vc
    }
    
    private func makeVerifyIdentityCameraController(with type: VerifyIdentityCameraType) -> CameraVerifyIdentityPhotoController {
        let cameraViewController = CameraVerifyIdentityPhotoController(cameraType: type)
        cameraViewController.didSelectMediaItem = { [weak self] item in
            guard let self = self else { return }
            if type == .identity {
                self.mainView.identityImage = item.photoThumbnail
            } else {
                self.mainView.selfieImage = item.photoThumbnail
            }
            
            DispatchQueue.main.async { KKDefaultLoading.shared.show(message: "Uploading..") }
            self.mainView.setLoading(true)
            self.viewModel.uploadPicture(with: item, type: type)
        }
        
        let guidelineController = makeGuideLineController(
            configure: .init(viewHeight: self.view.frame.height - 200, canSlideUp: false, canSlideDown: false)
        )
        
        cameraViewController.handleDidClickGuideline = {
            cameraViewController.add(guidelineController)
        }
        
        return cameraViewController
    }
}

fileprivate enum UploadStatus: Equatable {
    case success
    case failed
    case noInternetConnection
    
    var title: String {
        switch self {
        case .success:
            return "Berhasil upload"
        case .failed:
            return "Gagal upload"
        case .noInternetConnection:
            return "Tidak ada koneksi internet."
        }
    }
    
    var description: String {
        switch self {
        case .success:
            return "Berhasil mengupload identitas, data yang kamu kirim akan di verifikasi."
        case .failed:
            return "Sepertinya terjadi kesalahan pada proses upload, silahkan coba lagi."
        case .noInternetConnection:
            return "Sambungkan ke internet, lalu coba lagi."
        }
    }
}

private extension VerifyIdentityUploadController {
    func convertBase64ToData(with base64: String) -> Data? {
        guard let data = Data(base64Encoded: base64, options: .ignoreUnknownCharacters) else {
            return nil
        }
        
        return data
    }

    func extractImageFormat(from base64String: String) -> String? {
        // Ensure the string starts with the correct prefix
        guard base64String.hasPrefix("data:image/") else {
            return nil
        }
        
        // Extract the format substring between "data:image/" and ";"
        let components = base64String.components(separatedBy: ";")
        guard components.count > 1, let formatComponent = components.first?.split(separator: "/").last else {
            return nil
        }
        
        return String(formatComponent)
    }
}
