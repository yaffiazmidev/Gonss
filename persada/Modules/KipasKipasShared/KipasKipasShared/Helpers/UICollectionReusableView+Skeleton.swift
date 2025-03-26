import UIKit

public protocol SkeletonDisplayableStatus {
    var isSkeletonShowing: Bool { get set }
}

public protocol SkeletonDisplayable {
    func showSkeleton(config: SkeletonConfig)
    func hideSkeleton()
}

public struct SkeletonConfig {
    public let backgroundColor: UIColor
    public let highlightColor: UIColor
    
    public init(
        backgroundColor: UIColor = UIColor.softPeach,
        highlightColor: UIColor = UIColor.alabaster
    ) {
        self.backgroundColor = backgroundColor
        self.highlightColor = highlightColor
    }
}

extension SkeletonDisplayable where Self: UIView {
    
    private var skeletonLayerName: String {
        return "skeletonLayerName"
    }
    
    private var skeletonGradientName: String {
        return "skeletonGradientName"
    }
    
    private var skeletonGroupAnimation: String {
        return "backgroundColor"
    }
    
    private func skeletonViews(in view: UIView) -> [UIView] {
        var results = [UIView]()
        for subview in view.subviews as [UIView] {
            subview.accessibilityIdentifier = "SKELETON_\(String(describing: subview))"
            
            switch subview {
            case _ where subview.isKind(of: UILabel.self):
                subview.layer.cornerRadius = 4
                
                results += [subview]
            case _ where subview.isKind(of: UIImageView.self):
                results += [subview]
            case _ where subview.isKind(of: UIButton.self):
                results += [subview]
            case _ where subview.isKind(of: AnimatedProgressView.self):
                results += [subview]
            default: results += skeletonViews(in: subview)
            }
        }
        return results
    }
    
    public func showSkeleton(config: SkeletonConfig) {
        setSkeletonStatus(isShowing: true)
        
        let skeletons = skeletonViews(in: self)
        let backgroundColor = config.backgroundColor.cgColor
        let highlightColor = config.highlightColor.cgColor
        
        let skeletonLayer = CALayer()
        skeletonLayer.backgroundColor = backgroundColor
        skeletonLayer.name = skeletonLayerName
        skeletonLayer.anchorPoint = .zero
        skeletonLayer.frame = bounds
        
        let gradients: [CAGradientLayer] = skeletons.map { _ in
            let gradientLayer = CAGradientLayer()
            gradientLayer.frame = self.bounds
            gradientLayer.startPoint = CGPoint(x: 0.0, y: 1.0)
            gradientLayer.endPoint = CGPoint(x: 1.0, y: 1.0)
            gradientLayer.colors = [backgroundColor, highlightColor, backgroundColor]
            gradientLayer.locations = [0.0, 0.5, 1.0]
            gradientLayer.name = skeletonGradientName
            return gradientLayer
        }
        
        zip(skeletons, gradients).enumerated().forEach { index, layer in
            let (skeleton, gradient) = layer
            
            skeleton.layer.mask = skeletonLayer
            skeleton.layer.addSublayer(skeletonLayer)
            skeleton.layer.addSublayer(gradient)
            skeleton.clipsToBounds = true
            
            let previous = gradients[safe: index - 1]?.animation(forKey: skeletonGroupAnimation)
            
            let group = makeAnimationGroup(previousGroup: previous)
            gradient.add(group, forKey: skeletonGroupAnimation)
        }
    }
    
    public func hideSkeleton() {
        skeletonViews(in: self).forEach {
            $0.layer.sublayers?.removeAll {
                $0.name == skeletonLayerName || $0.name == skeletonGradientName
            }
        }
        setSkeletonStatus(isShowing: false)
    }
    
    private func makeAnimationGroup(previousGroup: CAAnimation? = nil) -> CAAnimationGroup {
        let animDuration: CFTimeInterval = 1.5
        let anim1 = CABasicAnimation(keyPath: #keyPath(CAGradientLayer.backgroundColor))
        anim1.fromValue = UIColor.softPeach.cgColor
        anim1.toValue = UIColor.softPeach.cgColor
        anim1.duration = animDuration
        anim1.beginTime = 0.0
        
        let anim2 = CABasicAnimation(keyPath: #keyPath(CAGradientLayer.backgroundColor))
        anim2.fromValue = UIColor.alabaster.cgColor
        anim2.toValue = UIColor.alabaster.cgColor
        anim2.duration = animDuration
        anim2.beginTime = anim1.beginTime + anim1.duration
        
        let shimmer = CABasicAnimation(keyPath: "locations")
        shimmer.fromValue = [-1.0, -0.5, 0.0]
        shimmer.toValue = [1.0, 1.5, 2.0]
        shimmer.repeatCount = .infinity
        shimmer.duration = 1.5
        
        let group = CAAnimationGroup()
        group.animations = [anim1, anim2, shimmer]
        group.repeatCount = .greatestFiniteMagnitude // infinite
        group.duration = anim2.beginTime + anim2.duration + shimmer.duration
        group.isRemovedOnCompletion = false
        
        if let previousGroup = previousGroup {
            // Offset groups by 0.33 seconds for effect
            group.beginTime = previousGroup.beginTime + 0.33
        }
        
        return group
    }
    
    private func setSkeletonStatus(isShowing: Bool) {
        if var view = self as? SkeletonDisplayableStatus {
            view.isSkeletonShowing = isShowing
        }
    }
    
    public func setAnimatedSkeletonView(
        _ isShowing: Bool,
        config: SkeletonConfig = SkeletonConfig()
    ) {
        isShowing ? showSkeleton(config: config) : hideSkeleton()
    }
}

extension UICollectionReusableView: SkeletonDisplayable {}
extension UITableViewCell: SkeletonDisplayable {}

private extension Collection {
    subscript (safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
