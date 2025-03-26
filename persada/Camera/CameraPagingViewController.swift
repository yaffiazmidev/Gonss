import UIKit
import KipasKipasShared

class CameraPagingViewController: PagingViewController {
    
    private(set) lazy var mainView = CameraPagingView(
        options: options,
        collectionView: collectionView,
        pageView: pageViewController.view
    )
    
    override func loadView() {
        view = mainView
    }
    
    func hideBottomBar(_ isHidden: Bool) {
        self.mainView.stackView.isHidden = isHidden
    }
}
