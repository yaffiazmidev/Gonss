import UIKit
import KipasKipasPaymentInAppPurchase
import KipasKipasDirectMessageUI
import KipasKipasShared
import KipasKipasDonationCart

var showUserBasicInfo: ((_ user: InputUserParams) -> Void)?
var showListBank: ((@escaping (BankAccountItem) -> Void) -> Void)?

extension AppDelegate {
    
    func configureUserBasicInfoFeature() {
        KipasKipas.showUserBasicInfo = showUserBasicInfo(user:)
        KipasKipas.showListBank = showListBank
    }
    
    private func showUserBasicInfo(user: InputUserParams) {
        let viewController = UserBasicInfoUIFactory.create(inputUser: user, onSuccessCreateNewUser: { userId in
            // Register here
            print("Register success")
            InAppPurchasePendingManager.instance.initialize(baseUrl: self.baseURL, userId: userId, client: self.authenticatedHTTPClient)
            DonationCartManager.instance.login(user: userId)
            KKFeedLike.instance.reset()
            self.configureCallFeature()
        })
        viewController.modalPresentationStyle = .fullScreen
        window?.topViewController?.present(viewController, animated: true)
    }
    
    private func showListBank(completion: @escaping (BankAccountItem) -> Void) {
        let vc = AccountDestinationViewController(isMyAccount: true)
        vc.bindNavigationBar(String.get(.rekeningSaya))
        vc.choice = { item in
            completion(.init(
                bankId: item.id ?? "",
                username: item.nama ?? "",
                nameBank: item.namaBank ?? "",
                noRekening: item.noRek ?? "",
                withdrawalFee: Int(item.withdrawFee ?? 0)
            ))
        }
        window?.topNavigationController?.pushViewController(vc, animated: true)
    }
}
