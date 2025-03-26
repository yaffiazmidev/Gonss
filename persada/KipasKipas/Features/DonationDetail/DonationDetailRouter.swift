//
//  DonationDetailRouter.swift
//  KipasKipas
//
//  Created by DENAZMI on 27/02/23.
//

import UIKit
import KipasKipasShared
import KipasKipasDonationCart

protocol IDonationDetailRouter {
    func presentAuthPopUp()
    func goToDonationHistory(campaignId: String)
    func goToWithdrawalHistory(campaignId: String)
    func goToDonationItemHistory(campaignId: String)
    func presentWithdrawalPage(amountAvailable: Double, campaignId: String)
    func presentCart()
    func presentDonateCart(data: RemoteDonationDetailData)
    func presentDonateGoods(donationId: String)
}

class DonationDetailRouter: IDonationDetailRouter {
    weak var controller: DonationDetailViewController?
    
    init(controller: DonationDetailViewController?) {
        self.controller = controller
    }
    
    func presentAuthPopUp() {
//        let popup = AuthPopUpViewController(mainView: AuthPopUpView())
//        popup.modalPresentationStyle = .overFullScreen
//        popup.modalTransitionStyle = .crossDissolve
//        popup.handleWhenNotLogin = {
//            popup.dismiss(animated: true, completion: nil)
//        }
//        controller?.present(popup, animated: true, completion: nil)
        
        showLogin?()
    }
    
    func goToDonationHistory(campaignId: String) {
        showDonationHistory?(campaignId)
    }
    
    func goToWithdrawalHistory(campaignId: String) {
        showWithdrawalHistory?(campaignId)
    }
    
    func goToDonationItemHistory(campaignId: String) {
        showDonateStuff?(campaignId, .initiator)
    }
    
    func presentWithdrawalPage(amountAvailable: Double, campaignId: String) {
        let vc = WithdrawDonationBalanceRouter.configure(
            amountAvailable: amountAvailable,
            campaignId: campaignId
        )
        vc.hidesBottomBarWhenPushed = true
        controller?.navigationController?.pushViewController(vc, animated: true)
    }
    
    func presentCart() {
        showDonationCart?()
    }
    
    func presentDonateCart(data: RemoteDonationDetailData) {
        if DonationCartManager.instance.isAdded(id: data.feedId ?? "") {
            presentCart()
        } else {
            showInputAmountDonation(from: data)
        }
    }
    
    func presentDonateGoods(donationId: String) {
        showDonateStuff?(donationId, .donor)
    }
    
    private func showFeatureInDevelopment() {
        let vc = CustomPopUpViewController(
            title: "Fitur sedang dalam proses pengembangan.",
            description: "Kami sedang menyempurnakan fitur ini, bersiaplah untuk pengalaman terbaik.",
            iconImage: .imgProgress,
            iconHeight: 99
        )
        controller?.present(vc, animated: false)
    }
}

extension DonationDetailRouter {
    func showInputAmountDonation(from data: RemoteDonationDetailData) {
        let vc = DonationInputAmountViewController()
        vc.modalPresentationStyle = .overFullScreen
        vc.handleCreateOrderDonation = { [weak self] amount in
            guard self != nil else { return }
            
            DonationCartManager.instance.add(
                DonationCart(
                    id: data.feedId ?? "",
                    title: data.title ?? "",
                    accountId: data.initiator?.id ?? "",
                    accountName: data.initiator?.name ?? "",
                    amount: amount
                )
            )
        }
        controller?.present(vc, animated: true) {
            vc.donationType = .add
        }
    }
}

extension DonationDetailRouter {
    static func configure(controller: DonationDetailViewController) {
        let router = DonationDetailRouter(controller: controller)
        let presenter = DonationDetailPresenter(controller: controller)
        let network = DIContainer.shared.defaultAPIDataTransferService
        let authNetwork = DIContainer.shared.apiDataTransferService
        let interactor = DonationDetailInteractor(presenter: presenter, network: AUTH.isLogin() ? authNetwork : network)
        controller.router = router
        controller.interactor = interactor
    }
}
