import UIKit

public final class GroupView: UIView {
    private let stackView = UIStackView()
    
    public init(views: [UIView]) {
        super.init(frame: .zero)
        configureUI()
        views.forEach(stackView.addArrangedSubview)
    }
    
    required init?(coder: NSCoder) {
        return nil
    }
    
    // MARK: UI
    private func configureUI() {
        backgroundColor = .clear
        configureStackView()
    }
    
    private func configureStackView() {
        stackView.axis = .vertical
        stackView.alignment = .center
        
        addSubview(stackView)
        stackView.anchors.edges.pin()
    }
}
