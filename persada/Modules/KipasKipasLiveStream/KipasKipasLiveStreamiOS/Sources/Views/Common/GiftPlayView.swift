import UIKit
import Lottie
import KipasKipasTRTC
import KipasKipasShared

public final class GiftPlayView: UIView {
    
    private var likeCompletion: (() -> Void)?
    
    private lazy var likeDispatcher = {
        return TimedSequence<(() -> Void)?>(interval: 5) { completion in
            completion?()
        }
    }()
    
    private lazy var giftQueue = {
        return SimpleQueue<GiftData>(maxQueue: 3) { [weak self] data in
            if let data {
                self?.playGiftAnimation(data)
            }
        }
    }()
    
    var onTapLikeAnywhere: (() -> Void)?
    var onReceiveGift: ((GiftData, Bool) -> Void)?
    var onInsufficientBalance: (() -> Void)?
    var onGiftError: (() -> Void)?
    
    private lazy var lottieQueue = {
        return SimpleQueue<GiftData>(maxQueue: 1) { [weak self] data in
            if let data,
               let lottieURL = data.lottieUrl {
                self?.playLottieAnimation(URL(string: lottieURL))
            }
        }
    }()
    
    private var constraintDict: [GiftBulletView: NSLayoutConstraint] = [:]
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        isUserInteractionEnabled = true
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapLikeAnywhere(gesture:)))
        tap.numberOfTapsRequired = 2
        addGestureRecognizer(tap)
    }
   
    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        return nil
    }
    
    @objc private func didTapLikeAnywhere(gesture: UITapGestureRecognizer) {
        guard let onTapLikeAnywhere else { return }
        
        let haptic = UIImpactFeedbackGenerator(style: .medium)
        let location = gesture.location(in: self)
        let animatedView = FaveButton(
            frame: .init(
                x: location.x,
                y: location.y,
                width: 45,
                height: 45
            ),
            faveIconNormal: .iconHeart
        )
        animatedView.delegate = self
        animatedView.normalColor = UIColor(red: 226/255, green: 38/255,  blue: 77/255,  alpha: 1)
        
        addSubview(animatedView)
        
        animatedView.setSelected(selected: true, animated: true)
        animateLikeAnywhere(animatedView, startPoint: location)
        
        haptic.impactOccurred()
        
        onTapLikeAnywhere()
    }
    
    private func animateLikeAnywhere(_ animatedView: UIView, startPoint: CGPoint) {
        
        let path = UIBezierPath()
        path.move(to: animatedView.center)
        
        let controlPoint1 = CGPoint(x: 20, y: startPoint.y < 100 ? 200 : startPoint.y)
        let endPoint = CGPoint(x: 20, y: 10)
        
        path.addQuadCurve(to: endPoint, controlPoint: controlPoint1)
        
        let positionAnimation = CAKeyframeAnimation(keyPath: "position")
        positionAnimation.path = path.cgPath
        positionAnimation.duration = 3.0
        positionAnimation.timingFunctions = [CAMediaTimingFunction(name: .easeInEaseOut)]
        positionAnimation.isRemovedOnCompletion = true
        
        // Create a CABasicAnimation for scale
        let scaleAnimation = CABasicAnimation(keyPath: "transform.scale")
        scaleAnimation.fromValue = 1.0
        scaleAnimation.toValue = 0.1
        scaleAnimation.duration = 3.0
        scaleAnimation.isRemovedOnCompletion = true
        
        // Create a CABasicAnimation for opacity
        let opacityAnimation = CABasicAnimation(keyPath: "opacity")
        opacityAnimation.fromValue = 1.0
        opacityAnimation.toValue = 0.0
        opacityAnimation.duration = 3.0
        opacityAnimation.isRemovedOnCompletion = true
        
        // Group the animations
        let animationGroup = CAAnimationGroup()
        animationGroup.animations = [positionAnimation, scaleAnimation, opacityAnimation]
        animationGroup.duration = 3
        animationGroup.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        animationGroup.isRemovedOnCompletion = true
        
        // Apply the animation to the view
        animatedView.layer.add(animationGroup, forKey: "pathAnimation")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5, execute: {
            animatedView.layer.removeAllAnimations()
            animatedView.removeFromSuperview()
        })
    }
    
    private func playLikeAnimation() {
        let startFrame = CGRect(
            x: (frame.size.width * 5) / 6,
            y: frame.size.height-safeAreaBottom-10-44,
            width: 30,
            height: 30
        )
        
        let likeImageView = UIImageView(frame: startFrame)
        likeImageView.image = .iconReactionLike
        likeImageView.alpha = 0
        
        addSubview(likeImageView)
        likeImageView.layer.add(likeAnimation(startFrame), forKey: nil)
         
        likeCompletion = { [likeImageView] in
            likeImageView.removeFromSuperview()
        }
        
        likeDispatcher.append(likeCompletion)
        
        DispatchQueue.main.asyncAfter(deadline: .now()+3, execute: {
            likeImageView.removeFromSuperview()
        })
    }
    
    private func playGiftAnimation(_ data: GiftData) {
        var beginY = frame.size.height*0.5
        // 0 60 120
        var firstExist = false , secondExist = false
        for v in subviews.reversed() {
            if let view = v as? GiftBulletView, let top = constraintDict[view] {
                
                if top.constant == beginY {
                    firstExist = true
                }else if top.constant == beginY - 60{
                    secondExist = true
                }
            }
        }
        if firstExist {
            beginY = frame.size.height * 0.5 - 60
        }
        if firstExist && secondExist {
            beginY = frame.size.height * 0.5 - 120
        }
        
        
        let bulletView = GiftBulletView() 
        addSubview(bulletView)
        bulletView.anchors.width.greaterThanOrEqual(176)
        bulletView.anchors.height.equal(50)
        
        let y = bulletView.anchors.top.pin(inset: beginY)
        
        bulletView.configure(with: data)
        bulletView.playAnimation { [weak self] isFinished in
            if isFinished {
                bulletView.removeFromSuperview()
                self?.constraintDict[bulletView] = nil
                self?.giftQueue.dequeue()
            }
        }
        
        constraintDict[bulletView] = y
    }
    
    private func playLottieAnimation(_ url: URL?) {
        guard let url else {
            lottieQueue.dequeue()
            return
        }
        
        var completion: ((Error?) -> Void)?
        
        let animationView = LottieAnimationView(url: url, closure: { completion?($0) })
        animationView.frame = .init(x: 0, y: 0, width: bounds.width, height: bounds.height - 40)
        animationView.backgroundColor = .clear
        
        completion = { _ in play() }
        
        func play() {
            animationView.play { [weak self] _ in
                UIView.animate(withDuration: 0.2, animations: {
                    animationView.alpha = 0
                    animationView.stop()
                }, completion: { _ in
                    animationView.removeFromSuperview()
                    self?.lottieQueue.dequeue()
                })
            }
        }
        
        play()
        addSubview(animationView)
        sendSubviewToBack(animationView)
    }
    
    
    private func likeAnimation(_ startFrame: CGRect) -> CAAnimation {
        // Opacity
        let opacityAnimation = CABasicAnimation(keyPath: "opacity")
        opacityAnimation.fromValue = 1.0
        opacityAnimation.toValue = 0
        opacityAnimation.isRemovedOnCompletion = false
        opacityAnimation.beginTime = 0
        opacityAnimation.duration = 3.0
        
        // Scale
        let scaleAnimation = CABasicAnimation(keyPath: "transform.scale")
        scaleAnimation.fromValue = 0
        scaleAnimation.toValue = 1.0
        scaleAnimation.isRemovedOnCompletion = false
        scaleAnimation.fillMode = .forwards
        scaleAnimation.duration = 0.5
        
        // Position
        let positionAnimation = CAKeyframeAnimation(keyPath: "position")
        positionAnimation.beginTime = 0.5
        positionAnimation.duration = 2.5
        positionAnimation.fillMode = .forwards
        positionAnimation.calculationMode = .cubicPaced
        positionAnimation.path = likeAnimationPositionPath(startFrame).cgPath
        
        // Group
        let animationGroup = CAAnimationGroup()
        animationGroup.animations = [opacityAnimation, scaleAnimation, positionAnimation]
        animationGroup.duration = 3.0
        return animationGroup
    }
    
    private func likeAnimationPositionPath(_ frame: CGRect) -> UIBezierPath! {
        let path = UIBezierPath()
        
        let point0 = CGPoint(x: frame.origin.x + frame.size.width/2, y: frame.origin.y + frame.size.height/2)
        let point1 = CGPoint(x: point0.x - remainder(by: 30) + 30.0, y: frame.origin.y - remainder(by: 60))
        let point2 = CGPoint(x: point0.x - remainder(by: 15) + 15, y: frame.origin.y - remainder(by: 60) - 30)
        let pointOffset3 = UIScreen.main.bounds.width * 0.1
        let pointOffset4 = UIScreen.main.bounds.width * 0.2
        let point4 = CGPoint(x: point0.x - remainder(by: pointOffset4) + pointOffset4, y: remainder(by: 30) + 240)
        let point3 = CGPoint(x: point0.x - remainder(by: pointOffset3) + pointOffset3, y: (point4.y + point2.y)/2 + remainder(by: 30) - 30)
        path.move(to: point0)
        path.addQuadCurve(to: point2, controlPoint:point1)
        path.addQuadCurve(to: point4, controlPoint:point3)
        
        return path
    }
    
    private func remainder(by value: CGFloat) -> CGFloat {
        let random = CGFloat(arc4random())
        return random.truncatingRemainder(dividingBy: value)
    }
}

