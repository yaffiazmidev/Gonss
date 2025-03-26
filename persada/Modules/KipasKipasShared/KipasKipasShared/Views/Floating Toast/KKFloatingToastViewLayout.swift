import UIKit

open class KKFloatingToastViewLayout {

    open var leftIconSize: CGSize
    open var rightIconSize: CGSize
    open var margins: UIEdgeInsets
    
    public init(leftIconSize: CGSize, rightIconSize: CGSize, margins: UIEdgeInsets) {
        self.leftIconSize = leftIconSize
        self.rightIconSize = rightIconSize
        self.margins = margins
    }
}

public extension KKFloatingToastViewLayout {
    
    convenience init() {
        self.init(
            leftIconSize: .init(
                width: Self.defaultIconSideSize,
                height: Self.defaultIconSideSize
            ),
            rightIconSize: .init(
                width: Self.defaultIconSideSize,
                height: Self.defaultIconSideSize
            ),
            margins: .init(
                top: Self.defaultVerticallInset,
                left: Self.defaultHorizontalInset,
                bottom: Self.defaultVerticallInset,
                right: Self.defaultHorizontalInset
            )
        )
    }
    
    static var defaults = KKFloatingToastViewLayout()

    // Default values.
    private static var defaultIconSideSize: CGFloat { 12 }
    private static var defaultVerticallInset: CGFloat { 8 }
    private static var defaultHorizontalInset: CGFloat { 12 }
}
