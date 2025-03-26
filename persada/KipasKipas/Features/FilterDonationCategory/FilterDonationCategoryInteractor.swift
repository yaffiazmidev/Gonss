//
//  FilterDonationCategoryInteractor.swift
//  KipasKipas
//
//  Created by DENAZMI on 24/02/23.
//

import UIKit

protocol IFilterDonationCategoryInteractor: AnyObject {
    var requestPage: Int { get set }
    var totalPage: Int { get set }
    
    func requestCategory()
}

class FilterDonationCategoryInteractor: IFilterDonationCategoryInteractor {
    
    private let presenter: IFilterDonationCategoryPresenter
    private let network: DataTransferService
    var requestPage: Int = 0
    var totalPage: Int = 0
    
    init(presenter: IFilterDonationCategoryPresenter, network: DataTransferService) {
        self.presenter = presenter
        self.network = network
    }
    
    func requestCategory() {
        let isLoggedIn = getToken() != nil
        let publicPath = isLoggedIn ? "" : "public/"
        
        let endpoint: Endpoint<RemoteDonationCategory?> = Endpoint(
            path: publicPath + "donation-categories",
            method: .get,
            headerParamaters: ["Authorization" : "Bearer \(getToken() ?? "")", "Content-Type":"application/json"],
            queryParameters: [
                "page": requestPage,
                "size": 10,
            ]
        )
        
        network.request(with: endpoint) { [weak self] result in
            guard let self = self else { return }
            self.presenter.presentCategories(with: result)
        }
    }
}
