import UIKit

public protocol KKPageViewControllerEventDelegate: AnyObject {
    func pageViewController(willMoveTo childController: UIViewController?, from previousController: UIViewController?)
    func pageViewController(didMoveTo childController: UIViewController, currentIndex: Int, from previousController: UIViewController?)
}

public protocol KKPageViewControllerDelegate {
    var isScrollEnabled: Bool { get set }
    
    func scrollTo(index: Int, direction: UIPageViewController.NavigationDirection, animated: Bool)
}

open class KKPageViewController: UIPageViewController {
    
    private var childControllers: [UIViewController]
    
    private var currentSelectedIndex: Int = 0
    
    public var currentViewController: UIViewController? {
        return childControllers[safe: currentSelectedIndex]
    }
    
    public var scrollView: UIScrollView? {
        view.subviews.first(where: { $0 is UIScrollView }) as? UIScrollView
    }
    
    public weak var eventDelegate: KKPageViewControllerEventDelegate?
    
    public init(childControllers: [UIViewController] = [], navigationOrientation: UIPageViewController.NavigationOrientation = .horizontal) {
        self.childControllers = childControllers
        super.init(transitionStyle: .scroll, navigationOrientation: navigationOrientation, options: [:])
        guard let firstController = self.childControllers.first else { return }
        super.setViewControllers([firstController], direction: .forward, animated: false, completion: nil)
    }
    
    @available(*, unavailable)
    required public init?(coder: NSCoder) {
        return nil
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        dataSource = self
        delegate = self
        
        view.backgroundColor = .white
        view.layoutMargins = .zero
        view.preservesSuperviewLayoutMargins = true
        view.insetsLayoutMarginsFromSafeArea = false
        
        for view in view.subviews {
            if let scrollView = view as? UIScrollView {
                scrollView.delaysContentTouches = false
                scrollView.preservesSuperviewLayoutMargins = true
            }
        }
    }
    
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let margins = view.layoutMargins
        childControllers.forEach({
            if $0.view.preservesSuperviewLayoutMargins && $0.view.layoutMargins != margins  {
                $0.view.layoutMargins = margins
            }
        })
    }
    
    open override func setViewControllers(_ viewControllers: [UIViewController]?, direction: UIPageViewController.NavigationDirection, animated: Bool, completion: ((Bool) -> Void)? = nil) {
        guard let first = viewControllers?.first else {
            completion?(true)
            return
        }
        super.setViewControllers([first], direction: direction, animated: animated, completion: completion)
        self.childControllers = viewControllers ?? []
    }
}

// MARK: KKPageViewControllerDelegate
extension KKPageViewController: KKPageViewControllerDelegate {
    public var isScrollEnabled: Bool {
        get { scrollView?.isScrollEnabled ?? false }
        set { scrollView?.isScrollEnabled = newValue }
    }
    
    public func scrollTo(index: Int, direction: NavigationDirection, animated: Bool = true) {
        guard let controller = childControllers[safe: index] else { return }
        super.setViewControllers([controller], direction: direction, animated: animated, completion: nil)
    }
}

// MARK: - UIPageViewControllerDataSource & UIPageViewControllerDelegate
extension KKPageViewController: UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    public func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let index = childControllers.firstIndex(of: viewController) else { return nil }
        let newIndex = index - 1
        if newIndex < 0 { return nil }
        return childControllers[newIndex]
    }
    
    public func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let index = childControllers.firstIndex(of: viewController) else { return nil }
        let newIndex = index + 1
        if newIndex > childControllers.count - 1 { return nil }
        return childControllers[newIndex]
    }
    
    public func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if completed {
            if let currentViewController = pageViewController.viewControllers?.first,
               let previousController = previousViewControllers.first,
            let index = childControllers.firstIndex(of: currentViewController) {
                currentSelectedIndex = index
                eventDelegate?.pageViewController(didMoveTo: currentViewController, currentIndex: index, from: previousController)
            }
        }
    }
    
    public func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
        let fromViewController = childControllers[safe: currentSelectedIndex]
        let toViewController = pendingViewControllers.first
        
        eventDelegate?.pageViewController(willMoveTo: toViewController, from: fromViewController)
    }
}

private extension Collection {
    subscript (safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
