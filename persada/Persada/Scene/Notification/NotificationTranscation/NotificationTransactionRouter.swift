//
//  NotificationTransactionRouter.swift
//  KipasKipas
//
//  Created by movan on 13/08/20.
//  Copyright (c) 2020 Muhammad Noor. All rights reserved.
//

import UIKit
import KipasKipasDirectMessage
import KipasKipasDirectMessageUI

final class NotificationTransactionRouter: Routeable {
	
	private weak var viewController: UIViewController?
	
	init(_ viewController: UIViewController?) {
		self.viewController = viewController
	}
}



// MARK: - Private Zone
extension NotificationTransactionRouter {
    
    func navigateToCoinPurchaseDetail(item: NotificationTransaction) {
        let historyDetail = item.currency.map({ RemoteCurrencyHistoryDetailData(invoiceNumber: $0.noInvoice, accountNumber: $0.bankAccount, storeName: "-", totalAmount: $0.price, id: nil, conversionPerUnit: nil, bankFee: $0.bankFee, recipient: "-", accountName: nil, createAt: $0.modifyAt, qty: $0.qty, currencyType: $0.currencyType, bankName: $0.bankName, userName: nil) })
        
        let vc = CoinPurchaseDetailRouter.create(
            baseUrl: APIConstants.baseURL,
            authToken: getToken(),
            purchaseStatus: item.currency?.status == "Purchased" ? .complete : .process,
            purchaseType: .topup,
            id: "",
            historyDetail: historyDetail,
            isPresent: true
        )
        
        let nav = UINavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .overFullScreen
        viewController?.present(nav, animated: true)
    }
    
    func navigateToDiamondWithdrawalDetail(item: NotificationTransaction) {
        let historyDetail = item.currency.map({ RemoteCurrencyHistoryDetailData(invoiceNumber: $0.noInvoice, accountNumber: $0.bankAccount, storeName: $0.storeName, totalAmount: $0.totalWithdraw, id: nil, conversionPerUnit: $0.price, bankFee: $0.bankFee, recipient: nil, accountName: nil, createAt: $0.modifyAt, qty: $0.qty, currencyType: $0.currencyType, bankName: $0.bankName, userName: nil) })
        
        let vc = DiamondWithdrawalDetailRouter.create(
            baseUrl: APIConstants.baseURL,
            authToken: getToken() ?? "",
            status: item.currency?.status == "completed" ? .complete : .process,
            type: .withdrawal,
            id: "",
            historyDetail: historyDetail
        )

        vc.bindNavigationBar("", false)
        
        let nav = UINavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .overFullScreen
        viewController?.present(nav, animated: true)
    }
	
	func dismissNotificationTransactionScene() {
		viewController?.dismiss(animated: true)
	}
    
    func detailWithdrawGopay(withdrawl: Withdrawl) {
        let vc = DetailTransactionGopayController(withdraw: withdrawl)
        vc.bindNavigationBar(.get(.penarikanDana))
        viewController?.navigationController?.pushViewController(vc, animated: false)
    }
	
    func detailTransaction(_ id: String, statusTuple : (String, String, String)) {
		var dataSource = DetailTransactionModel.DataSource()
		dataSource.id = id
		dataSource.data = nil
        dataSource.statusTuple = statusTuple
		let detailController = DetailTransactionPurchaseController(mainView: DetailTransactionPurchaseView.loadViewFromNib(), dataSource: dataSource)
		
		viewController?.navigationController?.pushViewController(detailController, animated: true)
	}
    
    func detailTransaction(id: String, _ termsCondition: ProcessTermsCondition, _ title: String) {
        var dataSource = DetailTransactionModel.DataSource()
        dataSource.id = id
        dataSource.data = nil
        dataSource.termsCondition = termsCondition
        dataSource.title = title
        if title == .get(.detailTransaction) && termsCondition.title == "" {
            let controller = DetailTransactionPurchaseController(mainView: DetailTransactionPurchaseView.loadViewFromNib(), dataSource: dataSource)
            self.viewController?.navigationController?.push(controller)
        } else {
            let detailController = DetailTransactionSalesController(mainView: DetailTransactionSalesView(), dataSource: dataSource)
            
            self.viewController?.navigationController?.pushViewController(detailController, animated: true)
        }
    }
    
    func detailTransactionWithWeightAdjustment(_ id: String) {
        let vc = NotificationPenyesuaianHargaViewController(id: id)
        vc.bindNavigationBar(.get(.penyesuaianHarga))
        viewController?.navigationController?.pushViewController(vc, animated: true)
    }
	
	func statusTransaction() {
		let controller = StatusTransactionController()
		viewController?.navigationController?.pushViewController(controller, animated: true)
	}
    
    func bannedProduct(_ id: String) {
        let controller = NotificationBannedController.init(mainView: NotificationBannedView.loadViewFromNib(), id: id)
        controller.bindNavigationBar(String.get(.bannedProduct))
        viewController?.navigationController?.pushViewController(controller, animated: true)
    }
    
    func toDetail( accoundId: String?, productId: String?){
        let detailController = ProductDetailFactory.createProductDetailController(dataSource: Product(accountId: accoundId, id: productId))
        detailController.hidesBottomBarWhenPushed = true
        viewController?.navigationController?.pushViewController(detailController, animated: true)
    }
    
    func toArchive(){
        let controller = NotificationArchiveController()
        controller.hidesBottomBarWhenPushed = true
        viewController?.navigationController?.pushViewController(controller, animated: true)
    }
    
    func toCommissionDetail(orderId: String){
        let controller = DetailTransactionCommissionFactory.createController(orderId)
        controller.hidesBottomBarWhenPushed = true
        viewController?.navigationController?.pushViewController(controller, animated: true)
    }
    
    func toDonationSuccessDetail(orderId: String, groupId: String?){
        showDonationTransactionDetail?(orderId, groupId)
    }
    
    func toDonationWaitingDetail(orderId: String, groupId: String?){
        showDonationTransactionDetail?(orderId, groupId)
    }
    
    func toDonationExpiredDetail(orderId: String){
        let controller = DetailTransactionDonationFactory.createExpiredController(orderId)
        controller.hidesBottomBarWhenPushed = true
        viewController?.navigationController?.pushViewController(controller, animated: true)
    }
}
