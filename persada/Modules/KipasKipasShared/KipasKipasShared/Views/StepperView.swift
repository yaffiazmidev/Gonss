import UIKit

public final class StepperView: UIControl {
    
    private lazy var plusButton = stepperButton(
        color: viewData.color,
        image: UIImage(systemName: "plus"),
        value: 1
    )
    
    private lazy var minusButton = stepperButton(
        color: viewData.color,
        image: UIImage(systemName: "minus"),
        value: -1
    )
    
    private lazy var counterLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = .gravel
        label.font = .roboto(.medium, size: 14)
        return label
    }()
    
    private lazy var container: UIStackView = {
        let stack = UIStackView()
        return stack
    }()
    
    private(set) public var value: Double = 0
    private let viewData: ViewData
    
    public init(viewData: ViewData) {
        self.viewData = viewData
        
        super.init(frame: .zero)
        setup()
    }
    
    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        return nil
    }
    
    func setValue(_ newValue: Double) {
        updateValue(min(viewData.maximum, max(viewData.minimum, newValue)))
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        plusButton.anchors.height.equal(bounds.height)
        plusButton.anchors.width.equal(bounds.height)
        
        minusButton.anchors.height.equal(bounds.height)
        minusButton.anchors.width.equal(bounds.height)
    }
    
    private func setup() {
        setValue(viewData.defaultValue)
        
        backgroundColor = .white
        
        addSubview(container)
        container.anchors.edges.pin()
        
        [minusButton, counterLabel, plusButton].forEach(container.addArrangedSubview)
    }
    
    private func didPressedStepper(value: Double) {
        updateValue(value * viewData.stepValue)
    }
    
    private func updateValue(_ newValue: Double) {
        guard (viewData.minimum...viewData.maximum) ~= (value + newValue) else {
            return
        }
        value += newValue
        counterLabel.text = String(format: "%.0f", value)
        sendActions(for: .valueChanged)
    }
    
    public func reset() {
        value = viewData.defaultValue
        counterLabel.text = String(format: "%.0f", value)
        sendActions(for: .valueChanged)
    }
    
    private func stepperButton(color: UIColor, image: UIImage?, value: Int) -> UIButton {
        let button = KKLoadingButton(icon: image?.withTintColor(color), iconPosition: .none)
        button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        button.tag = value
        button.backgroundColor = .alabaster
        button.layer.cornerRadius = 4
        button.imageView?.contentMode = .scaleAspectFit
        return button
    }
    
    @objc private func buttonTapped(_ sender: UIButton) {
        didPressedStepper(value: Double(sender.tag))
    }
}

extension StepperView {
    public struct ViewData {
        public let color: UIColor
        public let minimum: Double
        public let maximum: Double
        public let stepValue: Double
        public let defaultValue: Double
        
        public init(
            color: UIColor,
            minimum: Double,
            maximum: Double,
            stepValue: Double,
            defaultValue: Double = 1.0
        ) {
            self.color = color
            self.minimum = minimum
            self.maximum = maximum
            self.stepValue = stepValue
            self.defaultValue = defaultValue
        }
    }
}
