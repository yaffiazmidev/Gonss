import UIKit
import KipasKipasShared
import KipasKipasDonationRank
import KipasKipasDonationRankiOS
import KipasKipasDonationBadge
import KipasKipasDonationBadgeiOS

var showDonationRankAndBadge: ((_ accountId: String) -> Void)?

extension AppDelegate {
    func configureDonationRankAndBadgeFeature() {
        KipasKipas.showDonationRankAndBadge = makePagingContainerViewController(accountId:)
    }
    
    private func makeListBadgeViewController() -> ListBadgeViewController {
        let listBadgeLoader = RemoteListBadgeLoader(
            baseURL: baseURL,
            client: authenticatedHTTPClient
        )
        
        let viewController = ListBadgeUIComposer.composeListBadgeWith(loader: listBadgeLoader)
        
        return viewController
    }
    
    private func makeDonationGlobalRankViewController(accountId: String) -> DonationGlobalRankViewController {
        let loader = RemoteDonationGlobalRankLoader(
            baseURL: baseURL,
            client: authenticatedHTTPClient
        )
        let selfRankLoader = RemoteDonationGlobalSelfRankLoader(
            baseURL: baseURL,
            client: authenticatedHTTPClient
        )
        
        let viewController = DonationGlobalRankUIComposer.composeUIWith(
            accountId: accountId,
            loader: loader,
            selfRankLoader: selfRankLoader
        )
        return viewController
    }
    
    private func makePagingContainerViewController(accountId: String) {
        let pagingViewController = DonationRankBadgeContainerViewController(
            pageModels: [
                .init(
                    childController: makeListBadgeViewController(),
                    title: "Badge Donasi"
                ),
                .init(
                    childController: makeDonationGlobalRankViewController(accountId: accountId),
                    title: "Top 100 Global Ranking"
                )
            ]
        )
        pagingViewController.modalPresentationStyle = .fullScreen
        window?.topViewController?.present(pagingViewController, animated: true)
    }
}
