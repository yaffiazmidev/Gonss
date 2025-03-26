import UIKit
import KipasKipasShared
import KipasKipasLiveStream
import KipasKipasLiveStreamiOS

extension SceneDelegate {
    func makeListGiftViewController() -> UIViewController {
        let controller = ListGiftUIComposer.composeListGiftUIWith(
            selection: { _ in },
            onTapTopUpCoin: navigateToCoinPurchase
        )
        return controller
    }
}
