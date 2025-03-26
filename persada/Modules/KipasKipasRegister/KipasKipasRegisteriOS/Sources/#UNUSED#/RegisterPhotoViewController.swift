import UIKit
import Combine
import KipasKipasCamera
import KipasKipasShared
import KipasKipasRegister

public final class RegisterPhotoViewController: StepsController {
    
    private let mainView = RegisterPhotoView()
    private let submitButton = KKLoadingButton()
    private let genderPickerView = GenderPickerView()
    
    private lazy var cameraViewController = {
        let cameraPhotoController = CameraPhotoViewController()
        cameraPhotoController.didSelectMediaItem = showPreviewController
        
        let controller = CameraViewController(cameraController: cameraPhotoController)
        controller.modalPresentationStyle = .fullScreen
        return controller
    }()
    
    @Published var photoURL: String = ""
    @Published var fullName: String = ""
    @Published var selectedGender: String = ""
    
    var uploadPhoto: ((RegisterUploadPhotoParam) -> Void)?
    var submitRegistration: ((RegisterUserParam) -> Void)?
    var onRegistrationSuccess: ((RegisterResponse) -> Void)?
    
    private var cancellables: Set<AnyCancellable> = []
    
    private let referralCode: String
    
    public init(referralCode: String) {
        self.referralCode = referralCode
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        return nil
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        observe()
    }
    
    private func observe() {
        mainView.didTapPickButton = { [weak self, cameraViewController] in
            self?.present(cameraViewController, animated: true)
        }
        
        mainView.didTypeFullname = { [weak self] fullName in
            self?.fullName = fullName
        }
        
        genderPickerView.didSelectGender = { [weak self] gender in
            self?.selectedGender = gender?.code ?? ""
        }
        
        cameraViewController.didSelectMediaItem = showPreviewController
        
        let valuesPublisher = Publishers.CombineLatest3($photoURL, $fullName, $selectedGender)
        
        valuesPublisher
            .sink { [weak self] (url, fullName, gender) in
                self?.storedData.photoURL = url
                self?.storedData.gender = gender
                self?.storedData.fullName = fullName
                self?.submitButton.isEnabled = url.isEmpty == false || fullName.isEmpty == false || gender.isEmpty == false
            }
            .store(in: &cancellables)
        
        submitButton
            .tapPublisher
            .sink { [weak self] in
                guard let self = self else { return }
                submitButton.showLoader([])
                submit()
            }
            .store(in: &cancellables)
    }
    
    private func showPreviewController(with item: KKMediaItem) {
        KKLogFile.instance.log(label:"RegisterPhotoViewController", message: "showPreviewController")

        let previewController = KKCameraPreviewViewController(item: item)
        previewController.modalPresentationStyle = .fullScreen
        previewController.handleDoneTapped = { [weak self] in
            self?.showCropController(with: item)
        }
        present(previewController, animated: true)
    }
    
    private func showCropController(with item: KKMediaItem) {
        let cropController = ProfilePictureCropController(item: item)
        cropController.modalPresentationStyle = .fullScreen
        cropController.delegate = self
        present(cropController, animated: true)
    }
    
    private func submit() {
        let fullname = storedData.fullName.isEmpty ? storedData.username : storedData.fullName
        submitRegistration?(.init(
            name: fullname,
            mobile: storedData.phoneNumber,
            password: storedData.password,
            photo: storedData.photoURL,
            username: storedData.username,
            otpCode: storedData.otpCode,
            birthDate: storedData.birthDate,
            gender: storedData.gender,
            deviceId: UIDevice.current.identifierForVendor?.uuidString ?? "",
            referralCode: referralCode, 
            email: nil
        ))
    }
}

// MARK: Image Crop
extension RegisterPhotoViewController: ProfilePictureCropDelegate {
    public func didCropped(media item: KKMediaItem) {
        if let data = item.data {
            uploadPhoto?(.init(imageData: data))
            mainView.setImage(from: data)
        }
    }
}

// MARK: ResourceView, ResourceLoadingView, ResourceErrorView
extension RegisterPhotoViewController: ResourceView {
    public func display(view viewModel: RegisterPhotoViewModel) {
        photoURL = viewModel.url
    }
}

extension RegisterPhotoViewController: ResourceLoadingView {
    public func display(loading loadingViewModel: ResourceLoadingViewModel) {
        mainView.setLoading(loadingViewModel.isLoading)
    }
}

extension RegisterPhotoViewController: ResourceErrorView {
    public func display(error errorViewModel: ResourceErrorViewModel) {
        guard let error = errorViewModel.error else { return }
        
        mainView.setImage(from: nil)
        showToast(with: error.message ?? "", verticalSpace: 50)
    }
}

// MARK: RegisterViewAdapterDelegate
extension RegisterPhotoViewController: RegisterViewAdapterDelegate {
    func didFinishRegister(with errorViewModel: ResourceErrorViewModel) {
        submitButton.hideLoader()
        
        if let error = errorViewModel.error {
            showToast(with: error.message ?? "Terjadi kesalahan. Coba lagi nanti", verticalSpace: 60)
        }
    }
    
    func didFinishRegister(with response: RegisterResponse) {
        submitButton.hideLoader()
        onRegistrationSuccess?(response)
    }
}

private extension RegisterPhotoViewController {
    func configureUI() {
        view.backgroundColor = .white
        
        configureUsernameView()
        configureSubmitButton()
        configureGenderPickerView()
    }
    
    func configureUsernameView() {
        mainView.backgroundColor = .clear
        scrollContainer.addArrangedSubViews(spacer(32))
        scrollContainer.addArrangedSubViews(mainView)
    }
    
    func configureSubmitButton() {
        submitButton.indicator = MaterialLoadingIndicatorSimple(radius: 10.0)
        submitButton.indicatorPosition = .right
        submitButton.setBackgroundColor(.watermelon, for: .normal)
        submitButton.setBackgroundColor(.sweetPink, for: .disabled)
        submitButton.isEnabled = false
        submitButton.indicator.color = .white
        submitButton.titleLabel?.font = .roboto(.bold, size: 14)
        submitButton.setTitle("Let's Go", for: .normal)
        submitButton.setTitleColor(.white, for: .normal)
        submitButton.layer.cornerRadius = 8
        submitButton.clipsToBounds = true
        
        wrapWithBottomSafeAreaPaddingView(submitButton, height: 24)
        submitButton.anchors.edges.pin(insets: 32, axis: .horizontal)
        submitButton.anchors.height.equal(40)
    }
    
    func configureGenderPickerView() {
        scrollContainer.addArrangedSubViews(genderPickerView)
    }
}

