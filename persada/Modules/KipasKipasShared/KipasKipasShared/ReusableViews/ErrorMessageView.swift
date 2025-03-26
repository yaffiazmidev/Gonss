import UIKit

/**
 User for error message below textfield
 */
public final class ErrorMessageView: UIView {
    private let errorStackView = UIStackView()
    private let errorLabel = UILabel()
    private let errorIconView = UIImageView()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        configureUI()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        return nil
    }
    
    private func configureUI() {
        configureErrorStackView()
        configureErrorIconView()
        configureErrorLabel()
    }
    
    private func configureErrorStackView() {
        errorStackView.alignment = .top
        errorStackView.spacing = 6
        
        addSubview(errorStackView)
        errorStackView.anchors.edges.pin()
    }
    
    private func configureErrorIconView() {
        errorIconView.image = .iconWarningRed?.withAlignmentRectInsets(.init(top: -2, left: 0, bottom: 0, right: 0))
        errorIconView.contentMode = .top
        
        errorStackView.addArrangedSubview(errorIconView)
    }
    
    private func configureErrorLabel() {
        errorLabel.font = .roboto(.regular, size: 14)
        errorLabel.textColor = .brightRed
        errorLabel.numberOfLines = 0
        
        errorStackView.addArrangedSubview(errorLabel)
    }
    
    // MARK: API
    public func setErrorText(_ text: String?) {
        errorLabel.text = text
        isHidden = text == nil || text?.isEmpty == true
    }
}
