import UIKit
import KipasKipasShared
import KipasKipasDonateStuff

final class DonationItemDetailStakeholderCell: UICollectionViewCell {
    
    private let stackContainer = UIStackView()
    private let supplierView = DonationItemStakeholderView()
    private let initiatorView = DonationItemStakeholderView()
        
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        return nil
    }
    
    func setSupplierImage(_ image: UIImage?) {
        supplierView.imageView.setImageAnimated(image)
    }
    
    func setInitiatorImage(_ image: UIImage?) {
        initiatorView.imageView.setImageAnimated(image)
    }
    
    func configure(with viewModel: DonationItemDetailStakeholder) {
        supplierView.roleLabel.text = "Penyedia Barang"
        supplierView.nameLabel.text = viewModel.supplierName
        
        initiatorView.roleLabel.text = "Penyalur"
        initiatorView.nameLabel.text = viewModel.initiatorName
    }
}

// MARK: UI
private extension DonationItemDetailStakeholderCell {
    func configureUI () {
        contentView.backgroundColor = .white
        
        configureStackContainer()
        configureSupplierView()
        configureInitiatorView()
        configureSpacerView()
    }
    
    func configureStackContainer() {
        stackContainer.spacing = 4
        stackContainer.distribution = .fillEqually
        stackContainer.alignment = .center
        
        addSubview(stackContainer)
        stackContainer.anchors.edges.pin(insets: 16, axis: .vertical)
        stackContainer.anchors.edges.pin(axis: .horizontal)
    }
    
    func configureSupplierView() {
        stackContainer.addArrangedSubview(supplierView)
    }
    
    func configureInitiatorView() {
        stackContainer.addArrangedSubview(initiatorView)
    }
    
    func configureSpacerView() {
        let spacer = UIView()
        spacer.backgroundColor = .alabaster
        
        addSubview(spacer)
        spacer.anchors.width.equal(4)
        spacer.anchors.edges.pin(axis: .vertical)
        spacer.anchors.center.align()
    }
}
