import UIKit
import KipasKipasShared

public class VerifyIdentityGuidelineController: KKBottomSheetController {
    
    public override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    public override func handleCloseAction() {
        animateHideView { [weak self] in
            guard let self = self else { return }
            self.remove()
        }
    }
    
    public override func animateDismissView() {
        animateHideView { [weak self] in
            guard let self = self else { return }
            self.remove()
        }
    }
}
