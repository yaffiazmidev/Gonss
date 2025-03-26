import UIKit
import KipasKipasShared

final class KKReportFooterTextView: UICollectionReusableView {
    
    weak var delegate: KKTextViewDelegate? {
        didSet {
            textView.ctvDelegate = delegate
            DispatchQueue.main.async {
                self.textView.nameTextField.becomeFirstResponder()
            }
        }
    }
    
    static var identifier: String {
        return String(describing: Self.self)
    }
    
    private let textView = KKTextView()
    
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
private extension KKReportFooterTextView {
    func configureUI() {
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.placeholder = "Tulis alasan"
        textView.nameLabel.font = .roboto(.medium, size: 12)
        textView.nameLabel.textColor = .boulder
        textView.nameTextField.backgroundColor = .alabaster
        textView.nameTextField.layer.cornerRadius = 8
        textView.nameTextField.layer.borderColor = UIColor.softPeach.cgColor
        textView.nameTextField.layer.borderWidth = 1
        textView.nameTextField.textContainerInset = .init(top: 8, left: 12, bottom: 8, right: 12)
        
        addSubview(textView)
        NSLayoutConstraint.activate([
            textView.topAnchor.constraint(equalTo: topAnchor),
            textView.leadingAnchor.constraint(equalTo: leadingAnchor),
            textView.bottomAnchor.constraint(equalTo: bottomAnchor),
            textView.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }
}
