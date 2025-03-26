import UIKit
import KipasKipasShared

final class RealtimeAudienceToolbar: UIView {
    
    private let stackView = UIStackView()
    private let audienceIcon = UIImageView()
    private(set) var audienceCountLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        return nil
    }
    
    private func configureUI() {
        backgroundColor = UIColor.black.withAlphaComponent(0.2)
        layer.cornerRadius = 14
        
        configureStackView()
    }
    
    private func configureStackView() {
        stackView.alignment = .center
        stackView.distribution = .equalCentering
        stackView.spacing = 6
        
        addSubview(stackView)
        stackView.anchors.edges.pin(insets: 10, axis: .horizontal)
        stackView.anchors.edges.pin(axis: .vertical)
        
        configureAudienceIcon()
        configureAudienceCountLabel()
    }
    
    private func configureAudienceIcon() {
        audienceIcon.image = .iconUser
        
        stackView.addArrangedSubview(audienceIcon)
    }
    
    private func configureAudienceCountLabel() {
        audienceCountLabel.text = "0"
        audienceCountLabel.font = .roboto(.medium, size: 12)
        audienceCountLabel.textColor = .white
        
        stackView.addArrangedSubview(audienceCountLabel)
    }
}
