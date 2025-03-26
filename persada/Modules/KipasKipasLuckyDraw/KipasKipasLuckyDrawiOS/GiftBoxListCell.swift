import UIKit
import KipasKipasShared
import KipasKipasLuckyDraw
import Lottie

final class GiftBoxListCell: UICollectionViewCell {
    
    private var HEIGHT_RATIO: CGFloat = 0.285
    
    private let containerView = UIView()
    
    private lazy var giftImageView: LottieAnimationView = {
        let animation = LottieAnimation.named("giftbox")
        let view = LottieAnimationView(animation: animation)
        view.backgroundColor = .clear
        view.loopMode = .loop
        return view
    }()
    
    private let countdownContainer = UIView()
    private let countdownLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        return nil
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let height = (bounds.height * HEIGHT_RATIO)
        configureCountdownGradient(height: height)
    }
    
    // MARK: API
    func setCountdown(
        _ viewModel: GiftBoxLotteryScheduleViewModel,
        description: String?
    ) {
        if viewModel.isLessThanADay {
            countdownLabel.text = description
        } else {
            countdownLabel.text = "\(viewModel.daysRemaining) hari"
        }
    }
}

// MARK: UI
private extension GiftBoxListCell {
    func configureUI() {
        configureContainerView()
        configureGiftImageView()
        configureCountdownContainer()
        configureCountdownLabel()
    }
    
    func configureContainerView() {
        containerView.layer.cornerRadius = 10
        containerView.backgroundColor = .clear
        
        addSubview(containerView)
        containerView.anchors.edges.pin()
    }
    
    func configureGiftImageView() {
        giftImageView.clipsToBounds = true
        
        containerView.addSubview(giftImageView)
        giftImageView.anchors.edges.pin()
        giftImageView.anchors.center.align()
        giftImageView.play()
    }
    
    func configureCountdownContainer() {
        countdownContainer.backgroundColor = .clear
        containerView.addSubview(countdownContainer)
        
        countdownContainer.anchors.edges.pin(axis: .horizontal)
        countdownContainer.anchors.bottom.pin()
        countdownContainer.anchors.height.equal(anchors.height * HEIGHT_RATIO)
    }
    
    func configureCountdownLabel() {
        countdownLabel.font = .roboto(.regular, size: 8)
        countdownLabel.textAlignment = .center
        countdownLabel.textColor = .white
        
        countdownContainer.addSubview(countdownLabel)
        countdownLabel.anchors.edges.pin()
    }
    
    func configureCountdownGradient(height: CGFloat) {
        let gradient = CAGradientLayer()
        gradient.colors = [
            UIColor(hexString: "#FE37EA"),
            UIColor(hexString: "#FE4852")
        ].map { $0.cgColor }
        gradient.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradient.endPoint = CGPoint(x: 1.0, y: 0.5)
        gradient.locations = [0, 1]
        gradient.frame = .init(x: 0, y: 0, width: bounds.width, height: height)
        gradient.cornerRadius = height / 2
        
        countdownContainer.layer.insertSublayer(gradient, at: 0)
    }
}
