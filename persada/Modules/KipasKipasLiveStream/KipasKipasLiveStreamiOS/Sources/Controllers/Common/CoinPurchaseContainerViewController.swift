import UIKit
import KipasKipasShared

public final class CoinPurchaseContainerViewController: UIViewController, PanModalPresentable {
    
    private let fakeNavbar = FakeNavBar()

    private let controller: UIViewController
    
    private var panNavigation: (UIViewController & PanModalPresentable)? {
        return navigationController as? (UIViewController & PanModalPresentable)
    }
    
    public init(controller: UIViewController) {
        self.controller = controller
        super.init(nibName: nil, bundle: nil)
    }
    
    public required init?(coder: NSCoder) {
        return nil
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        controller.overrideUserInterfaceStyle = .dark
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(false)
        panNavigation?.panModalSetNeedsLayoutUpdate()
        panNavigation?.panModalTransition(to: .longForm)
    }
    
    public var panScrollable: UIScrollView? {
        nil
    }
    
    public var longFormHeight: PanModalHeight {
        .maxHeightWithTopInset(100)
    }
    
    public var shortFormHeight: PanModalHeight {
        longFormHeight
    }
}

// MARK: UI
private extension CoinPurchaseContainerViewController {
    func configureUI() {
        configureFakeNavbar()
        configureChildController()
    }
    
    func configureFakeNavbar() {
        fakeNavbar.titleLabel.text = "Top Up Coin"
        fakeNavbar.titleLabel.font = .roboto(.regular, size: 14)
        fakeNavbar.titleLabel.textColor = .white
        fakeNavbar.titleLabel.textAlignment = .left
        fakeNavbar.backgroundColor = .gunMetal
        fakeNavbar.height = 41
        fakeNavbar.separatorView.backgroundColor = .gravel
        fakeNavbar.leftButton.setImage(.iconArrowLeft)
        fakeNavbar.leftButton.addTarget(self, action: #selector(didTapBack), for: .touchUpInside)
        fakeNavbar.titleHorizontalInsets = 40
        
        view.addSubview(fakeNavbar)
    }
    
    func configureChildController() {
        addChild(controller)
        
        view.addSubview(controller.view)
        controller.view.anchors.top.spacing(0, to: fakeNavbar.anchors.bottom)
        controller.view.anchors.edges.pin(axis: .horizontal)
        controller.view.anchors.bottom.pin()
        
        controller.didMove(toParent: self)
    }
    
    @objc func didTapBack() {
        navigationController?.popViewController(animated: true)
    }
}
