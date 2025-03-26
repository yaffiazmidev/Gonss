import UIKit
import KipasKipasShared

final class DonationItemPaymentSummaryCell: UICollectionViewCell {
    private let stackView = UIStackView()
    private let stackDetail = UIStackView()
    
    let titleLabel = UILabel()
    let detailLabel = UILabel()
    let copyButton = UIButton()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        return nil
    }
}

// MARK: UI
private extension DonationItemPaymentSummaryCell {
    func configureUI() {
        contentView.backgroundColor = .white
        configureStackView()
    }
    
    func configureStackView() {
        stackView.distribution = .equalCentering
        stackView.alignment = .center
        
        addSubview(stackView)
        stackView.anchors.top.pin(inset: 6)
        stackView.anchors.edges.pin(insets: 16, axis: .horizontal)
        stackView.anchors.bottom.pin(inset: 6)
        
        titleLabel.text = .placeholderWithSpaces(count: 25)
        stackView.addArrangedSubview(titleLabel)
        
        configureStackDetail()
    }
    
    func configureStackDetail() {
        stackDetail.alignment = .top
        stackDetail.spacing = 6
        stackDetail.distribution = .equalCentering
        stackView.addArrangedSubview(stackDetail)
        
        configureDetaiLabel()
        configureCopyButton()
    }
    
    func configureDetaiLabel() {
        detailLabel.numberOfLines = 2
        detailLabel.text = .placeholderWithSpaces(count: 20)
        detailLabel.textAlignment = .right
        
        stackDetail.addArrangedSubview(detailLabel)
        detailLabel.anchors.width.equal(bounds.width * 0.4)
    }
    
    func configureCopyButton() {
        copyButton.backgroundColor = .clear
        copyButton.setImage(UIImage(systemName: "doc.on.doc"))
        copyButton.tintColor = .boulder
        copyButton.addTarget(self, action: #selector(copyText), for: .touchUpInside)
        
        stackDetail.addArrangedSubview(copyButton)
        copyButton.anchors.width.equal(14)
        copyButton.anchors.height.equal(14)
    }
    
    @objc func copyText() {
        UIPasteboard.general.string = detailLabel.text
        appWindow?.topMostVC?.showToast(
            with: "Tersalin",
            verticalSpace: 70
        )
    }
}
