import UIKit
import KipasKipasShared
import KipasKipasLuckyDraw
import KipasKipasImage

final class WinnerListCell: UICollectionViewCell {
    
    private let container = UIView()
    private let stackView = UIStackView()
    
    private let stackLeftContent = UIStackView()
    private let userImageView = UIImageView()
    private let userNameLabel = UILabel()
    
    private let prizeLabel = UILabel()
    
    var onReuse: EmptyClosure?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        return nil
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        onReuse?()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        userImageView.layer.cornerRadius = bounds.height / 2
    }
    
    // MARK: API
    func configure(with viewModel: WinnerViewModel) {
        KipasKipasImage.fetchImage(
            with: .init(url: URL(string: viewModel.photo)),
            into: userImageView
        )
        userNameLabel.text = viewModel.censoredName
        prizeLabel.text = "【\(viewModel.giftName)】"
    }
}

// MARK: UI
private extension WinnerListCell {
    func configureUI() {
        configureContainer()
        configureStackView()
    }

    func configureContainer() {
        container.isUserInteractionEnabled = true
        container.backgroundColor = .clear
        container.clipsToBounds = true
        
        addSubview(container)
        container.anchors.edges.pin()
    }
    
    func configureStackView() {
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .equalSpacing
        
        container.addSubview(stackView)
        stackView.anchors.edges.pin(insets: 20, axis: .horizontal)
        stackView.anchors.edges.pin(axis: .vertical)
        
        configureStackLeftContent()
        configurePrizeLabel()
    }
    
    // MARK: Left Content
    func configureStackLeftContent() {
        stackLeftContent.spacing = 12
        stackLeftContent.alignment = .center
        
        stackView.addArrangedSubview(stackLeftContent)
        
        configureUserImageView()
        configureUserNameLabel()
    }
    
    func configureUserImageView() {
        userImageView.backgroundColor = .systemGray4
        userImageView.contentMode = .scaleAspectFit
        userImageView.clipsToBounds = true
        
        stackLeftContent.addArrangedSubview(userImageView)
        userImageView.anchors.width.equal(26)
        userImageView.anchors.height.equal(26)
    }
    
    func configureUserNameLabel() {
        userNameLabel.font = .roboto(.medium, size: 12)
        userNameLabel.textColor = .gravel
        userNameLabel.text = .placeholderWithSpaces(count: 20)
        
        stackLeftContent.addArrangedSubview(userNameLabel)
    }
    
    func configurePrizeLabel() {
        prizeLabel.textAlignment = .right
        prizeLabel.textColor = UIColor(hexString: "#888888")
        prizeLabel.font = .roboto(.regular, size: 12)
        prizeLabel.text = .placeholderWithSpaces()
        
        stackView.addArrangedSubview(prizeLabel)
    }
}

private extension String {
    static func placeholderWithSpaces(count: Int = 30) -> String {
        return String(repeating: " ", count: count)
    }
}
