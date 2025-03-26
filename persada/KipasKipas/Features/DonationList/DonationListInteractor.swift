//
//  DonationListInteractor.swift
//  KipasKipas
//
//  Created by DENAZMI on 05/02/23.
//

import UIKit

protocol IDonationListInteractor: AnyObject {
    var requestPage: Int { get set }
    var totalPage: Int { get set }
    var totalElements: Int { get set }
    var isActive: Bool { get set }
    
    func requestDonations()
}

class DonationListInteractor: IDonationListInteractor {
    
    private let presenter: IDonationListPresenter
    private let network: DataTransferService
    var requestPage: Int = 0
    var totalPage: Int = 0
    var totalElements: Int = 0
    var isActive: Bool = true
    
    init(presenter: IDonationListPresenter, network: DataTransferService) {
        self.presenter = presenter
        self.network = network
    }
    
    func requestDonations() {
        let endpoint: Endpoint<RemoteDonation?> = Endpoint(
            path: "donations",
            method: .get,
            headerParamaters: ["Authorization" : "Bearer \(getToken() ?? "")", "Content-Type":"application/json"],
            queryParameters: [
                "page": requestPage,
                "size": 10,
                "status": isActive ? "ACTIVE" : "INACTIVE",
                "initiatorId": getIdUser(),
                "sort": "createAt,desc"
            ]
        )
        
        network.request(with: endpoint) { [weak self] result in
            guard let self = self else { return }
            if case .success(let response) = result, let data = response?.data {
                self.totalElements = data.totalElements ?? 0
                self.totalPage = (data.totalPages ?? 0) - 1
            }
            
            self.presenter.presentDonation(with: result)
        }
    }
}
