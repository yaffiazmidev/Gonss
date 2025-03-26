import UIKit

public enum KKFloatingIconPreset {
    case heartAndArrow
    case arrow
}

public extension KKFloatingToastViewLayout {
    convenience init(for preset: KKFloatingIconPreset) {
        switch preset {
        case .heartAndArrow:
            self.init()
            leftIconSize = .init(width: 24, height: 28)
            rightIconSize = .init(width: 16, height: 16)
        case .arrow:
            self.init()
            rightIconSize = .init(width: 16, height: 16)
        }
    }
}
