import UIKit
import KipasKipasShared

protocol DonationItemDetailButtonViewDelegate: AnyObject {
    func didTapDonateButton()
    func didStepperValueChange(value: Int)
}

final class DonationItemDetailButtonView: UIView {
    
    weak var delegate: DonationItemDetailButtonViewDelegate?
    
    private let stackView = UIStackView()
    private let stepperView = StepperView(viewData: .init(
        color: .watermelon,
        minimum: 1,
        maximum: 10000,
        stepValue: 1
    ))
    
    private let donateButton = KKLoadingButton()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        return nil
    }
    
    func resetStepper() {
        stepperView.reset()
    }
    
    @objc private func didTapDonateButton() {
        delegate?.didTapDonateButton()
    }
    
    @objc private func didStepperValueChange() {
        delegate?.didStepperValueChange(value: Int(stepperView.value))
    }
}

private extension DonationItemDetailButtonView {
    func configureUI() {
        backgroundColor = .white
        
        configureStackView()
        configureStepView()
        configureDonateButton()
    }
    
    func configureStackView() {
        stackView.spacing = 20
        stackView.distribution = .fillProportionally
        
        addSubview(stackView)
        stackView.anchors.top.pin(inset: 12)
        stackView.anchors.edges.pin(insets: 12, axis: .horizontal)
        stackView.anchors.bottom.pin(inset: 14)
    }
    
    func configureStepView() {
        stepperView.addTarget(self, action: #selector(didStepperValueChange), for: .valueChanged)
        
        stackView.addArrangedSubview(stepperView)
        stepperView.anchors.width.equal(135)
    }
    
    func configureDonateButton() {
        donateButton.indicatorPosition = .right
        donateButton.indicator = MaterialLoadingIndicatorSimple(radius: 10)
        donateButton.setBackgroundColor(.watermelon, for: .normal)
        donateButton.indicator.color = .white
        donateButton.titleLabel?.font = .roboto(.bold, size: 14)
        donateButton.setTitle("Donasi Sekarang", for: .normal)
        donateButton.setTitleColor(.white, for: .normal)
        donateButton.layer.cornerRadius = 8
        donateButton.clipsToBounds = true
        donateButton.addTarget(self, action: #selector(didTapDonateButton), for: .touchUpInside)
        
        stackView.addArrangedSubview(donateButton)
    }
}
