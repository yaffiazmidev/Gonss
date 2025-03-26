import UIKit

public enum KeyboardTransitionState {
    case unset, willShow, didShow, willHide, didHide
}

public struct KeyboardState {
    public var state: KeyboardTransitionState = .unset
    public var height = 0.0
    public var isVisible = false
    public var frame: CGRect = .zero
    public var animationDuration = 0.0
    
    private let frameEnd = UIResponder.keyboardFrameEndUserInfoKey
    private let animEnd = UIResponder.keyboardAnimationDurationUserInfoKey
    
    public init(with note: Notification) {
        switch note.name {
        case UIResponder.keyboardWillShowNotification:
            state = .willShow
            let keyboardEndFrame = note.userInfo?[frameEnd] as! CGRect
            height = Double(keyboardEndFrame.size.height)
            
            let animationDurationValue = note.userInfo?[animEnd] as! NSNumber
            animationDuration = animationDurationValue.doubleValue
            break
        case UIResponder.keyboardDidShowNotification:
            state = .didShow
            isVisible = true
            
            let keyboardEndFrame = note.userInfo?[frameEnd] as! CGRect
            height = Double(keyboardEndFrame.size.height)
            break
        case UIResponder.keyboardWillHideNotification:
            state = .willHide
            let animationDurationValue = note.userInfo?[animEnd] as! NSNumber
            animationDuration = animationDurationValue.doubleValue
            break
        case UIResponder.keyboardDidHideNotification:
            state = .didHide
            break
        default:
            break
        }
    }
}
