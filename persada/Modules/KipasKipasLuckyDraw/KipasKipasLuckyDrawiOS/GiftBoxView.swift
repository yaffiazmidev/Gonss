import UIKit
import KipasKipasShared
import KipasKipasLuckyDraw

protocol GiftBoxViewDelegate: AnyObject {
    func didTapClose()
    func didTapButton(state: GiftBoxInfoContainerView.ButtonState)
}

final class GiftBoxView: UIView {
    private let container = UIView()
    private let stackView = UIStackView()
    
    private let headingContainerView = UIView()
    private let headingImageView = UIImageView()
    
    private let ribbonView = GiftBoxRibbonView()
    private let giftBoxAccessoryView = UIImageView()
    private let giftBoxInfoView = GiftBoxInfoContainerView()
    private let closeButton = KKBaseButton()
    
    weak var delegate: GiftBoxViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        return nil
    }
    
    @objc private func didTapCloseButton() {
        delegate?.didTapClose()
    }
    
    // MARK: API
    func configure(with viewModel: GiftBoxViewModel) {
        giftBoxInfoView.configure(with: viewModel)
    }
    
    func setButtonState(
        _ state: GiftBoxInfoContainerView.ButtonState,
        isLoading: Bool
    ) {
        giftBoxInfoView.setButtonState(state, isLoading: isLoading)
    }
  
    func setCountdown(
        schedule: GiftBoxLotteryScheduleViewModel,
        countdownDesc: String
    ) {
        ribbonView.timeLabel.text = "\(schedule.daysRemaining) Hari \(countdownDesc)"
    }
}

// MARK: UI
private extension GiftBoxView {
    func configureUI() {
        configureContainer()
        configureStackView()
        configureCloseButton()
    }
    
    func configureContainer() {
        container.backgroundColor = .clear
        container.clipsToBounds = true
        
        addSubview(container)
        container.anchors.edges.pin()
    }
    
    func configureStackView() {
        stackView.axis = .vertical
        
        container.addSubview(stackView)
        stackView.anchors.edges.pin(insets: 16, axis: .horizontal)
        stackView.anchors.edges.pin(axis: .vertical)
        
        configureHeadingContainerView()
        configureGiftBoxInfoView()
    }

    func configureHeadingContainerView() {
        headingContainerView.backgroundColor = .clear
        
        stackView.addArrangedSubview(spacer(14))
        stackView.addArrangedSubview(headingContainerView)
        headingContainerView.anchors.height.equal(70)
        
        headingImageView.image = UIImage.LuckyDraw.giftBoxHeading
        headingImageView.contentMode = .center
        
        headingContainerView.addSubview(headingImageView)
        headingImageView.anchors.height.equal(32)
        headingImageView.anchors.center.align()
    }
    
    func configureGiftBoxInfoView() {
        giftBoxInfoView.onTapButton = { [weak self] state in
            self?.delegate?.didTapButton(state: state)
        }
        
        stackView.addArrangedSubview(spacer(20))
        stackView.addArrangedSubview(giftBoxInfoView)
        stackView.addArrangedSubview(spacer(34))
        
        configureRibbonView()
        configureGiftBoxAccessoryView()
    }
    
    func configureRibbonView() {
        giftBoxInfoView.addSubview(ribbonView)
        ribbonView.anchors.centerX.align()
        ribbonView.anchors.centerY.equal(giftBoxInfoView.anchors.top, constant: 5)
        ribbonView.anchors.width.equal(giftBoxInfoView.anchors.width * 0.46)
        ribbonView.anchors.height.equal(20)
    }
    
    func configureGiftBoxAccessoryView() {
        giftBoxAccessoryView.image = UIImage.LuckyDraw.giftBoxDouble
        giftBoxAccessoryView.contentMode = .scaleAspectFill
        giftBoxAccessoryView.backgroundColor = .clear
        
        giftBoxInfoView.insertSubview(giftBoxAccessoryView, at: 0)
        giftBoxAccessoryView.anchors.trailing.pin()
        giftBoxAccessoryView.anchors.centerY.equal(giftBoxInfoView.anchors.top, constant: -10)
        giftBoxAccessoryView.anchors.width.equal(71)
        giftBoxAccessoryView.anchors.height.equal(57)
    }
    
    func configureCloseButton() {
        closeButton.setImage(UIImage.LuckyDraw.iconXOutlined?.withTintColor(.white), for: .normal)
        closeButton.backgroundColor = .clear
        closeButton.addTarget(self, action: #selector(didTapCloseButton), for: .touchUpInside)
        
        addSubview(closeButton)
        closeButton.anchors.width.equal(24)
        closeButton.anchors.height.equal(24)
        closeButton.anchors.trailing.pin(inset: 16)
        closeButton.anchors.top.pin(inset: adapted(dimensionSize: 32, to: .height))
    }
}
