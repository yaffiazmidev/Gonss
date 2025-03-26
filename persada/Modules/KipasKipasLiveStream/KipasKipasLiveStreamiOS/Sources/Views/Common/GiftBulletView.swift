import UIKit
import KipasKipasShared
import KipasKipasTRTC

public final class GiftBulletView: UIView {
    var privateData: GiftData?
    var newPrivateData: GiftData?
    private let containerView = UIView()
    private let userImageView = UIImageView()
    private let symbolLabel = UILabel()
    private let numLabel = UILabel()
    
    private let horizontalStack = UIStackView()
    
    private let labelStack = UIStackView()
    private let usernameLabel = UILabel()
    private let descriptionLabel = UILabel()
    
    private let giftIconView = UIImageView()
    
    private var isAnimationPlaying = false
    private var onAnimationFinished: ((Bool) -> Void)?
    
    private lazy var gradientLayer = {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [
            UIColor(red: 0.188, green: 0.198, blue: 0.244, alpha: 1).cgColor,
            UIColor(red: 0.192, green: 0.2, blue: 0.239, alpha: 0.06).cgColor
        ]
        gradientLayer.locations = [0, 1]
        gradientLayer.startPoint = CGPoint(x: 0.425, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 0.65, y: 0.5)
        gradientLayer.bounds = containerView.bounds.insetBy(dx: -1.0*containerView.bounds.size.width, dy: -0.5*containerView.bounds.size.height)
        gradientLayer.position = containerView.center
        gradientLayer.masksToBounds = true
        
        return gradientLayer
    }()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
    }
    
    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        return nil
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        userImageView.layer.cornerRadius = userImageView.bounds.height / 2
        giftIconView.layer.cornerRadius = userImageView.bounds.height / 2
        configureContainerGradientLayer()
    }
    
    // MARK: API
    func playAnimation(finished: @escaping (Bool) -> Void) {
        if !isAnimationPlaying {
            isAnimationPlaying = true
            onAnimationFinished = finished
            if(privateData?.comboGift == 1){
                beginAnimation()
            }else{
                beginNumAnimation()
            }
            
        }
    }
    
    func beginNumAnimation() {
        giftIconView.alpha = 0
        symbolLabel.layer.removeAllAnimations()
        numLabel.layer.removeAllAnimations()
        giftIconView.layer.removeAllAnimations()
        layer.removeAllAnimations()
        layoutIfNeeded()
        giftIconView.alpha = 1
        self.anchors.leading.pin(inset: 20)
        
        let scale = CAKeyframeAnimation(keyPath: "transform.scale")
        scale.values = [1.6,1]
        scale.fillMode = .forwards
        scale.isRemovedOnCompletion = false
        scale.duration = 0.25
        scale.delegate = self
        symbolLabel.layer.add(scale, forKey: "tui_anim_begin.scale") 
        numLabel.layer.add(scale, forKey: "tui_anim_begin.scale")
    }
    
    private func beginAnimation() {
        layoutIfNeeded()
        
        let contentAnimation = CAKeyframeAnimation(keyPath: "position.x")
        contentAnimation.values = [-self.frame.size.width * 0.5, self.frame.size.width * 0.5 + 40, self.frame.size.width * 0.5 + 20]
        contentAnimation.duration = 0.25
        contentAnimation.delegate = self
        contentAnimation.fillMode = .forwards
        contentAnimation.isRemovedOnCompletion = false
        
        let opacity = CAKeyframeAnimation(keyPath: "opacity")
        opacity.values = [0.6,1]
        opacity.calculationMode = .linear
        opacity.fillMode = .forwards
        opacity.isRemovedOnCompletion = false
        opacity.duration = 0.1
        
        layer.add(contentAnimation, forKey: "tui_anim_begin.x")
        layer.add(opacity, forKey: "tui_anim_begin.opacity")
    }
    
    func stopAnimation() {
        giftIconView.alpha = 0
        symbolLabel.layer.removeAllAnimations()
        numLabel.layer.removeAllAnimations()
        giftIconView.layer.removeAllAnimations()
        layer.removeAllAnimations()
        alpha = 0
//        onAnimationFinished?(false)
        onAnimationFinished?(true)
    }
    
    func giftIconEnterAnim() {
        layoutIfNeeded()
     
        let contentAnimation = CAKeyframeAnimation(keyPath: "position.x")
        contentAnimation.values = [frame.size.width * 0.2, frame.size.width - giftIconView.mm_w * 2]
        contentAnimation.duration = 0.25
        contentAnimation.delegate = self
        contentAnimation.fillMode = .forwards
        contentAnimation.isRemovedOnCompletion = false
        
        
        let opacity = CAKeyframeAnimation(keyPath: "opacity")
        opacity.values = [0.6,1]
        opacity.calculationMode = .linear
        opacity.fillMode = .forwards
        opacity.isRemovedOnCompletion = false
        opacity.duration = 0.1
        
        giftIconView.layer.add(contentAnimation, forKey:"tui_anim_begin.x")
        giftIconView.layer.add(opacity, forKey: "tui_anim_begin.opacity")
    }
    
    func dismissAnimation() {
//        let contentAnimation = CAKeyframeAnimation(keyPath: "position.y")
//        contentAnimation.values = [self.frame.origin.y, self.frame.origin.y - self.frame.size.height * 1.5]
//        contentAnimation.duration = 0.25
//        contentAnimation.delegate = self
//        contentAnimation.fillMode = .forwards
//        contentAnimation.isRemovedOnCompletion = false
        
        let opacity = CAKeyframeAnimation(keyPath: "opacity")
        opacity.values = [1,0]
        opacity.duration = 0.25
        opacity.calculationMode = .linear
        opacity.fillMode = .forwards
        opacity.isRemovedOnCompletion = false
        
        let animationGroup:CAAnimationGroup! = CAAnimationGroup()
        animationGroup.animations = [opacity]
        animationGroup.fillMode = .forwards
        animationGroup.isRemovedOnCompletion = false
        animationGroup.delegate = self
        
        layer.add(animationGroup, forKey:"tui_anim_begin.y")
    }
    
    func configure(with data: GiftData) {
        privateData = data
        userImageView.setImage(with: data.extInfo.avatarUrl, placeholder: .defaultProfileImage)
        usernameLabel.text = data.extInfo.userName
        descriptionLabel.text = data.message
        giftIconView.setImage(with: data.imageUrl)
        numLabel.text = "\(data.comboGift)"
    }
}

