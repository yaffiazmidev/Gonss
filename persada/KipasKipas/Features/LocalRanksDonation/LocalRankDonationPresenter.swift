//
//  LocalRankDonationPresenter.swift
//  KipasKipas
//
//  Created by Muhammad Noor on 26/09/23.
//  Copyright © 2023 Koanba. All rights reserved.
//

import UIKit

protocol ILocalRankDonationPresenter {
    typealias CompletionResult<T> = Swift.Result<T, DataTransferError>
    
    func presentLocalRank(with result: CompletionResult<RemoteDonationDetailLocalRank?>)
}

class LocalRankDonationPresenter: ILocalRankDonationPresenter {
    weak var controller: ILocalRankDonationController?
    
    init(controller: ILocalRankDonationController) {
        self.controller = controller
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
