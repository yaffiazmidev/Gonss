import UIKit

public protocol SegmentedProgressViewDataSource: AnyObject {
    var numberOfSegments: Int { get }
    var segmentDuration: TimeInterval? { get }
    var paddingBetweenSegments: CGFloat { get }
    var trackColor: UIColor { get }
    var progressColor: UIColor { get }
    var roundCornerType: SegmentCornerType { get }
}

public extension SegmentedProgressViewDataSource {
    var paddingBetweenSegments: CGFloat {
        3
    }
    
    var trackColor: UIColor {
        .ashGrey
    }
    
    var progressColor: UIColor {
        .white
    }
    
    var roundCornerType: SegmentCornerType {
        .roundCornerSegments(cornerRadius: 2)
    }
}
