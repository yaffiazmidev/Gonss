import UIKit
import KipasKipasShared
import KipasKipasDonateStuff

final class DonationItemPaymentHeaderCell: UICollectionViewCell {
    private let backgroundImageView = UIImageView()
    private let stackContainer = UIStackView()
    
    private let stackLabel = UIStackView()
    
    let headingLabel = TopAlignedLabel()
    let subheadingLabel = InteractiveLabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        return nil
    }
}

private extension DonationItemPaymentHeaderCell {
    func configureUI() {
        configureBackgroundView()
        configureStackContainer()
        configureStackLabel()
    }
    
    func configureStackContainer() {
        stackContainer.backgroundColor = .clear
        stackContainer.axis = .vertical
        stackContainer.spacing = 6
        
        addSubview(stackContainer)
        stackContainer.anchors.top.pin()
        stackContainer.anchors.trailing.pin(inset: 12)
        stackContainer.anchors.bottom.pin(inset: 14)
        stackContainer.anchors.leading.pin(inset: 45)
        
        let view = UIView()
        view.backgroundColor = .clear
        
        stackContainer.addArrangedSubview(view)
        view.anchors.edges.pin(axis: .horizontal)
        view.anchors.height.equal(statusBarFrame.height)
    }
    
    func configureBackgroundView(){
        backgroundImageView.contentMode = .scaleAspectFill
        backgroundImageView.image = .paymentHeaderBackground
        
        addSubview(backgroundImageView)
        backgroundImageView.anchors.edges.pin()
    }
    
    func configureStackLabel() {
        stackLabel.spacing = 2
        stackLabel.axis = .vertical
        stackLabel.backgroundColor = .clear
        stackLabel.alignment = .top
        stackLabel.distribution = .equalCentering
        
        stackContainer.addArrangedSubview(stackLabel)
        
        configureHeadingLabel()
        configureSubheadingLabel()
    }
    
    func configureHeadingLabel() {
        headingLabel.font = .roboto(.bold, size: 24)
        headingLabel.textColor = .night
        
        stackLabel.addArrangedSubview(headingLabel)
    }
    
    func configureSubheadingLabel() {
        subheadingLabel.numberOfLines = 2
        subheadingLabel.font = .roboto(.regular, size: 13)
        subheadingLabel.textColor = .boulder
        
        stackLabel.addArrangedSubview(subheadingLabel)
    }
}

final class DonationItemPaymentHeaderCellController: NSObject {
    
    private let viewModel: DonationItemPaymentStatusViewModel
    
    var cell: DonationItemPaymentHeaderCell?
    
    init(viewModel: DonationItemPaymentStatusViewModel) {
        self.viewModel = viewModel
    }
    
    private var headingtext: String? {
        switch viewModel.paymentStatus {
        case .WAIT:
            return "Menunggu Pembayaran"
        case .PAID:
            return "Donasi Berhasil"
        case .EXPIRED:
            return "Pembayaran Expired"
        case .none:
            return nil
        }
    }
    
    private var subheadingText: String? {
        switch viewModel.paymentStatus {
        case .WAIT:
            return "Segera melakukan pembayaran sebelum " + viewModel.expiredPaymentTimeDesc
        case .PAID:
            return "Terima kasih, donasi kamu sangat berguna bagi mereka yang membutuhkan."
        case .EXPIRED, .none:
            return nil
        }
    }
}

extension DonationItemPaymentHeaderCellController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        cell = collectionView.dequeueReusableCell(at: indexPath)
        cell?.headingLabel.text = headingtext
        
        let customType = InteractiveLabelType.custom(pattern: viewModel.expiredPaymentTimeDesc)
        cell?.subheadingLabel.enabledTypes = [customType]
        cell?.subheadingLabel.text = subheadingText
        cell?.subheadingLabel.customColor[customType] = .night
        cell?.subheadingLabel.highlightedFont = .roboto(.bold, size: 13)
        
        return cell!
    }
}
