import UIKit

open class KKPhoneNumberTextField: KKUnderlinedTextField {
    
    private let toggleAreaButton = UIButton()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        configureToggleShowAreaButton()
        configureDefaultStyle()
    }
    
    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        return nil
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        toggleAreaButton.frame = .init(x: 0, y: 0, width: 42, height: bounds.height)
        leftView?.frame = .init(x: 0, y: 0, width: 64, height: bounds.height)
    }
}

private extension KKPhoneNumberTextField {
    func configureToggleShowAreaButton() {
        toggleAreaButton.setTitle("ID +62", for: .normal)
        toggleAreaButton.setTitleColor(.black, for: .normal)
        toggleAreaButton.titleLabel?.font = .roboto(.regular, size: 16)
        toggleAreaButton.titleLabel?.textAlignment = .left
        
        toggleAreaButton.addTarget(self, action: #selector(toggleShowArea), for: .touchUpInside)
        toggleAreaButton.backgroundColor = .clear
        toggleAreaButton.contentHorizontalAlignment = .left
        
        let stackView = UIStackView()
        stackView.frame = bounds
        stackView.alignment = .center
        stackView.distribution = .fillProportionally
        stackView.addArrangedSubview(toggleAreaButton)
        
        let iconView = UIImageView()
        iconView.image = .iconCaretDown
        
        stackView.addArrangedSubview(iconView)
        stackView.addArrangedSubview(spacerWidth(8))
        iconView.anchors.width.equal(7)
        iconView.anchors.height.equal(8)
        
        let spaceLine = UIView()
        spaceLine.backgroundColor = .placeholder
        stackView.addSubview(spaceLine)
        
        spaceLine.anchors.trailing.pin()
        spaceLine.anchors.height.equal(stackView.anchors.height * 0.3)
        spaceLine.anchors.width.equal(1)
        spaceLine.anchors.centerY.align()
        
        insets.left = 8
        
        leftViewMode = .always
        leftView = stackView
    }
    
    @objc func toggleShowArea() {
        // MARK: TODO
    }
    
    private func configureDefaultStyle() {
        font = .roboto(.regular, size: 16)
        keyboardType = .numberPad
        layer.borderWidth = 0.0
        borderStyle = .none
        autocapitalizationType = .none
    }
}

