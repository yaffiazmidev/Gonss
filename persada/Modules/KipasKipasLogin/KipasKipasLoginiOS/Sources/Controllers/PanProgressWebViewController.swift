import UIKit
import KipasKipasShared

final class PanProgressWebViewController: ProgressWebViewController, PanModalPresentable {
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    var panScrollable: UIScrollView? {
        return nil
    }
    
    var longFormHeight: PanModalHeight {
        .maxHeight
    }
    
    var shortFormHeight: PanModalHeight {
        longFormHeight
    }
    
    var allowsDragToDismiss: Bool {
        return false
    }
    
    var allowsExtendedPanScrolling: Bool {
        return false
    }
    
    var topOffset: CGFloat {
        return 0
    }
    
    func shouldRespond(to panModalGestureRecognizer: UIPanGestureRecognizer) -> Bool {
        return false
    }
}
