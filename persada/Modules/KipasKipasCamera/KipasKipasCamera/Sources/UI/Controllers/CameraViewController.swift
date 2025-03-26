import UIKit
import KipasKipasShared

public final class CameraViewController: UIViewController, UINavigationControllerDelegate {
    
    private let cameraContainerView = UIView()
    
    private let bottomPanelView = UIView()
    private let bottomPanelStack = UIStackView()
    private let photoPreviewButton = KKBaseButton()
    private let rotateCameraButton = KKBaseButton()
    
    private let imagePickerController = KKMediaPicker()
    
    public var didSelectMediaItem: ((KKMediaItem) -> Void)?
    
    private let cameraController: CameraBaseViewController
    
    public init(cameraController: CameraBaseViewController) {
        self.cameraController = cameraController
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        return nil
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        
        configureUI()
        fetchPhotos()
        imagePickerController.delegate = self
        imagePickerController.types = [.photo, .video]
    }
    
    private func fetchPhotos() {
        Task {
            let images = try? await MediaLibraryFetcher.fetchPhotos(targetSize: .init(width: 200, height: 200))
            photoPreviewButton.setImage(images?.first)
        }
    }
 
    @objc private func switchCamera() {
        cameraController.switchCamera()
    }
    
    @objc private func toggleFlash() {
        cameraController.toggleFlash()
    }

        
    @objc private func didTapClose() {
        dismiss(animated: true)
    }
    
    @objc private func pickImage() {
        imagePickerController.show(in: self)
    }
}

// MARK: UI
private extension CameraViewController {
    func configureUI() {
        configureBottomPanelView()
        configureCameraContainerView()
    }
    
    func configureBottomPanelView() {
        bottomPanelView.backgroundColor = .night
        
        view.addSubview(bottomPanelView)
        bottomPanelView.anchors.height.equal(94)
        bottomPanelView.anchors.bottom.equal(view.safeAreaLayoutGuide.anchors.bottom)
        bottomPanelView.anchors.edges.pin(axis: .horizontal)
        
        configureBottomPanelStack()
    }
    
    func configureBottomPanelStack() {
        bottomPanelStack.distribution = .equalSpacing
        bottomPanelStack.alignment = .center
        
        bottomPanelView.addSubview(bottomPanelStack)
        bottomPanelStack.anchors.edges.pin(axis: .vertical)
        bottomPanelStack.anchors.edges.pin(insets: 32, axis: .horizontal)
        
        configurePhotoPreviewButton()
        configureRotateCameraButton()
    }
    
    func configurePhotoPreviewButton() {
        photoPreviewButton.imageView?.contentMode = .scaleAspectFill
        photoPreviewButton.backgroundColor = .ashGrey
        photoPreviewButton.layer.borderColor = UIColor.white.cgColor
        photoPreviewButton.layer.borderWidth = 1
        photoPreviewButton.layer.cornerRadius = 2
        photoPreviewButton.clipsToBounds = true
        photoPreviewButton.addTarget(self, action: #selector(pickImage), for: .touchUpInside)
        
        bottomPanelStack.addArrangedSubview(photoPreviewButton)
        photoPreviewButton.anchors.height.equal(24)
        photoPreviewButton.anchors.width.equal(24)
    }
    
    func configureRotateCameraButton() {
        rotateCameraButton.setImage(.iconRotate)
        rotateCameraButton.imageView?.contentMode = .scaleAspectFill
        rotateCameraButton.addTarget(self, action: #selector(switchCamera), for: .touchUpInside)
        
        bottomPanelStack.addArrangedSubview(rotateCameraButton)
        rotateCameraButton.anchors.height.equal(24)
        rotateCameraButton.anchors.width.equal(24)
    }
    
    func configureCameraContainerView() {
        cameraContainerView.backgroundColor = .clear
        cameraContainerView.clipsToBounds = true
        cameraContainerView.layer.cornerRadius = 16
        cameraContainerView.isUserInteractionEnabled = true
        
        view.addSubview(cameraContainerView)
        cameraContainerView.anchors.bottom.spacing(0, to: bottomPanelView.anchors.top)
        cameraContainerView.anchors.top.equal(view.anchors.top)
        cameraContainerView.anchors.edges.pin(axis: .horizontal)
        
        addChild(cameraController)
        cameraContainerView.addSubview(cameraController.view)
        cameraController.view.anchors.edges.pin()
        
        cameraController.didMove(toParent: self)
    }
}

extension CameraViewController: KKMediaPickerDelegate {
        
    public func didPermissionRejected() {
        KKMediaPicker.showAlertForAskPhotoPermisson(in: self)
    }
    
    public func didLoading(isLoading: Bool) {
        KKLogFile.instance.log(label:"CameraViewController", message: "didLoading")
        if isLoading {
            KKDefaultLoading.shared.show()
        } else {
            KKDefaultLoading.shared.hide()
        }
    }
    
    public func didSelectMedia(media item: KKMediaItem) {
        KKLogFile.instance.log(label:"CameraViewController", message: "didSelectMedia")
        dismiss(animated: true) { [weak self] in
            self?.didSelectMediaItem?(item)
        }
    }
    
    public func displayError(message: String) {
        if(message != ""){
            DispatchQueue.main.async {
                let okAction = UIAlertAction(title: "OK", style: .destructive)
                self.showAlertController(title: "Error", message: message,  actions: [okAction])
            }
        }
    }

}
