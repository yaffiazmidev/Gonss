//
//  LocalRankDonationInteractor.swift
//  KipasKipas
//
//  Created by Muhammad Noor on 26/09/23.
//  Copyright © 2023 Koanba. All rights reserved.
//

import UIKit

protocol ILocalRankDonationInteractor: AnyObject {
    func requestLocalRank(id: String, requestPage: Int)
}

class LocalRankDonationInteractor: ILocalRankDonationInteractor {
    
    private let presenter: ILocalRankDonationPresenter
    private let network: DataTransferService
    let isPublic = !AUTH.isLogin()
    
    init(presenter: ILocalRankDonationPresenter, network: DataTransferService) {
        self.presenter = presenter
        self.network = network
    }
    
    func requestLocalRank(id: String, requestPage: Int) {
        let endpoint: Endpoint<RemoteDonationDetailLocalRank?> = Endpoint(
            path: "\(isPublic ? "public/" : "")donations/\(id)/rank",
            method: .get,
            headerParamaters: ["Authorization" : "Bearer \(getToken() ?? "")", "Content-Type":"application/json"],
            queryParameters: ["page": requestPage, "size": 100]
        )
        
        network.request(with: endpoint) { [weak self] result in
            guard let self = self else { return }
            
            self.presenter.presentLocalRank(with: result)
        }
    }
}
