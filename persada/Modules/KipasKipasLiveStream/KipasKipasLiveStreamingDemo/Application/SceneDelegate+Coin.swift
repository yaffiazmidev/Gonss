import UIKit
import KipasKipasLiveStreamiOS
import KipasKipasDirectMessageUI

extension SceneDelegate {
    
    private func makeCoinPurchaseViewController() -> UIViewController {
        let store = tokenStore.retrieve()
        let controller = OldCoinPurchaseRouter.create(
            baseUrl: baseURL.absoluteString,
            authToken: store?.accessToken ?? ""
        )
        return controller
    }
    
    func navigateToCoinPurchase() {
        let destination = makeCoinPurchaseViewController()
        let container = CoinPurchaseContainerViewController(controller: destination)
        window?.topNavigationController?.pushViewController(container, animated: true)
    }
}
