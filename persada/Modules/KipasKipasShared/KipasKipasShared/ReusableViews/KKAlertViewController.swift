import UIKit

public final class KKAlertViewController: UIViewController {
    
    private let alertView = KKAlertView()
    
    private lazy var blurView: UIView = {
        let containerView = UIView()
        let blurEffect = UIBlurEffect(style: .light)
        
        let customBlurEffectView = CustomVisualEffectView(effect: blurEffect, intensity: 0.2)
        customBlurEffectView.frame = self.view.bounds
        
        let dimmedView = UIView()
        dimmedView.backgroundColor = .black.withAlphaComponent(0.6)
        dimmedView.frame = self.view.bounds
        
        containerView.addSubview(customBlurEffectView)
        containerView.addSubview(dimmedView)
        return containerView
    }()
    
    public var onTapOK: (() -> Void)?
    public var onTapCancel: (() -> Void)?
    
    private convenience init(
        title: String,
        desc: String,
        okButtonText: String
    ) {
        self.init(nibName: nil, bundle: nil)
        alertView.title = title
        alertView.desc = desc
        alertView.okButtonTitle = okButtonText
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        configureAlertView()
    }
    
    private func configureAlertView() {
        alertView.onTapOK = ok
        alertView.onTapCancel = cancel
        
        blurView.frame = view.bounds
        view.addSubview(blurView)
        view.sendSubviewToBack(blurView)
        
        blurView.addSubview(alertView)
        alertView.backgroundColor = .white
        alertView.anchors.center.align()
        alertView.anchors.width.equal(262)
        alertView.anchors.height.equal(154)
    }
    
    public static func composeUIWith(
        title: String,
        desc: String,
        okButtonText: String
    ) -> KKAlertViewController {
        return KKAlertViewController(
            title: title,
            desc: desc,
            okButtonText: okButtonText
        )
    }
    
    private func cancel() {
        dismiss(animated: true)
        onTapCancel?()
    }
    
    private func ok() {
        dismiss(animated: true)
        onTapOK?()
    }
}
