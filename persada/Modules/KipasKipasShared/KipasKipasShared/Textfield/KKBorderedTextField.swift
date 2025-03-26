import UIKit

open class KKBorderedTextField: KKBaseTextField {
    
    public override var isError: Bool {
        didSet {
            if isError {
                configureErrorAppearance()
            } else {
                configureDefaultAppearance()
            }
        }
    }
    
    public var defaultColor: UIColor = .gainsboro {
        didSet {
            configureDefaultAppearance()
        }
    }
    
    public var errorColor: UIColor = .brightRed {
        didSet {
            configureErrorAppearance()
        }
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        layer.borderWidth = 1
        layer.borderColor = defaultColor.cgColor
    }
    
    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        return nil
    }
}

private extension KKBorderedTextField {
    func configureDefaultAppearance() {
        layer.borderColor = defaultColor.cgColor
    }
    
    func configureErrorAppearance() {
        layer.borderColor = errorColor.cgColor
    }
}
