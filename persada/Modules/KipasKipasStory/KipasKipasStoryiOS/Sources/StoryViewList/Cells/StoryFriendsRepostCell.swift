import UIKit
import KipasKipasShared
import KipasKipasStory

internal class StoryFriendsRepostCell: BaseStoryRepostCell {
    
    private let bottomContainerView = UIStackView()
    private let stackLeftContent = UIStackView()
    private let sendMessageView = StorySendMessageView()
    
    private let stackRightContent = UIStackView()
    private let likeButton = KKBaseButton()
    private let shareButton = KKBaseButton()
    
    private var isLiked: Bool = false {
        didSet {
            likeButton.setImage(
                isLiked
                ? UIImage.Story.iconHeartFillRed
                : UIImage.Story.iconHeartOutlined
            )
        }
    }
        
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureBottomContainerView()
    }
    
    override func configure(with story: StoryItemViewModel, index: Int) {
        super.configure(with: story, index: index)
        isLiked = story.isLiked
    }
    
    // MARK: Privates
    @objc private func didTapLikeButton() {
        isLiked.toggle()
        onTapLike?(isLiked)
    }
    
    @objc private func didTapShareButton() {
        onTapShareButton?()
    }
}

// MARK: UI
private extension StoryFriendsRepostCell {
    func configureBottomContainerView() {
        bottomContainerView.distribution = .fillProportionally
        bottomContainerView.alignment = .center
        bottomContainerView.backgroundColor = .clear
        bottomContainerView.spacing = 16
        
        bottomView.addSubview(bottomContainerView)
        bottomContainerView.anchors.top.pin(inset: 16)
        bottomContainerView.anchors.edges.pin(insets: 16, axis: .horizontal)
        bottomContainerView.anchors.height.equal(54)
        
        configureStackLeftContent()
        configureStackRightContent()
    }
    
    // MARK: Left Content
    func configureStackLeftContent() {
        stackLeftContent.spacing = 4
        stackLeftContent.alignment = .center
        bottomContainerView.addArrangedSubview(stackLeftContent)
        
        configureSendMessageView()
    }
    
    func configureSendMessageView() {
        sendMessageView.layer.cornerRadius = 54 / 2
        sendMessageView.layer.borderWidth = 1.0
        sendMessageView.layer.borderColor = UIColor.boulder.cgColor
        
        stackLeftContent.addArrangedSubview(sendMessageView)
    }
    
    // MARK: Right Content
    func configureStackRightContent() {
        stackRightContent.spacing = 16
        stackRightContent.alignment = .center
        bottomContainerView.addArrangedSubview(stackRightContent)
        
        configureLikeButton()
        configureShareButton()
    }
    
    func configureLikeButton() {
        likeButton.setImage(UIImage.Story.iconHeartOutlined)
        likeButton.backgroundColor = .clear
        likeButton.addTarget(self, action: #selector(didTapLikeButton), for: .touchUpInside)
        
        stackRightContent.addArrangedSubview(likeButton)
    }
    
    func configureShareButton() {
        shareButton.setImage(UIImage.Story.iconShare)
        shareButton.backgroundColor = .clear
        shareButton.addTarget(self, action: #selector(didTapShareButton), for: .touchUpInside)
        
        stackRightContent.addArrangedSubview(shareButton)
    }
}
