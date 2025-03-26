import UIKit
import KipasKipasShared

public class VerifyIdentityInfoCheckView: UIView {

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var limitLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var requiredContainerStack: UIStackView!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var addEmailLabel: UILabel!
    @IBOutlet weak var userMobileLabel: UILabel!
    @IBOutlet weak var addUserMobileLabel: UILabel!
    @IBOutlet weak var emailStatusIconImageView: UIImageView!
    @IBOutlet weak var userMobileStatusIconImageView: UIImageView!
    @IBOutlet weak var diamondStatusIconImageView: UIImageView!
    
    public enum ViewType: Equatable {
        case limit
        case required(email: String, mobile: String, diamond: Bool)
    }
        
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
    
    func setupViewType(with type: ViewType) {
        limitLabel.isHidden = true
        requiredContainerStack.isHidden = true
        titleLabel.text = type.title
        
        switch type {
        case .limit:
            limitLabel.isHidden = false
        case let .required(email, mobile, diamond):
            requiredContainerStack.isHidden = false
            addEmailLabel.text = email.isEmpty ? "Tambahkan email" : "Ubah"
            addUserMobileLabel.text = mobile.isEmpty ? "Tambahkan nomor telepon" : "Ubah"
            emailLabel.isHidden = email.isEmpty
            userMobileLabel.isHidden = mobile.isEmpty
            
            emailLabel.text = email
            userMobileLabel.text = mobile
            
            emailStatusIconImageView.image = email.isEmpty ? .iconCircleCloseFillRed : .iconCircleCheckGreen
            userMobileStatusIconImageView.image = mobile.isEmpty ? .iconCircleCloseFillRed : .iconCircleCheckGreen
//            diamondStatusIconImageView.image = !diamond ? .iconCircleCloseFillRed : .iconCircleCheckGreen
        }
    }
    
    @IBAction func didClickConfirmButton(_ sender: Any) {
        handleDismiss?()
    }
}

private extension VerifyIdentityInfoCheckView.ViewType {
    var title: String {
        switch self {
        case .limit:
            return "Sudah beberapa kali gagal\n verifikasi ID"
        case .required:
            return "Lengkapi beberapa\n persyaratan di bawah ini untuk\n mulai verifikasi ID"
        }
    }
}
