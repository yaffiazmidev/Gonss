import Foundation
import UIKit

public struct ScaleTransformViewOptions {
    
    // MARK: Properties
    
    /// The minimum scale factor for side views
    public var minScale: CGFloat
    
    /// The maximum scale factor for side views
    public var maxScale: CGFloat
    
    /// Ratio for computing scale for each item
    /// Scale = 1 - progress * `scaleRatio`
    public var scaleRatio: CGFloat
    
    /// Ratio for the amount of translate for side views, calculates by `scalableView` size
    /// for instance, if translationRatio.x = 0.5 and scalableView.width = 100 then
    /// translateX = 50 for the right view and translateX = -50 for the left view
    public var translationRatio: CGPoint
    
    /// The minimum amount of translate for side views, calculates like `translationRatio`
    public var minTranslationRatio: CGPoint?
    
    /// The maximum amount of translate for side views, calculates like `translationRatio`
    public var maxTranslationRatio: CGPoint?
    
    /// Since it applies scale on views the spacing between views wouldn't be equal
    /// by default, if this flag is enabled it will keep spacing between items equally
    public var keepVerticalSpacingEqual: Bool
    
    /// Like `keepHorizontalSpacingEqual` but for horizontal spacing
    public var keepHorizontalSpacingEqual: Bool
                
    /// The curve function for scaling
    public var scaleCurve: TransformCurve
    
    /// The curve function for translating
    public var translationCurve: TransformCurve
    
    /// Set this flag to `false` if you don't want any shadow for `scalableView`
    public var shadowEnabled: Bool
    
    /// The shadow color that be applied on `scalableView`
    public var shadowColor: UIColor
    
    /// The shadow opacity that be applied on `scalableView`
    public var shadowOpacity: Float
    
    /// The shadow radius that be applied on `scalableView` when scale is minimum
    public var shadowRadiusMin: CGFloat
    
    /// The shadow radius that be applied on `scalableView` when scale is maximum
    public var shadowRadiusMax: CGFloat
    
    /// The shadow offset that be applied on `scalableView` when scale is minimum
    public var shadowOffsetMin: CGSize
    
    /// The shadow offset that be applied on `scalableView` when scale is maximum
    public var shadowOffsetMax: CGSize
    
    /// The shadow opacity that be applied on `scalableView` when scale is minimum
    public var shadowOpacityMin: Float
    
    /// The shadow opacity that be applied on `scalableView` when scale is maximum
    public var shadowOpacityMax: Float
    
    /// Enabling the blur effect for side views
    public var blurEffectEnabled: Bool
    
    /// The Ratio for computing blur radius, radius = progress * `burEffectRadiusRatio`
    public var blurEffectRadiusRatio: CGFloat
    
    /// Blur effect style in case you enable it
    public var blurEffectStyle: UIBlurEffect.Style
    
    /// 3D rotation based on CATransform3DMakeRotation(angle:CGFloat, x: CGFloat, y: CGFloat, z: CGFloat)
    public var rotation3d: Rotation3dOptions?
    
    /// 3D translation based on CATransform3DMakeTranslation(tx: CGFloat, ty: CGFloat, tz: CGFloat)
    public var translation3d: Translation3dOptions?
    
    
    // MARK: Lifecycle
    
