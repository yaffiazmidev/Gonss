import UIKit
import KipasKipasShared

final class KKReportHeaderView: UICollectionReusableView {
    
    static var identifier: String {
        return String(describing: KKReportHeaderView.self)
    }
    
    private(set) var questionLabel = UILabel()
    
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
private extension KKReportHeaderView {
    func configureUI() {
        backgroundColor = .white
        
        configureQuestionLabel()
    }
    
    func configureQuestionLabel() {
        questionLabel.textColor = .black
        questionLabel.numberOfLines = 2
        questionLabel.font = .airbnb(.bold, size: 16)
        questionLabel.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(questionLabel)
        NSLayoutConstraint.activate([
            questionLabel.topAnchor.constraint(equalTo: topAnchor),
            questionLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 14),
            questionLabel.bottomAnchor.constraint(equalTo: bottomAnchor),
            questionLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -14)
        ])
    }
}
