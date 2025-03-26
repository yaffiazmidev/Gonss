import UIKit

public protocol SegmentedProgressViewDelegate: AnyObject {
    func segmentedProgressView(completedAt index: Int, isLastIndex: Bool)
}
