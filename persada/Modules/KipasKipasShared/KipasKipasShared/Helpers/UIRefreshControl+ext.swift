import UIKit

public extension UIRefreshControl {
    private func beginRefreshingManually(tintColor: UIColor = .white) {
        guard !isRefreshing else { return }
        self.tintColor = tintColor
        
        if let scrollView = superview as? UIScrollView {
            scrollView.setContentOffset(
                CGPoint(x: 0, y: scrollView.contentOffset.y - frame.height),
                animated: false
            )
        }
      
        beginRefreshing()
    }
    
    func setLoading(
        _ isLoading: Bool,
        tintColor: UIColor = .white,
        backgroundColor: UIColor = .clear
    ) {
        if isLoading {
            beginRefreshingManually(tintColor: tintColor)
            self.backgroundColor = backgroundColor
        } else {
            endRefreshing()
            self.backgroundColor = .clear
        }
    }
}
