import UIKit

public final class KKAlertView: UIView {
    
    public var title: String? {
        didSet {
            titleLabel.text = title
        }
    }
    
    public var desc: String?{
        didSet {
            descriptionLabel.text = desc
        }
    }
    
    public var okButtonTitle: String? {
        didSet {
            okButton.setTitle(okButtonTitle, for: .normal)
        }
    }
    
    public var onTapOK: (() -> Void)?
    public var onTapCancel: (() -> Void)?
    
    private let containerView = UIView()
    private let stackContainerView = ScrollContainerView()
    private let titleLabel = UILabel()
    private let descriptionLabel = UILabel()
    
    private let stackButton = UIStackView()
    private let cancelButton = KKBaseButton()
    private let okButton = KKBaseButton()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
        #if DEBUG
        UIFont.loadCustomFonts
        #endif
    }
    
    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        return nil
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = 8
    }
}

// MARK: UI
private extension KKAlertView {
    func configureUI() {
        clipsToBounds = true
                
        configureContainerView()
        configureStackContainerView()
    }
    
    func configureContainerView() {
        addSubview(containerView)
        containerView.anchors.edges.pin()
    }
    
    func configureStackContainerView() {
        stackContainerView.isScrollEnabled = false
        stackContainerView.spacingBetween = 8
        
        containerView.addSubview(stackContainerView)
        stackContainerView.anchors.edges.pin(axis: .vertical)
        stackContainerView.anchors.edges.pin(insets: 16, axis: .horizontal)
        
        configureTitleLabel()
        configureDescriptionLabel()
        configureStackButton()
    }
    
    func configureTitleLabel() {
        titleLabel.font = .roboto(.bold, size: 14)
        titleLabel.textColor = .black
        
        let spacer = UIView()
        spacer.anchors.height.equal(8)
        stackContainerView.addArrangedSubViews(spacer)
        stackContainerView.addArrangedSubViews(titleLabel)
    }
    
    func configureDescriptionLabel() {
        descriptionLabel.font = .roboto(.medium, size: 12)
        descriptionLabel.textColor = .boulder
        descriptionLabel.numberOfLines = 0
        
        stackContainerView.addArrangedSubViews(descriptionLabel)
    }
    
    func configureStackButton() {
        stackButton.alignment = .trailing
        stackButton.spacing = 36
        
        let invisibleView = UIView()
        invisibleView.anchors.height.equal(24)
        
        stackContainerView.addArrangedSubViews(invisibleView)
        stackContainerView.addArrangedSubViews(stackButton)
        stackButton.anchors.height.equal(32)
        
        cancelButton.setTitle("Batal", for: .normal)
        cancelButton.setTitleColor(.boulder, for: .normal)
        cancelButton.font = .roboto(.medium, size: 12)
        cancelButton.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        
        okButton.font = .roboto(.medium, size: 12)
        okButton.setTitleColor(.warning, for: .normal)
        okButton.addTarget(self, action: #selector(okButtonTapped), for: .touchUpInside)
        
        let spacer = UIView()
        stackButton.addArrangedSubview(spacer)
        stackButton.addArrangedSubview(cancelButton)
        stackButton.addArrangedSubview(okButton)
    }
    
    @objc func okButtonTapped() {
        onTapOK?()
    }
    
    @objc func cancelButtonTapped() {
        onTapCancel?()
    }
}

#if DEBUG
import SwiftUI

private extension KKAlertView {
    static func withFontsLoaded() -> KKAlertView {
        UIFont.loadCustomFonts
        return KKAlertView()
    }
}

@available(iOS 13, *)
struct KKAlertView_Preview: PreviewProvider {
    static var previews: some View {
        let alert = KKAlertView.withFontsLoaded()
        alert.title = "Hapus Postingan"
        alert.desc = "Postingan yang sudah dihapus tidak dapat dilihat dan dikembalikan lagi."
        alert.okButtonTitle = "Hapus"
        alert.backgroundColor = .lightGray
    
        return alert
            .showPreview()
            .frame(width: 262, height: 164, alignment: .center)
    }
}
#endif
