import UIKit
import KipasKipasShared
import KipasKipasLiveStream

public final class LiveStreamingListViewController: KKPageViewController {
    
    private let hud = KKProgressHUD()
    
    private lazy var emptyController = LiveStreamingEmptyListViewController()
    
    public override init(
        childControllers: [UIViewController] = [],
        navigationOrientation: UIPageViewController.NavigationOrientation = .vertical
    ) {
        super.init(navigationOrientation: .vertical)
    }
    
    public var loadActiveLiveStreams: (() -> Void)?
    
    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        return nil
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.interactivePopGestureRecognizer?.delegate = nil
        navigationController?.setNavigationBarHidden(true, animated: true)
        view.backgroundColor = .black
        
        hud.show(in: view)
        loadActiveLiveStreams?()
    }
    
    // MARK: API
    public func set(_ childControllers: [AudienceViewController]) {
        hud.dismiss()
        
        if childControllers.isEmpty {
            add(emptyController, ignoreSafeArea: false, animated: false)
            return
        }
        
        setViewControllers(
            childControllers,
            direction: .forward,
            animated: true
        )
    }
}
