import UIKit
import KipasKipasShared

class VerifyIdentityMarkInfoView: UIView {

    @IBOutlet weak var containerView: UIView!
    
    var handleOnTapConfirm: (() -> Void)?
    
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
    
    @IBAction func didClickConfirmButton(_ sender: Any) {
        handleOnTapConfirm?()
    }
}
