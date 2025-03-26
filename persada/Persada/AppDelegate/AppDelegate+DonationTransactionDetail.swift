import UIKit
import Combine
import KipasKipasNetworking
import KipasKipasNetworkingUtils
import KipasKipasShared
import KipasKipasDonationTransactionDetailiOS
import KipasKipasDonationTransactionDetail

var showDonationTransactionDetail: ((_ orderId: String, _ groupId: String?) -> ())?

extension AppDelegate {
    
    func configureDonationTransacationDetailFeature() {
        KipasKipas.showDonationTransactionDetail = navigateToDonationTransacationDetail
    }
    
    private func makeDonationTransactionDetailController(orderId: String, groupId: String? = nil) -> UIViewController {
        let orderLoader: DonationTransactionDetailOrderLoader = RemoteDonationTransactionDetailOrderLoader(baseURL: baseURL, client: authenticatedHTTPClient)
        let groupLoader: DonationTransactionDetailGroupLoader = RemoteDonationTransactionDetailGroupLoader(baseURL: baseURL, client: authenticatedHTTPClient)
        let controller = DonationTransactionDetailController(orderId: orderId, groupId: groupId, events: DonationTransactionDetailController.Events(
            onTapPayNow: { id in
                guard let orderId = id else {
                    return
                }
                
                let controller = DetailTransactionDonationFactory.createWaitingController(orderId)
                controller.hidesBottomBarWhenPushed = true
                self.pushOnce(controller)
            }, onTapDonateAgain: { (orderId, feedId) in
                guard let validOrderId = orderId, let validFeedId = feedId else {
                    return
                }
                
                let controller = DonationDetailViewController(donationId: validOrderId, feedId: validFeedId)
                controller.hidesBottomBarWhenPushed = true
                self.pushOnce(controller)
            }))
        
        controller.orderLoader = MainQueueDispatchDecorator(decoratee: orderLoader)
        controller.groupLoader = MainQueueDispatchDecorator(decoratee: groupLoader)
        
        return controller
    }
    
    
    public func navigateToDonationTransacationDetail(orderId: String, groupId: String? = nil) {
        let destination = makeDonationTransactionDetailController(orderId: orderId, groupId: groupId)
        destination.hidesBottomBarWhenPushed = true
        destination.overrideUserInterfaceStyle = .light
        destination.bindNavigationBar("Detail Transaksi")
        pushOnce(destination)
    }
}


extension MainQueueDispatchDecorator: DonationTransactionDetailOrderLoader where T == DonationTransactionDetailOrderLoader {
    public func load(request: DonationTransactionDetailOrderRequest, completion: @escaping (DonationTransactionDetailOrderLoader.DonationTransactionDetailResult) -> Void) {
        decoratee.load(request: request) { [weak self] result in
            self?.dispatch { completion(result) }
        }
    }
}

extension MainQueueDispatchDecorator: DonationTransactionDetailGroupLoader where T == DonationTransactionDetailGroupLoader {
    public func load(request: DonationTransactionDetailGroupRequest, completion: @escaping (DonationTransactionDetailGroupLoader.GroupResult) -> Void) {
        decoratee.load(request: request) { [weak self] result in
            self?.dispatch { completion(result) }
        }
    }
}