extension GiftPlayView: LiveRoomGiftServiceDelegate {
    public func onReceiveMessage(_ data: Data?, selfId: String) {
        guard let data = data else { return }
        
        if let _ = GiftPlayView.decode(
            LiveRoomLike<LikeData>.self,
            from: data
        ) {
            playLikeAnimation()
        }
          
        if var gift = GiftPlayView.decode(
            LiveRoomGift<GiftData>.self,
            from: data
        ) {
            
            let userId = gift.data.extInfo.userId
                  
            if gift.isGiftFromAdministrator && gift.isStatusSuccess {
                gift.data.comboGift = gift.comboGift 
                gift.data.totalComboGift = gift.totalComboGift
                
                judgeReptGift(gift)
                onReceiveGift?(gift.data, userId == selfId)
                
            } else if gift.isInsufficientBalance && userId == selfId {
                onInsufficientBalance?()
                
            } else {
                if userId == selfId {
                    onGiftError?()
                }
            }
        }
    }
    
    
    func judgeReptGift(_ gift : LiveRoomGift<GiftData>){
        var repeated = false
        for v in subviews.reversed() {
            if let view = v as? GiftBulletView {
                if  view.alpha == 1,
                    gift.data.comboGift > 1,
                    gift.data.comboGift > view.privateData?.comboGift ?? 1,
                    view.privateData?.userId == gift.data.extInfo.userId ,
                    view.privateData?.giftId == gift.data.giftId {
                    repeated = true
                    view.configure(with: gift.data)
                    view.beginNumAnimation()
                    break
                }
            }
        }
        
        if !repeated {
            var queuesRept = false
            giftQueue.queues =  giftQueue.queues.map { queueGift in
                            if gift.data.giftId == queueGift.giftId ,
                               gift.data.userId == queueGift.userId ,
                               gift.data.comboGift > queueGift.comboGift,
                               gift.data.totalComboGift > queueGift.totalComboGift {
                                queuesRept = true
                                return gift.data
                            }
                            return queueGift
                    }
            if !queuesRept {
                giftQueue.enqueue(gift.data)
                lottieQueue.enqueue(gift.data)
            }
            
        }
    }
     
    
    private static func decode<T: Decodable>(_ response: T.Type, from data: Data) -> T? { 
        return try? JSONDecoder().decode(response, from: data)
    }
}

extension GiftPlayView: FaveButtonDelegate {
    public func faveButton(_ faveButton: FaveButton, didSelected selected: Bool) {}
    
    public func faveButtonDotColors(_ faveButton: FaveButton) -> [DotColors]? {
        let colors = [
            DotColors(first: color(0x7DC2F4), second: color(0xE2264D)),
            DotColors(first: color(0xF8CC61), second: color(0x9BDFBA)),
            DotColors(first: color(0xAF90F4), second: color(0x90D1F9)),
            DotColors(first: color(0xE9A966), second: color(0xF8C852)),
            DotColors(first: color(0xF68FA7), second: color(0xF6A2B8))
        ]
        return colors
    }
}

fileprivate func color(_ rgbColor: Int) -> UIColor{
    return UIColor(
        red:   CGFloat((rgbColor & 0xFF0000) >> 16) / 255.0,
        green: CGFloat((rgbColor & 0x00FF00) >> 8 ) / 255.0,
        blue:  CGFloat((rgbColor & 0x0000FF) >> 0 ) / 255.0,
        alpha: CGFloat(1.0)
    )
}
