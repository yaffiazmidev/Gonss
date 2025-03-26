import UIKit
import KipasKipasShared

final class AnchorLiveEndedView: UIView {
    
    private let containerView = UIView()
    private let stackContainerView = ScrollContainerView()
    private let titleLabel = UILabel()
    
    private(set) var totalDurationLabel = UILabel()
    private(set) var totalViewersLabel = UILabel()
    private(set) var totalLikesLabel = UILabel()
    private(set) var totalDiamondLabel = UILabel()
    private(set) var backButton = KKBaseButton()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        return nil
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = 12
    }
}

// MARK: UI
private extension AnchorLiveEndedView {
    func configureUI() {
        clipsToBounds = true
        configureContainerView()
        configureStackContainerView()
    }
    
    func configureContainerView() {
        containerView.backgroundColor = .white
        addSubview(containerView)
        containerView.anchors.edges.pin()
    }
    
    func configureStackContainerView() {
        stackContainerView.isScrollEnabled = false
        stackContainerView.spacingBetween = 24
        
        containerView.addSubview(stackContainerView)
        stackContainerView.anchors.edges.pin()
        
        configureTitleLabel()
        configureDurationLabel()
        configureTotalViewersAndLikeView()
        configureTotalDiamondLabel()
        configureBackButton()
    }
    
    func configureTitleLabel() {
        titleLabel.font = .roboto(.medium, size: 15)
        titleLabel.text = "Live Stream Ended"
        titleLabel.textColor = .black
        titleLabel.textAlignment = .center
        
        let spacer = UIView()        
        stackContainerView.addArrangedSubViews(spacer)
        stackContainerView.addArrangedSubViews(titleLabel)
    }
    
    func configureDurationLabel() {
        totalDurationLabel.font = .roboto(.medium, size: 16)
        totalDurationLabel.text = "00:00:00"
        totalDurationLabel.textColor = .black
        totalDurationLabel.textAlignment = .center
        
        let stack = UIStackView()
        stack.spacing = 4
        stack.axis = .vertical
        stack.alignment = .center
        
        let title = UILabel()
        title.text = "Duration"
        title.font = .roboto(.regular, size: 10)
        title.textColor = .black
        
        stack.addArrangedSubview(totalDurationLabel)
        stack.addArrangedSubview(title)
        
        stackContainerView.addArrangedSubViews(stack)
    }
    
    private func configureTotalViewersAndLikeView() {
        totalViewersLabel.font = .roboto(.medium, size: 16)
        totalViewersLabel.text = "0"
        totalViewersLabel.textColor = .black
        totalViewersLabel.textAlignment = .center
        
        let viewerStack = UIStackView()
        viewerStack.spacing = 4
        viewerStack.axis = .vertical
        viewerStack.alignment = .center
        
        let viewerTitle = UILabel()
        viewerTitle.text = "Viewers"
        viewerTitle.font = .roboto(.regular, size: 10)
        viewerTitle.textColor = .black
        
        viewerStack.addArrangedSubview(totalViewersLabel)
        viewerStack.addArrangedSubview(viewerTitle)
        
        totalLikesLabel.font = .roboto(.medium, size: 16)
        totalLikesLabel.text = "0"
        totalLikesLabel.textColor = .black
        totalLikesLabel.textAlignment = .center
        
        let likeStack = UIStackView()
        likeStack.spacing = 4
        likeStack.axis = .vertical
        likeStack.alignment = .center
        
        let likeTitle = UILabel()
        likeTitle.text = "Likes"
        likeTitle.font = .roboto(.regular, size: 10)
        likeTitle.textColor = .black
        
        likeStack.addArrangedSubview(totalLikesLabel)
        likeStack.addArrangedSubview(likeTitle)
        
        let horizontalStack = UIStackView()
        horizontalStack.distribution = .equalCentering
        horizontalStack.alignment = .center
        
        let leftSpacer = UIView()
        let rightSpacer = UIView()
        
        horizontalStack.addArrangedSubview(leftSpacer)
        horizontalStack.addArrangedSubview(viewerStack)
        horizontalStack.addArrangedSubview(likeStack)
        horizontalStack.addArrangedSubview(rightSpacer)
        
        stackContainerView.addArrangedSubViews(horizontalStack)
    }
    
    func configureTotalDiamondLabel() {
        totalDiamondLabel.font = .roboto(.medium, size: 16)
        totalDiamondLabel.text = "0"
        totalDiamondLabel.textColor = .black
        totalDiamondLabel.textAlignment = .center
        
        let stack = UIStackView()
        stack.spacing = 4
        stack.axis = .vertical
        stack.alignment = .center
        
        let title = UILabel()
        title.text = "Diamonds"
        title.font = .roboto(.regular, size: 10)
        title.textColor = .black
        
        stack.addArrangedSubview(totalDiamondLabel)
        stack.addArrangedSubview(title)
        
        stackContainerView.addArrangedSubViews(stack)
    }
    
    func configureBackButton() {
        backButton.setTitle("Back", for: .normal)
        backButton.setTitleColor(.azure, for: .normal)
        backButton.font = .roboto(.bold, size: 14)
        backButton.addTopBorder(color: .softPeach, height: 1)
        
        backButton.anchors.height.equal(40)
        stackContainerView.addArrangedSubViews(backButton)
    }
}

private extension UIView {
    func addTopBorder(color: UIColor?, height borderHeight: CGFloat) {
        let border = UIView()
        border.backgroundColor = color
        border.frame = CGRect(x: 0, y: 0, width: frame.size.width, height: borderHeight)
        border.autoresizingMask = [.flexibleWidth, .flexibleBottomMargin]
        addSubview(border)
    }
}
