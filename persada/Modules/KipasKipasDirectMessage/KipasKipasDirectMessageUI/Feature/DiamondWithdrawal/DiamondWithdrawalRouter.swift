import Foundation
import KipasKipasDirectMessage
import UIKit
#warning("[BEKA] Remove this")
import KipasKipasNetworking

protocol IDiamondWithdrawalRouter {
    func presentTnCWebView()
    func navigateToHistory()
    func presentConfirmPassword()
    func navigateToBank()
    func navigateDiamondWithdrawal(value: WithdrawalDiamond)
    func navigateToVerifyIdentity(status: String)
}

public class DiamondWithdrawalRouter: IDiamondWithdrawalRouter {
    weak var controller: DiamondWithdrawalViewController?
    private let baseUrl: String
    private let authToken: String
    
    var showListBank: ((@escaping (BankAccountItem) -> Void) -> Void)?
    var showVerifyIdentity: ((String) -> Void)?
    
    init(controller: DiamondWithdrawalViewController?, baseUrl: String, authToken: String) {
        self.controller = controller
        self.baseUrl = baseUrl
        self.authToken = authToken
    }
    
    func presentTnCWebView() {
        let tncURL = "https://kipaskipas.com/syarat-dan-ketentuan-kipaskipas/#1694508382375-2b66b3de-ce45"
        let vc = KKWebViewController(url: tncURL)
        vc.bindNavBar("", isPresent: true)
        let navigate = UINavigationController.init(rootViewController: vc)
        navigate.modalPresentationStyle = .fullScreen
        controller?.present(navigate, animated: true)
    }
    
    func navigateToHistory() {
        let vc = DiamondWithdrawalHistoryRouter.create(baseUrl: baseUrl, authToken: authToken)
        controller?.push(vc)
    }
    
    func presentConfirmPassword() {
        let vc = ConfirmPasswordRouter.create(baseUrl: baseUrl, authToken: authToken) { [weak self] in
            guard let self = self else { return }
            self.controller?.withdrawalDiamond()
        }

        vc.modalPresentationStyle = .overFullScreen
        vc.modalTransitionStyle = .crossDissolve
        controller?.present(vc, animated: true)
    }
    
    func navigateToBank() {
        showListBank? { [weak self] item in
            self?.controller?.displaySelectedBank(with: item)
            self?.controller?.navigationController?.popViewController(animated: true)
        }
    }
    
    func navigateDiamondWithdrawal(value: WithdrawalDiamond) {
        guard let historyId = value.historyId else { return }
        let network = DIContainer.shared.apiAUTHDTS(baseUrl: baseUrl, authToken: authToken)
        let detailController = DiamondWithdrawalDetailRouter.create(
            network: network,
            status: .process,
            type: .withdrawal,
            id: historyId,
            historyDetail: nil
        )
       
        detailController.bindNavBar(isPresent: true) {
            self.controller?.navigationController?.popViewController(animated: true)
        }
        
        let nav = UINavigationController(rootViewController: detailController)
        nav.modalPresentationStyle = .overFullScreen
        controller?.present(nav, animated: true)
    }
    
    func navigateToVerifyIdentity(status: String) {
        showVerifyIdentity?(status)
    }
}

public extension DiamondWithdrawalRouter {
    static func create(
        type: String = "LIVE",
        baseUrl: String,
        authToken: String,
        showListBank: ((@escaping (BankAccountItem) -> Void) -> Void)?,
        showVerifyIdentity: ((String) -> Void)?
    ) -> DiamondWithdrawalViewController {
        let controller = DiamondWithdrawalViewController(type: type)
        let router = DiamondWithdrawalRouter(controller: controller, baseUrl: baseUrl, authToken: authToken)
        let presenter = DiamondWithdrawalPresenter(controller: controller)
        let network: DataTransferService = DIContainer.shared.apiAUTHDTS(baseUrl: baseUrl, authToken: authToken)
        let interactor = DiamondWithdrawalInteractor(presenter: presenter, network: network)
        
        router.showListBank = showListBank
        router.showVerifyIdentity = showVerifyIdentity
        controller.router = router
        controller.interactor = interactor
        
        return controller
    }
}
