import UIKit
import KipasKipasShared
import KipasKipasCamera
import KipasKipasVerificationIdentity
import KipasKipasNetworkingUtils

public class VerifyIdentityApprovalController: UIViewController, NavigationAppearance {

    private lazy var mainView: VerifyIdentityApprovalView = {
        let view = VerifyIdentityApprovalView()
        view.delegate = self
        return view
    }()
    
    private let uploadIdentityParam: VerifyIdentityUploadParam
    private var handleBackToBalanceView: (() -> Void)?
    
    init(
        uploadIdentityParam: VerifyIdentityUploadParam,
        handleBackToBalanceView: (() -> Void)?
    ) {
        self.uploadIdentityParam = uploadIdentityParam
        self.handleBackToBalanceView = handleBackToBalanceView
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        overrideUserInterfaceStyle = .light
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavigationBar(backIndicator: .iconChevronLeft)
    }
    
    public override func loadView() {
        view = mainView
    }
}

extension VerifyIdentityApprovalController: VerifyIdentityApprovalViewDelegate {
    func didClickNext() {
        let identityUploader: VerifyIdentityUploader = VerifyIdentityLoaderFactory.shared.get(.uploadIdentity)
        let mediaUploader: MediaUploader = VerifyIdentityLoaderFactory.shared.get(.mediaUploader)
        let viewModel = VerifyIdentityUploadViewModel(uploader: identityUploader, mediaUploader: mediaUploader)
        let vc = VerifyIdentityUploadController(
            viewModel: viewModel,
            handleBackToBalanceView: handleBackToBalanceView
        )
        viewModel.delegate = vc
        viewModel.uploadIdentityParam = uploadIdentityParam
        vc.hidesBottomBarWhenPushed = true
        push(vc)
    }
    
    func didClickGuideline() {
        let view = VerifyIdentityGuidelineView()
        let configureItem = KKBottomSheetConfigureItem(viewHeight: self.view.frame.height - 200, canSlideUp: false)
        let vc = KKBottomSheetController(view: view, title: "Cara mengambil foto ID", configure: configureItem)
        vc.handleDraggingDirection = { _ in view.pageControl.isHidden = true }
        vc.handleDidEndDraggingDirection = { _ in view.pageControl.isHidden = false }
        vc.modalPresentationStyle = .overFullScreen
        present(vc, animated: false)
    }
}
