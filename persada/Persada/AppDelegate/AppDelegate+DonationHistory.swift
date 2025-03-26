import UIKit
import KipasKipasDonationHistory
import KipasKipasDonationHistoryiOS

var showDonationHistory: ((String) -> Void)?
var showWithdrawalHistory: ((String) -> Void)?

extension AppDelegate {
    
    func configureDonationHistoryFeature() {
        KipasKipas.showDonationHistory = showDonationHistoryViewController(campaignId:)
        KipasKipas.showWithdrawalHistory = showWithdrawalHistoryViewController(campaignId:)
    }
    
    private func showDonationHistoryViewController(campaignId: String) {
        let loader = RemoteDonationHistoryLoader(baseURL: baseURL, client: authenticatedHTTPClient)
        let viewController = DonationHistoryUIComposer.composeDonationHistoryWith(
            type: "DEBIT",
            campaignId: campaignId,
            emptyMessage: "Belum ada dana terkumpul",
            loader: loader
        )
        viewController.bindNavigationBar("Riwayat Dana Terkumpul")

        window?.topNavigationController?.pushViewController(viewController, animated: true)
    }
    
    private func showWithdrawalHistoryViewController(campaignId: String) {
        let loader = RemoteDonationHistoryLoader(baseURL: baseURL, client: authenticatedHTTPClient)
        let viewController = DonationHistoryUIComposer.composeDonationHistoryWith(
            type: "CREDIT",
            campaignId: campaignId,
            emptyMessage: "Belum ada penarikan dana",
            loader: loader
        )
        viewController.bindNavigationBar("Riwayat Penarikan Dana")
       
        window?.topNavigationController?.pushViewController(viewController, animated: true)
    }
}
