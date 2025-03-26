import UIKit
import KipasKipasShared

public final class DonationRankBadgeContainerViewController: UIViewController {
    
    public struct PageModel {
        public let childController: UIViewController
        public let title: String
    }
    
    private var selectedMenuIndex: Int = 0
    
    private lazy var pageMenu: KKPageMenu = {
        let pageMenu = KKPageMenu(frame: .init(
            x: 0,
            y: safeAreaInsets.top,
            width: view.bounds.width,
            height: 34
        ))
        return pageMenu
    }()
    
    private lazy var backButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = UIColor.white.withAlphaComponent(0.1)
        button.setTitleColor(UIColor.white, for: .normal)
        button.setTitle("Kembali", for: .normal)
        button.titleLabel?.font = .roboto(.regular, size: 14)
        button.addTarget(self, action: #selector(dismissSelf), for: .touchUpInside)
        return button
    }()
    
    private let pageModels: [PageModel]
    private let pageViewController: KKPageViewController
    
    public init(pageModels: [PageModel]) {
        self.pageModels = pageModels
        self.pageViewController = KKPageViewController(childControllers: pageModels.map { $0.childController })
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        return nil
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .deepPurple
        configureUI()
    }
    
    @objc private func dismissSelf() {
        dismiss(animated: true)
    }
}

// MARK: UI
private extension DonationRankBadgeContainerViewController {
    func configureUI() {
        configurePageMenu()
        configureBackButton()
        configurePageViewController()
    }
    
    func configurePageMenu() {
        let titles = pageModels.map { $0.title }
        let itemWidth = view.bounds.width / CGFloat(titles.count)
        
        pageMenu.titles = pageModels.map { $0.title }
        pageMenu.labelWidthType = .fixed(width: itemWidth)
        pageMenu.normalTitleColor = .softPeach
        pageMenu.selectedTitleColor = .white
        pageMenu.indicatorColor = .white
        pageMenu.titleFont = .roboto(.regular, size: 12)
        pageMenu.selectedTitleFont = .roboto(.medium, size: 12)
        pageMenu.backgroundColor = .deepPurple
        pageMenu.indicatorStyle = .line(
            widthType: .fixed(width: itemWidth),
            position: .bottom((0, 1))
        )
        
        pageMenu.valueChange = { [weak self] index in
            guard let self = self else { return }
            let shouldForward =  index > self.selectedMenuIndex
            self.pageViewController.scrollTo(index: index, direction: shouldForward ? .forward : .reverse)
            self.selectedMenuIndex = index
        }
        
        view.addSubview(pageMenu)
    }
    
    func configureBackButton() {
        view.addSubview(backButton)
        backButton.anchors.width.equal(view.anchors.width)
        backButton.anchors.height.equal(66)
        backButton.anchors.bottom.pin()
    }
    
    func configurePageViewController() {
        pageViewController.eventDelegate = self
        pageViewController.view.backgroundColor = .deepPurple
        pageViewController.view.preservesSuperviewLayoutMargins = true
        pageViewController.isDoubleSided = true

        addChild(pageViewController)
        pageViewController.didMove(toParent: self)
        view.addSubview(pageViewController.view)

        pageViewController.view.anchors.top.spacing(0, to: pageMenu.anchors.bottom)
        pageViewController.view.anchors.leading.pin()
        pageViewController.view.anchors.bottom.spacing(0, to: backButton.anchors.top)
        pageViewController.view.anchors.trailing.pin()
    }
}

extension DonationRankBadgeContainerViewController: KKPageViewControllerEventDelegate {
    public func pageViewController(willMoveTo childController: UIViewController?, from previousController: UIViewController?) {}
    
    public func pageViewController(didMoveTo childController: UIViewController, currentIndex: Int, from previousController: UIViewController?) {
        pageMenu.setSelectIndex(index: currentIndex, animated: true)
    }
}