extension GiftBulletView: CAAnimationDelegate {
    public func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        if layer.animation(forKey: "tui_anim_begin.x") == anim {
            if flag {
                giftIconEnterAnim()
            }
        } else if giftIconView.layer.animation(forKey: "tui_anim_begin.x") == anim {
            DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                self.dismissAnimation()
            }
        } else if layer.animation(forKey: "tui_anim_begin.y") == anim {
            layer.removeAllAnimations()
            giftIconView.layer.removeAllAnimations()
            
            if flag {
                alpha = 0
                onAnimationFinished?(true)
            }
        }else if( symbolLabel.layer.animation(forKey: "tui_anim_begin.scale") == anim ) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                self.dismissAnimation()
            }
        }
    }
}

private extension GiftBulletView {
    func configureUI() {
        configureContainerView()
        configureUserImageView()
        configureHorizontalStack()
    }
    
    func configureContainerView() {
        containerView.clipsToBounds = true
        
        addSubview(containerView)
        containerView.anchors.edges.pin()
    }
    
    func configureContainerGradientLayer() {
        gradientLayer.removeFromSuperlayer()
        
        containerView.layer.cornerRadius = containerView.bounds.height * 0.5
        containerView.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    func configureUserImageView() {
        userImageView.clipsToBounds = true
        userImageView.contentMode = .scaleAspectFill
        
        addSubview(userImageView)
        userImageView.anchors.leading.pin(inset: 4)
        userImageView.anchors.centerY.align()
        userImageView.anchors.edges.pin(insets: 4, axis: .vertical)
        userImageView.anchors.width.equal(userImageView.anchors.height)
    }
    
    
    func configureHorizontalStack() {
        horizontalStack.distribution = .equalSpacing
        horizontalStack.alignment = .center
        horizontalStack.spacing = 4
        
        addSubview(horizontalStack)
        horizontalStack.anchors.edges.pin(insets: 4, axis: .vertical)
        horizontalStack.anchors.leading.spacing(8, to: userImageView.anchors.trailing)
        horizontalStack.anchors.trailing.pin(inset: 4)
        
        configureStackLabel()
        configureGiftIconView()
        configureNumLabel()
    }
    
    func configureStackLabel() {
        labelStack.axis = .vertical
        labelStack.alignment = .leading
        labelStack.spacing = 4
        
        horizontalStack.addArrangedSubview(labelStack)
        
        configureUsernameLabel()
        configureDescriptionLabel()
    }
    
    func configureUsernameLabel() {
        usernameLabel.font = .roboto(.regular, size: 11)
        usernameLabel.textColor = .white
        
        labelStack.addArrangedSubview(usernameLabel)
        usernameLabel.anchors.width.lessThanOrEqual(150)
    }
    
    func configureDescriptionLabel() {
        descriptionLabel.font = .roboto(.light, size: 10)
        descriptionLabel.textColor = .white
        
        labelStack.addArrangedSubview(descriptionLabel)
    }
    
    func configureGiftIconView() {
        giftIconView.clipsToBounds = true
        giftIconView.alpha = 0
        
        horizontalStack.addArrangedSubview(giftIconView)
        giftIconView.anchors.height.equal(userImageView.anchors.height)
        giftIconView.anchors.width.equal(userImageView.anchors.height)
    }
    
    func configureNumLabel(){
        symbolLabel.text = "x"
        symbolLabel.backgroundColor = .clear
        symbolLabel.font = .roboto(.bold, size: 20)
        symbolLabel.textColor = .white
        addSubview(symbolLabel)
        symbolLabel.anchors.leading.equal(horizontalStack.anchors.trailing, constant: 6)
        
        
        numLabel.text = "1"
        numLabel.backgroundColor = .clear
        numLabel.font = .roboto(.bold, size: 30)
        numLabel.textColor = .white
        addSubview(numLabel)
        numLabel.anchors.leading.equal(symbolLabel.anchors.trailing, constant: 6)
        numLabel.anchors.centerY.align()
        symbolLabel.anchors.bottom.equal(numLabel.anchors.bottom,constant: -3)
    }
}
