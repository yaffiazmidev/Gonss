import UIKit

public final class PanablePagingViewController: PagingViewController, UIGestureRecognizerDelegate {
    
    private var panGestureRecognizer: UIPanGestureRecognizer!
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        panGestureRecognizer = UIPanGestureRecognizer()
        panGestureRecognizer.delegate = self
        pageViewController.scrollView.bounces = false
        pageViewController.scrollView.addGestureRecognizer(panGestureRecognizer)
    }

    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        pageViewController.scrollView.isScrollEnabled = true
    }

    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard let panRecognizer = gestureRecognizer as? UIPanGestureRecognizer,
              panRecognizer == panGestureRecognizer else {
            return true
        }
        
        guard pageViewController.beforeViewController == nil else {
            return false
        }
        
        guard let gestureView = panRecognizer.view else {
            return true
        }
        
        let velocity = (panRecognizer.velocity(in: gestureView)).x
        
        pageViewController.scrollView.isScrollEnabled = velocity < 0
        
        return false
    }
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer == panGestureRecognizer && otherGestureRecognizer == self.pageViewController.scrollView.panGestureRecognizer {
            return true
        } else {
            return false
        }
    }
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