    public init(
        minScale: CGFloat = 0.75,
        maxScale: CGFloat = 1,
        scaleRatio: CGFloat = 0.25,
        translationRatio: CGPoint = .init(x: 0.93, y: 0.36),
        minTranslationRatio: CGPoint? = .init(x: -5, y: -5),
        maxTranslationRatio: CGPoint? = .init(x: 5, y: 5),
        keepVerticalSpacingEqual: Bool = true,
        keepHorizontalSpacingEqual: Bool = true,
        scaleCurve: TransformCurve = .linear,
        translationCurve: TransformCurve = .linear,
        shadowEnabled: Bool = true,
        shadowColor: UIColor = .black,
        shadowOpacity: Float = 0.6,
        shadowRadiusMin: CGFloat = 2,
        shadowRadiusMax: CGFloat = 13,
        shadowOffsetMin: CGSize = .init(width: 0, height: 2),
        shadowOffsetMax: CGSize = .init(width: 0, height: 6),
        shadowOpacityMin: Float = 0.1,
        shadowOpacityMax: Float = 0.1,
        blurEffectEnabled: Bool = false,
        blurEffectRadiusRatio: CGFloat = 0.4,
        blurEffectStyle: UIBlurEffect.Style = .light,
        rotation3d: Rotation3dOptions? = nil,
        translation3d: Translation3dOptions? = nil
    ) {
        self.minScale = minScale
        self.maxScale = maxScale
        self.scaleRatio = scaleRatio
        self.translationRatio = translationRatio
        self.minTranslationRatio = minTranslationRatio
        self.maxTranslationRatio = maxTranslationRatio
        self.keepVerticalSpacingEqual = keepVerticalSpacingEqual
        self.keepHorizontalSpacingEqual = keepHorizontalSpacingEqual
        self.scaleCurve = scaleCurve
        self.translationCurve = translationCurve
        self.shadowEnabled = shadowEnabled
        self.shadowColor = shadowColor
        self.shadowOpacity = shadowOpacity
        self.shadowRadiusMin = shadowRadiusMin
        self.shadowRadiusMax = shadowRadiusMax
        self.shadowOffsetMin = shadowOffsetMin
        self.shadowOffsetMax = shadowOffsetMax
        self.shadowOpacityMin = shadowOpacityMin
        self.shadowOpacityMax = shadowOpacityMax
        self.blurEffectEnabled = blurEffectEnabled
        self.blurEffectRadiusRatio = blurEffectRadiusRatio
        self.blurEffectStyle = blurEffectStyle
        self.rotation3d = rotation3d
        self.translation3d = translation3d
    }
}

public extension ScaleTransformViewOptions {
    
    struct Rotation3dOptions {
        
        // MARK: Properties
        
        /// The angle for rotate side views
        public var angle: CGFloat
        
        /// The minimum angle for rotation
        public var minAngle: CGFloat
        
        /// The maximum angle for rotation
        public var maxAngle: CGFloat
        
        public var x: CGFloat
        
        public var y: CGFloat
        
        public var z: CGFloat
        
        /// `CATransform3D.m34`, read more: https://stackoverflow.com/questions/3881446/meaning-of-m34-of-catransform3d
        public var m34: CGFloat
        
        /// `CALayer.isDoubleSided`, read more: https://developer.apple.com/documentation/quartzcore/calayer/1410924-isdoublesided
        public var isDoubleSided: Bool = false
        

        // MARK: Lifecycle
        
        public init(angle: CGFloat, minAngle: CGFloat, maxAngle: CGFloat, x: CGFloat, y: CGFloat, z: CGFloat, m34: CGFloat) {
            self.angle = angle
            self.minAngle = minAngle
            self.maxAngle = maxAngle
            self.x = x
            self.y = y
            self.z = z
            self.m34 = m34
        }
    }
}

public extension ScaleTransformViewOptions {
    struct Translation3dOptions {

        // MARK: Properties
        
        /// The translates(x,y,z) ratios
        /// (translateX = progress * translates.x * targetView.width)
        /// (translateY = progress * translates.y * targetView.height)
        /// (translateZ = progress * translates.z * targetView.width)
        public var translateRatios: (CGFloat, CGFloat, CGFloat)
        
        /// The minimum translate ratios
        public var minTranslateRatios: (CGFloat, CGFloat, CGFloat)
        
        /// The maximum translate ratios
        public var maxTranslateRatios: (CGFloat, CGFloat, CGFloat)
        
        
        // MARK: Lifecycle
        
        public init(
            translateRatios: (CGFloat, CGFloat, CGFloat),
            minTranslateRatios: (CGFloat, CGFloat, CGFloat),
            maxTranslateRatios: (CGFloat, CGFloat, CGFloat)
        ) {
            self.translateRatios = translateRatios
            self.minTranslateRatios = minTranslateRatios
            self.maxTranslateRatios = maxTranslateRatios
        }
    }
}
