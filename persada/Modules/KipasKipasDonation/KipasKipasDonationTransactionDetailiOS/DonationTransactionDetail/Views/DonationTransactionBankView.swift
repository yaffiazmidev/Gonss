import UIKit
import KipasKipasShared

public class DonationTransacationBankView: UIView {
    
    private(set) lazy var titleStack = UIStackView()
    private(set) lazy var containerView = UIView()
    private(set) lazy var titleLabel = UILabel()
    private(set) lazy var nameLabel = UILabel()
    
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
        titleStack.distribution = .equalSpacing
        titleStack.anchors.top.equal(containerView.anchors.top)
        titleStack.anchors.leading.equal(containerView.anchors.leading, constant: 12)
        titleStack.anchors.trailing.equal(containerView.anchors.trailing, constant: -12)
        titleStack.anchors.bottom.equal(containerView.anchors.bottom)
        
        configureTitleLabel()
        configureNameLabel()
    }
    
    private func configureTitleLabel() {
        titleStack.addArrangedSubview(titleLabel)
        titleLabel.textColor = .placeholder
        titleLabel.textAlignment = .left
        titleLabel.font = .roboto(.regular, size: 14)
    }
    
    private func configureNameLabel() {
        titleStack.addArrangedSubview(nameLabel)
        nameLabel.textColor = .black
        nameLabel.textAlignment = .right
        nameLabel.font = .roboto(.regular, size: 14)
    }
    
    public func configure(title: String, name: String) {
        titleLabel.text = title
        if name == "undifined" {
            nameLabel.text = "-"
        } else {
            nameLabel.text = name.uppercased()
        }
    }
}
