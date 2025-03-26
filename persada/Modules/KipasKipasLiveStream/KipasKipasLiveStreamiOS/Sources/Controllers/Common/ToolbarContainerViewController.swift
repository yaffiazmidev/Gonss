import UIKit
import KipasKipasShared

class ToolbarContainerViewController: UIViewController {
    
    private let container = UIStackView()
    private let topToolbarContainer = Stacker()
    private let bottomToolbarContainer = Stacker()
    
    convenience init(topToolbars: [UIView], bottomToolbars: [UIView]) {
        self.init(nibName: nil, bundle: nil)
        topToolbars.forEach { topToolbarContainer.addArrangedSubViews($0) }
        bottomToolbars.forEach { bottomToolbarContainer.addArrangedSubViews($0) }
    }
    
    override func loadView() {
        view = PassthroughView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        hideToolbar(animated: false)
    }
    
    func addTopToolbar(_ view: UIView) {
        topToolbarContainer.addArrangedSubViews(view)
    }
    
    func addBottomToolbar(_ view: UIView) {
        bottomToolbarContainer.addArrangedSubViews(view)
    }
    
    func addBottomToolbarToFirstIndex(_ view: UIView) {
        bottomToolbarContainer.insertArrangedSubViews(view, at: 0)
    }
    
    func setBottomToolbarHorizontalInsets(_ insets: CGFloat) {
        bottomToolbarContainer.paddingLeft = insets
        bottomToolbarContainer.paddingRight = insets
    }
}

// MARK: Animations
extension ToolbarContainerViewController {
    func hideToolbar(animated: Bool = true, completion: @escaping () -> Void = {}) {
        guard animated else { return transform() }
        
        animate(animation: transform, completion: completion)
        
        func transform() {
            topToolbarContainer.transform = CGAffineTransform(translationX: 0, y: -view.bounds.height)
            bottomToolbarContainer.transform = CGAffineTransform(translationX: 0, y: view.bounds.height)
            topToolbarContainer.alpha = 0
            bottomToolbarContainer.alpha = 0
        }
    }
    
    func showToolbar(animated: Bool = true, completion: @escaping () -> Void = {}) {
        guard animated else { return transform() }
        
        animate(animation: transform, completion: completion)

        func transform() {
            topToolbarContainer.transform = CGAffineTransform.identity
            bottomToolbarContainer.transform = CGAffineTransform.identity
            topToolbarContainer.alpha = 1
            bottomToolbarContainer.alpha = 1
        }
    }
    
    func animate(animation: @escaping () -> Void, completion: @escaping () -> Void) {
        UIView.animate(
            withDuration: 0.7,
            delay: 0.3,
            options: [.curveEaseOut],
            animations: {
                animation()
            }, completion: { _ in
                completion()
            }
        )
    }
}

// MARK: UI
private extension ToolbarContainerViewController {
    func configureUI() {
        view.backgroundColor = .clear
        
        configureContainer()
        configureTopToolbarContainer()
        configureBottomToolbarContainer()
    }
  
    func configureContainer() {
        container.axis = .vertical
        container.distribution = .fillEqually
        
        view.addSubview(container)
        container.anchors.edges.pin()
    }
    
    func configureTopToolbarContainer() {
        topToolbarContainer.isScrollEnabled = false
        topToolbarContainer.alignment = .top
        topToolbarContainer.spacingBetween = 8
        container.addArrangedSubview(topToolbarContainer)
    }
    
    func configureBottomToolbarContainer() {
        bottomToolbarContainer.isScrollEnabled = false
        bottomToolbarContainer.alignment = .bottom
        bottomToolbarContainer.spacingBetween = 8
        container.addArrangedSubview(bottomToolbarContainer)
    }
}
