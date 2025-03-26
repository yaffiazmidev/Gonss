import UIKit
import KipasKipasShared

final class GiftBoxScheduleView: UIView {
    
    private let stackView = UIStackView()
    
    private(set) var titleLabel = UILabel()
    private(set) var timeLabel = UILabel()
    
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
private extension GiftBoxScheduleView {
    func configureUI() {
        configureStackView()
    }
    
    func configureStackView() {
        stackView.axis = .vertical
        stackView.spacing = 4
        
        addSubview(stackView)
        stackView.anchors.edges.pin(insets: 14, axis: .vertical)
        stackView.anchors.edges.pin(insets: 18, axis: .horizontal)
        
        configureTitleLabel()
        configureTimeLabel()
    }
    
    func configureTitleLabel() {
        titleLabel.font = .roboto(.medium, size: 15)
        titleLabel.textColor = .paleCarmine
        
        stackView.addArrangedSubview(titleLabel)
    }
    
    func configureTimeLabel() {
        timeLabel.font = .roboto(.regular, size: 13)
        timeLabel.textColor = UIColor.redOxide.withAlphaComponent(0.5)
        timeLabel.numberOfLines = 0
        
        stackView.addArrangedSubview(timeLabel)
    }
}
