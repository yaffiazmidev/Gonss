//
//  TransactionRouter.swift
//  KipasKipasNotificationiOS
//
//  Created by DENAZMI on 10/05/24.
//

import Foundation
import KipasKipasNotification
import KipasKipasDonationTransactionDetail

public protocol ITransactionRouter {
    func navigateToDetail(with item: NotificationTransactionItem)
}

public var showDonationItemTransaction: ((String) -> Void)?

public class TransactionRouter: ITransactionRouter {
    
    public weak var controller: TransactionController?
    private let transactionDetailLoader: NotificationTransactionDetailLoader
    private let donationOrderLoader: DonationTransactionDetailOrderLoader
    private let donationGroupLoader: DonationTransactionDetailGroupLoader
    private let handleShowUserProfile: ((String) -> Void)?
    private let handleShowCurrencyDetail: ((NotificationTransactionItemCurrency) -> Void)?
    private let handleShowWithdrawlDetail: ((NotificationWithdrawl) -> Void)?
    private let handleShowDonationGroupOrder: ((DonationTransactionDetailGroupItem?) -> Void)?
    
    init(
        transactionDetailLoader: NotificationTransactionDetailLoader,
        donationOrderLoader: DonationTransactionDetailOrderLoader,
        donationGroupLoader: DonationTransactionDetailGroupLoader,
        handleShowUserProfile: ((String) -> Void)?,
        handleShowCurrencyDetail: ((NotificationTransactionItemCurrency) -> Void)?,
        handleShowWithdrawlDetail: ((NotificationWithdrawl) -> Void)?,
        handleShowDonationGroupOrder: ((DonationTransactionDetailGroupItem?) -> Void)?
    ) {
        self.transactionDetailLoader = transactionDetailLoader
        self.donationOrderLoader = donationOrderLoader
        self.donationGroupLoader = donationGroupLoader
        self.handleShowUserProfile = handleShowUserProfile
        self.handleShowCurrencyDetail = handleShowCurrencyDetail
        self.handleShowWithdrawlDetail = handleShowWithdrawlDetail
        self.handleShowDonationGroupOrder = handleShowDonationGroupOrder
    }
    
    public func navigateToDetail(with item: NotificationTransactionItem) {
        switch item.orderType {
        case "product":
            break
            let viewModel = TransactionDetailOrderViewModel(
                loader: transactionDetailLoader,
                orderLoader: donationOrderLoader
            )
            let vc = TransactionDetailOrderController(viewModel: viewModel)
            vc.hidesBottomBarWhenPushed = true
            
            viewModel.delegate = vc
            viewModel.transactionId = item.id
            viewModel.orderId = item.orderID
            
            controller?.push(vc)
        case "donation":
            let viewModel = TransactionDetailDonationViewModel(
                loader: transactionDetailLoader,
                orderLoader: donationOrderLoader,
                groupLoader: donationGroupLoader
            )
            let vc = TransactionDetailDonationController(viewModel: viewModel)
            vc.hidesBottomBarWhenPushed = true
            
            viewModel.delegate = vc
            viewModel.transactionId = item.id
            viewModel.orderId = item.orderID
            viewModel.groupOrderId = item.groupOrderId ?? ""
            
            vc.handleShowUserProfile = handleShowUserProfile
            vc.handleShowDonationGroupOrder = handleShowDonationGroupOrder
            
            controller?.push(vc)
            
        case "donation_item":
            showDonationItemTransaction?(item.orderID)
            
        default:
            switch item.notifType {
            case "currency_coin", "currency_diamond":
                handleShowCurrencyDetail?(item.currency)
            case "withdraw":
                handleShowWithdrawlDetail?(item.withdrawl)
            default:
                break
            }
        }
    }
}
