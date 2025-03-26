//
//  NotificationTransactionPresenter.swift
//  KipasKipas
//
//  Created by movan on 13/08/20.
//  Copyright (c) 2020 Muhammad Noor. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import KipasKipasDirectMessage
import KipasKipasDirectMessageUI

final class NotificationTransactionPresenter {
    
    var didSelectRowTrigger = PublishSubject<IndexPath>()
    let notificationResult = BehaviorRelay<[NotificationTransaction]>(value: [])
    let notificationSize = BehaviorRelay<String>(value: "0")
    private let disposeBag = DisposeBag()
    private let router : NotificationTransactionRouter!
    private let interactor = NotificationTransactionInteractor()
    
    var page = 0

    init(router : NotificationTransactionRouter?) {
        
        self.router = router
        
//        didSelectRowTrigger.asObservable()
//            .observeOn(MainScheduler.asyncInstance)
//            .bind(onNext: selectRow)
//            .disposed(by: disposeBag)
        
        

        
        fetchNotificationResult()
    }
    
    func fetchNotificationResult(){
        // PE-13955
        guard getToken() != nil else { return }
        
        interactor.notificationTransactionResponse(page: page, size: 20).subscribe { [weak self] (result) in
					guard let self = self else { return }
					
            if let data = result.element?.data {
                if self.page <= data.totalPages ?? 0 {
					if self.page == 0 {
						self.notificationResult.accept(data.content! )
					} else {
						self.notificationResult.accept(self.notificationResult.value + data.content! )
					}
                    
                    let totalNotifIsRead = self.notificationResult.value.filter { $0.isRead == false }.count
                    NotificationCenter.default.post(name: .notifyUpdateCounterTransaction, object: ["NotifyUpdateCounterTransaction" : Tampung(page: self.page, size: totalNotifIsRead)])
                    self.notificationSize.accept(String( totalNotifIsRead ))
                    
                    self.page += 1
                }
            }
        }.disposed(by: disposeBag)
    }
    
    func isReadNotificationTransaction(id: String) {
        interactor.isReadNotification(type: "transaction", id: id).subscribe { [weak self] (result) in
            guard let self = self else { return }

            var notifTransactionValid = self.notificationResult.value.map { item -> NotificationTransaction in
                var data = item
                if id == data.id {
                    data.isRead = true
                }
                return data
            }
            
            self.notificationResult.accept(notifTransactionValid)

        }.disposed(by: disposeBag)

    }
    
    func fetchSize(){
        notificationResult.map { (result) in
            String(result.count)
        }.bind(to: notificationSize).disposed(by: disposeBag)
    }
    
    func selectRow(indexPath: IndexPath) {
        let notificationTransaction = notificationResult.value[indexPath.row]
        let validId = notificationTransaction.id
        let id = notificationTransaction.orderID
        let type = notificationTransaction.orderType
        let status = notificationTransaction.status
        let paymentStatus = notificationTransaction.paymentStatus
        let shipmentStatus = notificationTransaction.shipmentStatus
        let isNotifWeightAdj = notificationTransaction.isNotifWeightAdj ?? false
        let isProductBanned = notificationTransaction.isProductBanned ?? false
        let accountType = notificationTransaction.accountShopType
        
        isReadNotificationTransaction(id: validId ?? "")
        
        if notificationTransaction.notifType == "currency_coin" {
            router.navigateToCoinPurchaseDetail(item: notificationTransaction)
            return
        }
        
        if notificationTransaction.notifType == "currency_diamond" {
            router.navigateToDiamondWithdrawalDetail(item: notificationTransaction)
            return
        }
        
        if isProductBanned {
            router.bannedProduct(notificationTransaction.productID ?? "")
            return
        }
        
        if notificationTransaction.notifType == "shop_out_of_stock_product"{
            router.toDetail(accoundId: notificationTransaction.account?.id, productId: notificationTransaction.productID)
            return
        }
        
        if notificationTransaction.notifType == "withdraw" {
            guard let validWithdraw = notificationTransaction.withdrawl else { return }
            router.detailWithdrawGopay(withdrawl: validWithdraw)
            return
        }
        
        if type == "product"{
            if isNotifWeightAdj {
                router.detailTransactionWithWeightAdjustment(id!)
                return
            }
            
            if accountType == "seller" {
                let titleTerms = getTitleTerms(notificationTransaction)
                router.detailTransaction(id: id ?? "", titleTerms?.terms ?? ProcessTermsCondition(title: "", subtitle: "", showPriceTerm: false), titleTerms?.title ?? "")
            } else if accountType == "buyer" {
                router.detailTransaction(id!, statusTuple: (status ?? "", paymentStatus ?? "", shipmentStatus ?? ""))
            } else if accountType == "reseller"{
                if notificationTransaction.notifType == "shop_order_complete_reseller" {
                    guard let id = notificationTransaction.orderID else { return }
                    router.toCommissionDetail(orderId: id)
                } else if notificationTransaction.notifType == "shop_product_reseller_update_archive" {
                    router.toArchive()
                } else {
                    router.toDetail(accoundId: notificationTransaction.account?.id, productId: notificationTransaction.productID)
                }
            }
        }else if type == "donation"{
            guard let id = notificationTransaction.orderID else { return }
            if notificationTransaction.notifType == "donation_unpaid" {
                router.toDonationWaitingDetail(orderId: id, groupId: notificationTransaction.groupOrderId)
            } else if notificationTransaction.notifType == "donation_paid" {
                router.toDonationSuccessDetail(orderId: id, groupId: notificationTransaction.groupOrderId)
            } else if notificationTransaction.notifType == "donation_expired" {
                router.toDonationExpiredDetail(orderId: id)
            }
        }
        
    }
    
    func routeToStatusTransaction(){
        router.statusTransaction()
    }
    
    private func getTitleTerms(_ item: NotificationTransaction) -> (terms: ProcessTermsCondition, title: String)?{
        let validId = item.id
        let id = item.orderID
        let type = item.orderType
        let status = item.status
        let paymentStatus = item.paymentStatus
        let shipmentStatus = item.shipmentStatus
        let isNotifWeightAdj = item.isNotifWeightAdj ?? false
        let isProductBanned = item.isProductBanned ?? false
        let accountType = item.accountShopType
        
        if status == "NEW" {
            return (ProcessTermsCondition(title: .get(.processNewOrderTermsContent), subtitle: .get(.processAdjustTerm), showPriceTerm: true), .get(.detailTransaction))
        }else if status == "PROCESS" {
            if paymentStatus == "PAID" {
                if shipmentStatus == "PACKAGING" {
                    return (ProcessTermsCondition(title: .get(.processNotReadyTermContent), subtitle: .get(.processAdjustTerm), showPriceTerm: true), .get(.detailCourier))
                }
                
                return (ProcessTermsCondition(), .get(.detailProcessCourier))
            }
        }else if status == "COMPLETE" {
            return (ProcessTermsCondition(title: .get(.priceTermsContent), subtitle: .get(.priceAdjustTerms), showPriceTerm: true), .get(.detailTransactionSalesDone))
        }else if status == "CANCELED" {
            return (ProcessTermsCondition(), .get(.detailTransaction))
        }
        
        return nil
    }
}
