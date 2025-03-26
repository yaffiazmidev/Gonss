import UIKit

extension UITextView {
    public func calculateSize(isUsingGesture: Bool = false) {
        let currentTransform = transform
        transform = .identity
        
        let currentCenter = center
        let fixedWidth: CGFloat = UIScreen.main.bounds.width
        
        sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
        
        let width = isUsingGesture ? intrinsicContentSize.width * 2 : fixedWidth
        let newSize = sizeThatFits(CGSize(width: width, height: CGFloat.greatestFiniteMagnitude))
        var newFrame = frame
        
        if isUsingGesture {
            newFrame.size = CGSize(width: newSize.width, height: newSize.height)
        } else {
            newFrame.size = CGSize(width: min(newSize.width, fixedWidth), height: newSize.height)
        }
        
        frame = newFrame
        center = currentCenter
        transform = currentTransform
        
        layoutIfNeeded()
    }
}
