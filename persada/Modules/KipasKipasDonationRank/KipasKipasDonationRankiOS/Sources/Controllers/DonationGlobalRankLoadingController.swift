import UIKit
import KipasKipasDonationRank
import KipasKipasShared

protocol DonationGlobalRankLoaderControllerDelegate {
    func didRequestLoad()
}

final class DonationGlobalRankLoadingController: NSObject {
    
    private(set) lazy var view = KKProgressHUD()
    
    private let delegate: DonationGlobalRankLoaderControllerDelegate
    
    init(delegate: DonationGlobalRankLoaderControllerDelegate) {
        self.delegate = delegate
    }
    
    func load() {
        delegate.didRequestLoad()
    }
}
