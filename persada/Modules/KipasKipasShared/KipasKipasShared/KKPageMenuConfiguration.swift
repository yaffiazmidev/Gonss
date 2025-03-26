import UIKit

public enum KKPageMenuItemWidthType {
    case fixed(width: CGFloat)
    case sizeToFit(minWidth: CGFloat)
    
    public var width: CGFloat {
        switch self {
        case let .fixed(width): return width
        case let .sizeToFit(minWidth): return minWidth
        }
    }
    
    public var isFixed: Bool {
        switch self {
        case .fixed:
            return true
        default:
            return false
        }
    }
}

public enum KKPageMenuIndicatorCornerStyle {
    case none
    case semicircle
    case corner(value: CGFloat)
    
    public var corner: CGFloat {
        switch self {
        case .none, .semicircle:
            return 0
        case let .corner(value):
            return value
        }
    }
}

public enum KKPageMenuIndicatorStyle {
    case line(widthType: KKPageMenuItemWidthType, position: KKPageMenulinePosition)
    case cover(widthType: KKPageMenuItemWidthType)
    
    public var widthType: KKPageMenuItemWidthType {
        get {
            switch self {
            case let .cover(width):
                return width
            case let .line(width, _):
                return width
            }
        }
    }
}

public enum KKPageMenulinePosition {
    public typealias linePosition = (margin: CGFloat, height: CGFloat)
    case top(linePosition)
    case bottom(linePosition)
    
    public var margin: CGFloat {
        get {
            switch self {
            case let .top((m, _)):
                return m
            case let .bottom((m, _)):
                return m
            }
        }
    }
    public var height: CGFloat {
        get {
            switch self {
            case let .top((_, h)):
                return h
            case let .bottom((_, h)):
                return h
            }
        }
    }
}
