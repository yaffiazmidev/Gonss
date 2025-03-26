import UIKit
import KipasKipasShared

public class DonationTransacationTitleVerifiedView: UIView {
    
    private(set) lazy var titleStack = UIStackView()
    private(set) lazy var nameStack = UIStackView()
    private(set) lazy var containerView = UIView()
    private(set) lazy var titleLabel = UILabel()
    private(set) lazy var nameLabel = UILabel()
    private(set) lazy var verifiedIcon = UIImageView()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureUI() {
        UIFont.loadCustomFonts
        configureContainerView()
    }
    
    private func configureContainerView() {
        addSubview(containerView)
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.anchors.edges.pin()
        
        configureTitleStack()
    }
    
    private func configureTitleStack() {
        containerView.addSubview(titleStack)
        titleStack.translatesAutoresizingMaskIntoConstraints = false
        titleStack.backgroundColor = .white
        titleStack.axis = .horizontal
        titleStack.distribution = .fillEqually
        titleStack.anchors.top.equal(containerView.anchors.top)
        titleStack.anchors.leading.equal(containerView.anchors.leading, constant: 12)
        titleStack.anchors.trailing.equal(containerView.anchors.trailing, constant: -12)
        titleStack.anchors.bottom.equal(containerView.anchors.bottom)
        
        configureTitleLabel()
        configureNameStack()
    }
    
    private func configureTitleLabel() {
        titleStack.addArrangedSubview(titleLabel)
        titleLabel.textColor = .placeholder
        titleLabel.textAlignment = .left
        titleLabel.font = .roboto(.regular, size: 14)
    }
    
    private func configureNameStack() {
        titleStack.addSubview(nameStack)
        nameStack.translatesAutoresizingMaskIntoConstraints = false
        nameStack.backgroundColor = .clear
        nameStack.axis = .horizontal
        nameStack.spacing = 4
        nameStack.distribution = .fillProportionally
        nameStack.anchors.top.equal(containerView.anchors.top)
        nameStack.anchors.leading.equal(containerView.anchors.leading, constant: 20)
        nameStack.anchors.trailing.equal(containerView.anchors.trailing, constant: -12)
        nameStack.anchors.bottom.equal(containerView.anchors.bottom)
        
        configureNameLabel()
        configureVerifiedIcon()
    }
    
    private func configureNameLabel() {
        nameStack.addArrangedSubview(nameLabel)
        nameLabel.textColor = .black
        nameLabel.textAlignment = .right
        nameLabel.font = .roboto(.regular, size: 14)
    }
    
    private func configureVerifiedIcon() {
        nameStack.addArrangedSubview(verifiedIcon)
        verifiedIcon.translatesAutoresizingMaskIntoConstraints = false
        verifiedIcon.anchors.width.equal(10)
        verifiedIcon.image = .iconVerified
        verifiedIcon.contentMode = .center
    }
    
    public func configure(title: String, name: String, isVerified: Bool) {
        titleLabel.text = title
        nameLabel.text = name
        verifiedIcon.isHidden = !isVerified
    }
}
