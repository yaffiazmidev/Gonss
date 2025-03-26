import UIKit
import KipasKipasShared
import KipasKipasNetworking
import KipasKipasVerificationIdentity

class VerifyIdentitySelectIdController: UIViewController, NavigationAppearance {
    
    private lazy var mainView: VerifyIdentitySelectIdView = {
        let view = VerifyIdentitySelectIdView()
        view.delegate = self
        return view
    }()
    
    enum IdentityType: String {
        case ktp, pasport
    }
    
    private var viewModel: IVerifyIdentitySelectIdViewModel
    private var countries: [VerifyIdentityCountryItem] = []
    private var selectedCountry: VerifyIdentityCountryItem?
    private var selectedIdentity: IdentityType = .ktp
    private var handleBackToBalanceView: (() -> Void)?
    
    public init(viewModel: IVerifyIdentitySelectIdViewModel, handleBackToBalanceView: (() -> Void)?) {
        self.viewModel = viewModel
        self.handleBackToBalanceView = handleBackToBalanceView
        super.init(nibName: nil, bundle: nil)
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        defaultRequest()
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavigationBar(title: "Pilih Tanda Pengenal", backIndicator: .iconChevronLeft)
    }
    
    public override func loadView() {
        view = mainView
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func defaultRequest() {
        viewModel.fetchCountries()
    }
}

extension VerifyIdentitySelectIdController: VerifyIdentitySelectIdViewModelDelegate {
    func displayCountries(with items: [VerifyIdentityCountryItem]) {
        countries = items
        selectedCountry = countries.lazy.filter({ $0.id == "112" || $0.name?.lowercased() == "indonesia" }).first
        mainView.selectedCountryLabel.text = selectedCountry?.name ?? "-"
    }
    
    func displayError(with error: Error) {
        guard let error = error as? KKNetworkError else { return }
        print(error.errorDescription ?? "")
    }
}
extension VerifyIdentitySelectIdController: VerifyIdentitySelectIdViewDelegate {
    func didClickNext() {
        let uploadIdentityParam = VerifyIdentityUploadParam(
            typeId: selectedIdentity.rawValue,
            countryId: selectedCountry?.id ?? ""
        )
        let vc = VerifyIdentityApprovalController(
            uploadIdentityParam: uploadIdentityParam,
            handleBackToBalanceView: handleBackToBalanceView
        )
        vc.hidesBottomBarWhenPushed = true
        push(vc)
    }
    
    func didClickInfo() {
        let view = VerifyIdentityCountryOrRegionInfoView()
        let configureItem = KKBottomSheetConfigureItem(
            viewHeight: self.view.frame.height / 2,
            canSlideUp: false,
            canSlideDown: false
        )
        let vc = KKBottomSheetController(view: view, configure: configureItem)
        view.handleDidClickConfirmButton = vc.animateDismissView
        vc.modalPresentationStyle = .overFullScreen
        present(vc, animated: false)
    }
    
    func didClickCountryOrRegion() {
        let countries = countries
        let vc = VerifyIdentityCountryOrRegionController(title: "Pilih negara atau wilayah", countries: countries)
        vc.didSelectedCountry = { [weak self] item in
            guard let self = self else { return }
            self.selectedCountry = item
            mainView.selectedCountryLabel.text = item.name
        }
        vc.modalPresentationStyle = .overFullScreen
        present(vc, animated: false)
    }
}

extension VerifyIdentitySelectIdController {
    private func configureUI() {
        overrideUserInterfaceStyle = .light
        configureNavigationBar()
    }
    
    private func configureNavigationBar() {
        let guidelineButtonItem = UIBarButtonItem(image: .iconCircleQuestion,style: .plain,target: self,action: #selector(guidelineButtonPressed))
        navigationItem.rightBarButtonItem = guidelineButtonItem
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        navigationController?.interactivePopGestureRecognizer?.delegate = self
    }
    
    @objc func guidelineButtonPressed() {
        let view = VerifyIdentityGuidelineView()
        let configureItem = KKBottomSheetConfigureItem(viewHeight: self.view.frame.height - 200, canSlideUp: false)
        let vc = KKBottomSheetController(view: view, title: "Cara mengambil foto ID", configure: configureItem)
        vc.handleDraggingDirection = { _ in view.pageControl.isHidden = true }
        vc.handleDidEndDraggingDirection = { _ in view.pageControl.isHidden = false }
        vc.modalPresentationStyle = .overFullScreen
        present(vc, animated: false)
    }
}

extension VerifyIdentitySelectIdController: UIGestureRecognizerDelegate {}
