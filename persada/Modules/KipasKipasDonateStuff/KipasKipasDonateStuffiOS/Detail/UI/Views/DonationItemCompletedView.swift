import UIKit
import KipasKipasShared

final class DonationItemCompletedView: UIView {
    private let stackView = UIStackView()
    private let imageView = UIImageView()
    private let descriptionLabel = UILabel()
    
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
private extension DonationItemCompletedView {
    func configureUI() {
        backgroundColor = .greenWhite
        
        configureStackView()
        configureImageView()
        configureDescriptionLabel()
    }
    
    func configureStackView() {
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = 12
        
        addSubview(stackView)
        stackView.anchors.edges.pin(insets: 16)
    }
    
    func configureImageView() {
        imageView.image = .iconCircleCheckGreen
        imageView.contentMode = .scaleAspectFill
        
        stackView.addArrangedSubview(imageView)
        imageView.anchors.width.equal(44)
        imageView.anchors.height.equal(44)
    }
    
    func configureDescriptionLabel() {
        descriptionLabel.font = .roboto(.regular, size: 12)
        descriptionLabel.textAlignment = .center
        descriptionLabel.textColor = .gravel
        descriptionLabel.text = "Jumlah yang dibutuhkan sudah terpenuhi, terima kasih kepada para donatur atas partisipasinya, donasi kamu sangat membantu mereka yang membutuhkan."
        descriptionLabel.numberOfLines = 0
        
        stackView.addArrangedSubview(descriptionLabel)
    }
}
