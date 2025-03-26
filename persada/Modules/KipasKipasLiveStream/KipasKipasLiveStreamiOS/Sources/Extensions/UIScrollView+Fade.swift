import UIKit
import KipasKipasShared

internal extension UIScrollView {
    
    private struct Sizing {
        let frameHeight: CGFloat
        let contentSizeHeight: CGFloat
        let offsetY: CGFloat
    }
    
    private var sizing: Sizing {
        return .init(
            frameHeight: frame.size.height,
            contentSizeHeight: contentSize.height,
            offsetY: contentOffset.y
        )
    }
    
    var topOpacity: CGColor {
        var opacity: CGFloat {
            if sizing.frameHeight >= sizing.contentSizeHeight { 1 }
            else if sizing.offsetY <= 0 { 1 }
            else { 0 }
        }
        return UIColor.night.withAlphaComponent(opacity).cgColor
    }
    
    var bottomOpacity: CGColor {
        var opacity: CGFloat {
            if sizing.frameHeight >= sizing.contentSizeHeight { 1 }
            else if sizing.offsetY + sizing.frameHeight >= sizing.contentSizeHeight { 1 }
            else { 0 }
        }
        return UIColor.night.withAlphaComponent(opacity).cgColor
    }
}
