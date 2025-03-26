import UIKit
import KipasKipasShared

class BaseRoomInfoToolbar: UIView {
   
    private let contentHorizontalStack = UIStackView()
    private let contentVerticalStack = UIStackView()
    
    private let subHorizontalStack = UIStackView()
    public let verifitedIcon = UIImageView()
    
    private(set) var userImageView = UIImageView()
    private(set) var ownerNameLabel = MarqueeLabel()
    
    var onClickUserImage: (() -> Void)?
    
    private(set) var trailingConstraint: NSLayoutConstraint! {
        didSet {
            trailingConstraint.isActive = true
        }
    }
    
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
        userImageView.layer.cornerRadius = userImageView.bounds.height / 2
    }
    
    private func configureUI() {
        backgroundColor = UIColor.black.withAlphaComponent(0.2)
        layer.cornerRadius = 17
        
        configureUserImageView()
        configureContentHorizontalStack()
    }
 
    private func configureUserImageView() {
        userImageView.contentMode = .scaleAspectFill
        userImageView.backgroundColor = .systemGray4
        userImageView.clipsToBounds = true
        userImageView.onTap { [weak self] in
            self?.onClickUserImage?()
        }
        
        addSubview(userImageView)
        userImageView.anchors.width.equal(anchors.height * 0.85)
        userImageView.anchors.height.equal(anchors.height * 0.85)
        userImageView.anchors.leading.pin(inset: 3)
        userImageView.anchors.centerY.align()
    }
    
    private func configureContentHorizontalStack() {
        contentHorizontalStack.spacing = 6
        contentHorizontalStack.alignment = .center
        
        addSubview(contentHorizontalStack)
        contentHorizontalStack.anchors.edges.pin(insets: 2, axis: .vertical)
        contentHorizontalStack.anchors.leading.spacing(6, to: userImageView.anchors.trailing)
        trailingConstraint = contentHorizontalStack.anchors.trailing.pin(inset: 4)
        contentHorizontalStack.anchors.centerY.align()
        
        configureContentVerticalStack()
    }
    
    private func configureContentVerticalStack() {
        contentVerticalStack.axis = .vertical
        contentVerticalStack.spacing = 3
        contentVerticalStack.alignment = .leading
        
        contentHorizontalStack.addArrangedSubview(contentVerticalStack)

        configureRoomNameLabel()
    }
    
    private func configureRoomNameLabel() {
        subHorizontalStack.spacing = 2
        subHorizontalStack.alignment = .top
        contentVerticalStack.addArrangedSubview(subHorizontalStack)
        
        ownerNameLabel.font = .roboto(.medium, size: 12)
        ownerNameLabel.textColor = .white
        ownerNameLabel.type = .continuous
        ownerNameLabel.textAlignment = .left
        ownerNameLabel.speed = .rate(15)
        ownerNameLabel.fadeLength = 15.0
        
        subHorizontalStack.addArrangedSubview(ownerNameLabel)
        
        verifitedIcon.isHidden = true
        verifitedIcon.image = .iconVerified
        verifitedIcon.anchors.width.equal(12)
        verifitedIcon.anchors.height.equal(12)
        subHorizontalStack.addArrangedSubview(verifitedIcon)
         
    }
    
    func addViewToVerticalStack(_ view: UIView, at index: Int = 0) {
        let arrangedSubviews = contentVerticalStack.arrangedSubviews
        
        if !arrangedSubviews.isEmpty {
            let insertedIndex = index > arrangedSubviews.count ? arrangedSubviews.count : index
            contentVerticalStack.insertArrangedSubview(view, at: insertedIndex)
        } else {
            contentVerticalStack.insertArrangedSubview(view, at: 0)
        }
    }
    
    func addViewToHorizontalStack(_ view: UIView) {
        contentHorizontalStack.addArrangedSubview(view)
    }
}

final class AnchorRoomInfoToolbar: BaseRoomInfoToolbar {
    
    private let contentHorizontalStack = UIStackView()
    
