//
//  DonationDetailPresenter.swift
//  KipasKipas
//
//  Created by DENAZMI on 27/02/23.
//

import UIKit

protocol IDonationDetailPresenter {
    typealias CompletionResult<T> = Swift.Result<T, DataTransferError>
    
    func presentDonation(with result: CompletionResult<RemoteDonationDetail?>)
    func presentDonationActivity(with result: CompletionResult<RemoteDonationDetailActivity?>)
    func presentDonationOrderExist(with result: CompletionResult<RemoteDonationOrderExist?>)
    func presentDonationContinueOrder(with result: CompletionResult<RemoteDonationContinueOrder?>)
    func presentDonationOrderDetail(with result: CompletionResult<RemoteDonationOrderDetail?>)
    func presentDonationCreateOrder(with result: CompletionResult<RemoteDonationCreateOrder?>)
    func presentLocalRank(with result: CompletionResult<RemoteDonationDetailLocalRank?>)
}

class DonationDetailPresenter: IDonationDetailPresenter {
	weak var controller: IDonationDetailViewController?
	
	init(controller: IDonationDetailViewController) {
		self.controller = controller
	}
    
    func presentDonation(with result: CompletionResult<RemoteDonationDetail?>) {
        switch result {
        case .success(let response):
            guard let donation = response?.data else {
                controller?.displayError(message: "Data not found, please try again..")
                return
            }
            
            controller?.display(donation: donation)
        case .failure(let error):
            controller?.displayError(message: error.message)
        }
    }
    
    func presentDonationActivity(with result: CompletionResult<RemoteDonationDetailActivity?>) {
        switch result {
        case .success(let response):
            guard let data = response?.data else {
                controller?.displayError(message: "Data not found, please try again..")
                return
            }
            
            controller?.display(activitys: data.content ?? [])
        case .failure(let error):
            controller?.displayError(message: error.message)
        }
    }
    
    func presentDonationOrderExist(with result: CompletionResult<RemoteDonationOrderExist?>) {
        switch result {
        case .success(let response):
            guard let data = response?.data else {
                controller?.displayError(message: "Data not found, please try again..")
                return
            }
            
            controller?.display(orders: data)
        case .failure(let error):
            controller?.displayError(message: error.message)
        }
    }
    
    func presentDonationContinueOrder(with result: CompletionResult<RemoteDonationContinueOrder?>) {
        switch result {
        case .success(let response):
            guard let data = response?.data else {
                controller?.displayError(message: "Data not found, please try again..")
                return
            }
            
            controller?.display(continueOrders: data)
        case .failure(let error):
            controller?.displayError(message: error.message)
        }
    }
    
    func presentDonationCreateOrder(with result: CompletionResult<RemoteDonationCreateOrder?>) {
        switch result {
        case .success(let response):
            guard let data = response?.data else {
                controller?.displayError(message: "Data not found, please try again..")
                return
            }
            
            controller?.display(createOrders: data)
        case .failure(let error):
            controller?.displayError(message: error.message)
        }
    }
    
    func presentDonationOrderDetail(with result: CompletionResult<RemoteDonationOrderDetail?>) {
        switch result {
        case .success(let response):
            guard let data = response?.data else {
                controller?.displayError(message: "Data not found, please try again..")
                return
            }
            
            controller?.display(detailOrders: data)
        case .failure(let error):
            controller?.displayError(message: error.message)
        }
    }
    
    func presentLocalRank(with result: CompletionResult<RemoteDonationDetailLocalRank?>) {
        switch result {
        case .success(let response):
            guard let data = response?.data else {
                controller?.displayError(message: "Data not found, please try again..")
                return
            }
            
            var ranks = data.content?.compactMap({
                return LocalRankItem(id: $0.id ?? "", name: $0.account?.name ?? "", username: $0.account?.username ?? "", photo: $0.account?.photo ?? "", isVerified: $0.account?.isVerified ?? false, localRank: $0.localRank ?? 0, levelBadge: $0.account?.levelBadge ?? 0, urlBadge: $0.account?.urlBadge ?? "", totalDonation: $0.totalLocalDonation ?? 0, isShowBadge: $0.account?.isShowBadge ?? false)
            }) ?? []
            controller?.display(localRanks: ranks)
        case .failure(let error):
            controller?.displayError(message: error.message)
        }
    }
}
