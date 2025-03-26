import UIKit
import KipasKipasShared

#warning("[BEKA] potential to be reusable")
public final class RegisterContainerViewController: UIViewController, NavigationAppearance {
    
    public struct PageModel {
        public let viewController: UIViewController
        public let title: String
        
        public init(viewController: UIViewController, title: String) {
            self.viewController = viewController
            self.title = title
        }
    }
    
    private lazy var pagingViewController = PanablePagingViewController()
    
    private let models: [PageModel]
    
    private var controllers: [UIViewController] = []
    private var items: [PagingItem] = []
    
    public init(models: [PageModel]) {
        self.models = models
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        return nil
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        setupNavigationBar(title: "Daftar", backIndicator: .iconChevronLeft)
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        setData()
        configureUI()
    }
    
    private func setData() {
        controllers = models.map { $0.viewController }
        items += models.enumerated().map { PagingIndexItem(
            index: $0.offset,
            title: $0.element.title
        )}
    }
}

private extension RegisterContainerViewController {
    func configureUI() {
        view.backgroundColor = .white
        navigationItem.setRightBarButton(.init(image: .iconCircleQuestion, style: .done, target: nil, action: nil), animated: false)
        configurePagingViewController()
    }
    
    func configurePagingViewController() {
        pagingViewController.menuItemSize = .sizeToFit(minWidth: view.bounds.width / 3, height: 38)
        pagingViewController.menuItemSpacing = 20
        pagingViewController.menuInsets = .init(top: 0, left: 16, bottom: 4, right: 16)
        pagingViewController.selectedScrollPosition = .preferCentered
        pagingViewController.menuPosition = .top
        pagingViewController.contentInteraction = .scrolling
        pagingViewController.menuInteraction = .none
        pagingViewController.dataSource = self
        pagingViewController.textColor = UIColor.white.withAlphaComponent(0.6)
        pagingViewController.textColor = .boulder
        pagingViewController.selectedTextColor = .night
        pagingViewController.indicatorColor = .night
        pagingViewController.indicatorOptions = .visible(height: 2, zIndex: Int.max, spacing: UIEdgeInsets.zero, insets: .zero)
        pagingViewController.borderColor = .gainsboro
        pagingViewController.borderOptions = .visible(height: 1, zIndex: Int.max - 1, insets: .zero)
        pagingViewController.menuBackgroundColor = .night
        pagingViewController.register(PagingTitleCell.self, for: PagingIndexItem.self)
        pagingViewController.menuHorizontalAlignment = .center
        pagingViewController.menuBackgroundColor = .white

        add(pagingViewController)
    }
}

// MARK: PagingViewControllerDataSource
extension RegisterContainerViewController: PagingViewControllerDataSource {
    public func pagingViewController(_: PagingViewController, viewControllerAt index: Int) -> UIViewController {
        return controllers[index]
    }
    
    public func pagingViewController(_: PagingViewController, pagingItemAt index: Int) -> PagingItem {
        return items[index]
    }
    
    public func numberOfViewControllers(in _: PagingViewController) -> Int {
        return controllers.count
    }
}