    private(set) var timeElapsedLabel = UILabel()
    private(set) var recordingDotView = UIView()
    private(set) var likesIcon = UIImageView()
    private(set) var likesLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        trailingConstraint.constant = -16
        configureUI()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        return nil
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        recordingDotView.layer.cornerRadius = 8 / 2
    }
    
    private func configureUI() {
        configureStack()
    }
    
    private func configureStack() {
        contentHorizontalStack.distribution = .fillProportionally
        contentHorizontalStack.alignment = .center
        contentHorizontalStack.spacing = 3
        
        addViewToVerticalStack(contentHorizontalStack, at: 1)
        
        configureOnRecordingView()
        configureTimeElapsedLabel()
        configureInvisibleView()
        configureLikesLabel()
    }
    
    private func configureOnRecordingView() {
        recordingDotView.backgroundColor = .red
        
        contentHorizontalStack.addArrangedSubview(recordingDotView)
        recordingDotView.anchors.width.equal(8)
        recordingDotView.anchors.height.equal(8)
    }
    
    private func configureTimeElapsedLabel() {
        timeElapsedLabel.font = .roboto(.regular, size: 12)
        timeElapsedLabel.textColor = .white
        
        contentHorizontalStack.addArrangedSubview(timeElapsedLabel)
    }
    
    private func configureLikesLabel() {
        likesIcon.image = .iconLove
        contentHorizontalStack.addArrangedSubview(likesIcon)
        likesIcon.anchors.width.equal(12)
        likesIcon.anchors.height.equal(12)
        
        likesLabel.font = .roboto(.regular, size: 12)
        likesLabel.textColor = .white
        likesLabel.text = "0 Likes"
        
        contentHorizontalStack.addArrangedSubview(likesLabel)
    }
    
    private func configureInvisibleView() {
        let invisibleView = UIView()
        invisibleView.backgroundColor = .clear
        invisibleView.setContentHuggingPriority(.defaultLow, for: .horizontal)
        
        contentHorizontalStack.addArrangedSubview(invisibleView)
    }
}


class AudienceRoomInfoToolbar: BaseRoomInfoToolbar {
    private let contentHorizontalStack = UIStackView()
    private(set) var likesIcon = UIImageView()
    private(set) var likesLabel = UILabel()
    private(set) var followButton = KKLoadingButton(icon: .iconPlus)
    
    private(set) var btnWConstraint: NSLayoutConstraint! {
        didSet {
            btnWConstraint.isActive = true
        }
    }
   
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureLikesLabel()
        configureFollowButton()
    }
    
    private func configureLikesLabel() {
        contentHorizontalStack.distribution = .fillProportionally
        contentHorizontalStack.alignment = .center
        contentHorizontalStack.spacing = 3
        addViewToVerticalStack(contentHorizontalStack, at: 1)
        
        likesIcon.image = .iconLove
        contentHorizontalStack.addArrangedSubview(likesIcon)
        likesIcon.anchors.width.equal(12)
        likesIcon.anchors.height.equal(12)
        
        likesLabel.text = "0 Likes"
        likesLabel.font = .roboto(.regular, size: 12)
        likesLabel.textColor = .white
        contentHorizontalStack.addArrangedSubview(likesLabel)
    }
    
    private func configureFollowButton() {
        let indicator = MaterialLoadingIndicator(color: .white)
        indicator.backgroundColor = .watermelon
        
        followButton.indicator = indicator
        followButton.font = .roboto(.medium, size: 12)
        followButton.setTitle("Follow")
        followButton.setBackgroundColor(.watermelon, for: .normal)
        followButton.setTitleColor(.white, for: .normal)
        
        followButton.layer.cornerRadius = 14
        followButton.iconInset = 5.0
        
        addViewToHorizontalStack(followButton)
        btnWConstraint = followButton.anchors.width.equal(68)
        followButton.anchors.height.equal(anchors.height * 0.80)
    }
    
    public func configureFollow(_ isFollow: Bool){
        if isFollow {
//            let indicator = MaterialLoadingIndicator(color: .white)
//            indicator.backgroundColor = .watermelon
//            followButton.indicator = indicator
            followButton.setTitle("")
            followButton.setImage(UIImage(named: ""))
            followButton.setBackgroundImage(.btnFollow, for: .disabled)
            btnWConstraint.constant = 36
            followButton.isEnabled = false
        }else{
            followButton.setTitle("Follow")
            followButton.setImage(.iconPlus)
            followButton.setBackgroundImage(UIImage(named: ""), for: .disabled)
            btnWConstraint.constant = 68
            followButton.isEnabled = true
        }
    }
}
