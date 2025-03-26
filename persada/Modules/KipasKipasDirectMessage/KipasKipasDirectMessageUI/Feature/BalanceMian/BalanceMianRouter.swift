import Foundation
import KipasKipasDirectMessage
import KipasKipasPaymentInAppPurchase
import UIKit
import KipasKipasNetworking
import KipasKipasShared

protocol IBalanceMianRouter {
    func navigateToCoinPurchase()
    func navigateToDiamondWithdrawal()
    func navigateToVerifyIdentity(by status: String)
    func navigateToVerifyIdentityStatus()
}

public class BalanceMianRouter: IBalanceMianRouter {
    weak var controller: BalanceMianViewController?
    let baseUrl: String
    let authToken: String
    var showListBank: ((@escaping (BankAccountItem) -> Void) -> Void)?
    var showVerifyIdentity: ((String) -> Void)?
    var showVerifyIdentityStatus: (() -> Void)?
    
    init(controller: BalanceMianViewController?, baseUrl: String, authToken: String) {
        self.controller = controller
        self.baseUrl = baseUrl
        self.authToken = authToken
    }
    
    func navigateToCoinPurchase() {
        let vc = CoinPurchaseRouter.create(baseUrl: baseUrl, authToken: authToken)
        controller?.push(vc)
    }
    
    
    func navigateToDiamondWithdrawal(){
        let vc = DiamondWithdrawalRouter.create(
//            diamond: KKCache.common.readInteger(key: .diamond) ?? 0,
            type:"DM",
            baseUrl: baseUrl,
            authToken: authToken,
            showListBank: showListBank, 
            showVerifyIdentity: showVerifyIdentity
        )
        controller?.push(vc)
//        vc.bindNavigationBar()
    }
    
    func navigateToVerifyIdentity(by status: String) {
        showVerifyIdentity?(status)
    }
    
    func navigateToVerifyIdentityStatus() {
        showVerifyIdentityStatus?()
    }
}
 

extension BalanceMianRouter {
    public static func create(
        baseUrl: String,
        authToken: String,
        showListBank: ((@escaping (BankAccountItem) -> Void) -> Void)?,
        showVerifyIdentity: ((String) -> Void)?,
        showVerifyIdentityStatus: (() -> Void)?
    ) -> BalanceMianViewController {
        let controller = BalanceMianViewController()
        let router = BalanceMianRouter(controller: controller, baseUrl: baseUrl, authToken: authToken)
        let presenter = BalanceMianPresenter(controller: controller)
        let network = DIContainer.shared.apiAUTHDTS(baseUrl: baseUrl, authToken: authToken)
        let interactor = BalanceMianInteractor(presenter: presenter, network: network)
         
        router.showListBank = showListBank
        router.showVerifyIdentity = showVerifyIdentity
        router.showVerifyIdentityStatus = showVerifyIdentityStatus
        controller.interactor = interactor
        controller.router = router
        return controller
    }
     
}
