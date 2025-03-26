import UIKit
import KipasKipasShared
import KipasKipasLuckyDraw
import KipasKipasImage

final class GiftBoxInfoContainerView: UIView {
    
    enum ButtonState {
        case join
        case follow
        case joined
    }
    
    private let container = UIView()
    private let stackView = UIStackView()
    
    private let productView = GiftBoxProductView()
    private let scheduleView = GiftBoxScheduleView()
    private let button = KKLoadingButton()
    
    private var buttonState: ButtonState = .join {
        didSet {
            updateButtonApperance()
        }
    }
    
    var onTapButton: Closure<ButtonState>?
    
    // MARK: Overridens
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
        updateButtonApperance()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        return nil
    }
    
    // MARK: Privates
    private func updateButtonApperance() {
        switch buttonState {
        case .join:
            button.setTitle("Ikuti Undian")
            button.isEnabled = true
            button.gradientBorderColors = [
                UIColor(hexString: "#FDFF85"),
                UIColor(hexString: "#FFB155")
            ]
        case .follow:
            button.setTitle("Follow")
            button.isEnabled = true
            button.gradientBorderColors = [
                UIColor(hexString: "#FDFF85"),
                UIColor(hexString: "#FFB155")
            ]
        case .joined:
            button.setTitle("Telah Berpartisipasi")
            button.isEnabled = false
            button.gradientBorderColors = [
                UIColor(hexString: "#F3F3F3"),
                UIColor(hexString: "#CACACA")
            ]
        }
    }
    
    @objc private func didTapButton() {
        guard buttonState == .join || buttonState == .follow else {
            return
        }
        
        onTapButton?(buttonState)
    }
    
    // MARK: API
    func configure(with viewModel: GiftBoxViewModel) {
        configureProductView(with: viewModel)
        configureScheduleView(with: viewModel)
    }
    
    func setButtonState(_ state: ButtonState, isLoading: Bool) {
        buttonState = state
        
        if isLoading {
            button.showLoader(userInteraction: false)
        } else {
            button.hideLoader()
        }
    }
    
    private func configureProductView(with viewModel: GiftBoxViewModel) {
        KipasKipasImage.fetchImage(
            with: .init(url: viewModel.photoURL),
            into: productView.productImageView
        )
        productView.productNameLabel.text = viewModel.giftName
        
        let attributedText = NSMutableAttributedString(
            string: viewModel.priceDesc,
            attributes: [
                .font: UIFont.roboto(.regular, size: 12),
                .strikethroughStyle: 1,
                .strikethroughColor: UIColor.redOxide.withAlphaComponent(0.5),
                .foregroundColor: UIColor.redOxide.withAlphaComponent(0.5)
            ]
        )
        productView.priceLabel.attributedText = attributedText
    }
    
    private func configureScheduleView(with viewModel: GiftBoxViewModel) {
        scheduleView.titleLabel.text = viewModel.scheduleTitle
        scheduleView.titleLabel.isHidden = viewModel.scheduleTitle == nil
        
        scheduleView.timeLabel.text = viewModel.scheduleTimeDesc
        scheduleView.timeLabel.isHidden = viewModel.scheduleTimeDesc == nil
    }
}

// MARK: UI
private extension GiftBoxInfoContainerView {
    func configureUI() {
        configureContainer()
        configureStackView()
    }
    
    func configureContainer() {
        container.backgroundColor = .oasis
        container.layer.cornerRadius = 10
        container.clipsToBounds = true
        
        addSubview(container)
        container.anchors.edges.pin()
    }
    
    func configureStackView() {
        stackView.axis = .vertical
        
        container.addSubview(stackView)
        stackView.anchors.edges.pin(insets: 16, axis: .horizontal)
        stackView.anchors.edges.pin(axis: .vertical)
        
        configureProductView()
        configureScheduleView()
        configureButton()
    }
    
    func configureProductView() {
        stackView.addArrangedSubview(spacer(32))
        stackView.addArrangedSubview(productView)
        stackView.addArrangedSubview(spacer(14))
    }
    
    func configureScheduleView() {
        scheduleView.backgroundColor = .palePeach
        scheduleView.layer.cornerRadius = 10
        
        stackView.addArrangedSubview(scheduleView)
        stackView.addArrangedSubview(spacer(15))
    }
    
    func configureButton() {
        button.indicator = MaterialLoadingIndicatorSimple(radius: 10, color: .white)
        button.layer.cornerRadius = 25
        button.setBackgroundImage(UIImage.LuckyDraw.giftBoxEnabledButtonBackground, for: .normal)
        button.setBackgroundImage(UIImage.LuckyDraw.giftBoxDisabledButtonBackground, for: .disabled)
        button.addTarget(self, action: #selector(didTapButton), for: .touchUpInside)
        
        button.borderWidth = 4
        button.font = .roboto(.bold, size: 15)
        button.clipsToBounds = true

        stackView.addArrangedSubview(button)
        button.anchors.height.equal(50)
        
        stackView.addArrangedSubview(spacer(20))
    }
}
