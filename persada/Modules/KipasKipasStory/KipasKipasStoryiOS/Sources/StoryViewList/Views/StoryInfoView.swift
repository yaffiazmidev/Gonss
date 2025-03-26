import UIKit
import KipasKipasShared

final class StoryInfoView: UIView {
    
    private let stackContainer = UIStackView()
    
    // MARK: Left Contents
    private let stackLeftContent = UIStackView()
    private(set) var photoView = UIImageView()
    private(set) var usernameLabel = UILabel()
    private(set) var timeLabel = UILabel()

    let usernameTapGesture = UITapGestureRecognizer()
    let photoTapGesture = UITapGestureRecognizer()
    
    private let dotView = UIView()

    // MARK: Right Contents
    private let stackRightContent = UIStackView()
        
    var onTapProfile: EmptyClosure?
    
    let storyCameraButton = KKBaseButton()
    let closeButton = KKBaseButton()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
        configureTapGesture()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        return nil
    }
    
    private func configureTapGesture() {
        photoView.addGestureRecognizer(photoTapGesture)
        usernameLabel.addGestureRecognizer(usernameTapGesture)
    }
}

// MARK: UI
private extension StoryInfoView {
    func configureUI() {
        backgroundColor = .clear
        configureStackContainer()
    }
    
    func configureStackContainer() {
        stackContainer.distribution = .equalCentering
        
        addSubview(stackContainer)
        stackContainer.anchors.edges.pin()
        
        configureStackLeftContent()
        configureStackRightContent()
    }
    
    // MARK: Left Contents
    func configureStackLeftContent() {
        stackLeftContent.alignment = .center
        stackContainer.addArrangedSubview(stackLeftContent)
        
        configurePhotoView()
        configureUsernameLabel()
        configureDotView()
        configureTimeLabel()
    }
    
    func configurePhotoView() {
        photoView.isUserInteractionEnabled = true
        photoView.backgroundColor = .grey
        photoView.clipsToBounds = true
        photoView.contentMode = .scaleAspectFill
        photoView.layer.cornerRadius = 40 / 2
        
        stackLeftContent.addArrangedSubview(photoView)
        photoView.anchors.width.equal(40)
        photoView.anchors.height.equal(40)
    }
    
    func configureUsernameLabel() {
        usernameLabel.isUserInteractionEnabled = true
        usernameLabel.font = .roboto(.bold, size: 16)
        usernameLabel.textColor = .white
        usernameLabel.text = "Winorlose"
        
        stackLeftContent.addArrangedSubview(spacerWidth(12))
        stackLeftContent.addArrangedSubview(usernameLabel)
    }
    
    func configureDotView() {
        dotView.backgroundColor = UIColor(hexString: "#D9D9D9")
        dotView.layer.cornerRadius = 2 / 2
        dotView.clipsToBounds = true
        
        stackLeftContent.addArrangedSubview(spacerWidth(4))
        stackLeftContent.addArrangedSubview(dotView)
        stackLeftContent.addArrangedSubview(spacerWidth(4))
        dotView.anchors.width.equal(2)
        dotView.anchors.height.equal(2)
    }
    
    func configureTimeLabel() {
        timeLabel.font = .roboto(.bold, size: 14)
        timeLabel.alpha = 0.5
        timeLabel.textColor = .white
        timeLabel.text = "29 menit"
        
        stackLeftContent.addArrangedSubview(timeLabel)
    }
    
    // MARK: Right Contents
    func configureStackRightContent() {
        stackRightContent.alignment = .center
        stackContainer.addArrangedSubview(stackRightContent)
        
        configureStoryCameraButton()
        configureCloseButton()
    }
    
    func configureStoryCameraButton() {
        storyCameraButton.backgroundColor = .clear
        storyCameraButton.setImage(UIImage.Story.iconStoryCamera)
        
        stackRightContent.addArrangedSubview(storyCameraButton)
        stackRightContent.addArrangedSubview(spacerWidth(20))
        storyCameraButton.anchors.width.equal(24)
        storyCameraButton.anchors.height.equal(24)
    }
    
    func configureCloseButton() {
        closeButton.backgroundColor = .clear
        closeButton.setImage(UIImage.Story.iconX)
        
        stackRightContent.addArrangedSubview(closeButton)
        closeButton.anchors.width.equal(24)
        closeButton.anchors.height.equal(24)
    }
}
