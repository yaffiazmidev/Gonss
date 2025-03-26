import UIKit
import KipasKipasShared

protocol VerifyIdentityChannelFeeAwardsViewDelegate: AnyObject {
    func didClickNavigateToWeb()
}

class VerifyIdentityChannelFeeAwardsView: UIView {

    @IBOutlet weak var containerView: UIView!
    
    weak var delegate: VerifyIdentityChannelFeeAwardsViewDelegate?
    
    var handleDismiss: (() -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initSubViews()
        setupComponent()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initSubViews()
    }
    
    private func initSubViews() {
        let nib = UINib(nibName: String(describing: type(of: self)), bundle: Bundle(for: type(of: self)))
        nib.instantiate(withOwner: self, options: nil)
        addSubview(containerView)
        containerView.anchors.edges.pin()
    }
    
    func setupComponent() {
        backgroundColor = .white
        overrideUserInterfaceStyle = .light
        containerView.backgroundColor = .white
    }
    
    @IBAction private func didClickNavigateToWebButton(_ sender: Any) {
        delegate?.didClickNavigateToWeb()
    }
    
    @IBAction private func didClickContinueInAppButton(_ sender: Any) {
        handleDismiss?()
    }
    
    @IBAction private func didClickCancelButton(_ sender: Any) {
        handleDismiss?()
    }
}
