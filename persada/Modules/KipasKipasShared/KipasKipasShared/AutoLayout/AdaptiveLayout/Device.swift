import UIKit

public enum Device {
    case iPhoneSE
    case iPhone8
    case iPhone8Plus
    case iPhone11Pro
    case iPhone11ProMax
    case iPhone11
    case iPhone12
    
    static let baseScreenSize: Device = .iPhone11
}

extension Device: RawRepresentable {
    public typealias RawValue = CGSize
    
    public init?(rawValue: CGSize) {
        switch rawValue {
        case CGSize(width: 320, height: 568):
            self = .iPhoneSE
        case CGSize(width: 375, height: 667):
            self = .iPhone8
        case CGSize(width: 414, height: 736):
            self = .iPhone8Plus
        case CGSize(width: 375, height: 812):
            self = .iPhone11Pro
        case CGSize(width: 414, height: 896):
            self = .iPhone11ProMax
        case CGSize(width: 414, height: 896):
            self = .iPhone11
        case CGSize(width: 390, height: 844):
            self = .iPhone12
        default:
            return nil
        }
    }
    
    public var rawValue: CGSize {
        switch self {
        case .iPhoneSE:
            return CGSize(width: 320, height: 568)
        case .iPhone8:
            return CGSize(width: 375, height: 667)
        case .iPhone8Plus:
            return CGSize(width: 414, height: 736)
        case .iPhone11Pro:
            return CGSize(width: 375, height: 812)
        case .iPhone11, .iPhone11ProMax:
            return CGSize(width: 414, height: 896)
        case .iPhone12:
            return CGSize(width: 390, height: 844)
        }
    }
}
