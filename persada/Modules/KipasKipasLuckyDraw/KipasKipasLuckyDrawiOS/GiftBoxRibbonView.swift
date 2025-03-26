import UIKit
import KipasKipasShared

final class GiftBoxRibbonView: UIView {
    
    private let ribbonImageView = UIImageView()
    
    let timeLabel = UILabel()
    
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
private extension GiftBoxRibbonView {
    func configureUI() {
        backgroundColor = .clear
        clipsToBounds = true
        
        configureRibbonImageView()
        configureTimeLabel()
    }
    
    func configureRibbonImageView() {
        ribbonImageView.image = UIImage.LuckyDraw.giftBoxRibbonView
        ribbonImageView.contentMode = .scaleAspectFill
        
        addSubview(ribbonImageView)
        ribbonImageView.anchors.edges.pin()
    }
    
    func configureTimeLabel() {
        timeLabel.font = .roboto(.bold, size: 13)
        timeLabel.textColor = .white
        timeLabel.textAlignment = .center
        
        addSubview(timeLabel)
        timeLabel.anchors.edges.pin(insets: 24, axis: .horizontal)
        timeLabel.anchors.edges.pin(insets: 2, axis: .vertical)
    }
}
