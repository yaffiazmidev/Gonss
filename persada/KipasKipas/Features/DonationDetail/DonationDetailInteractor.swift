//
//  DonationDetailInteractor.swift
//  KipasKipas
//
//  Created by DENAZMI on 27/02/23.
//

import UIKit
import KipasKipasDonationCart

protocol IDonationDetailInteractor: AnyObject {
    var feedId: String { get set }
    var donationId: String { get set }
    var requestPage: Int { get set }
    var totalPage: Int { get set }
    var donationAmount: Double { get set }
    
    func requestDonation()
    func requestDonationActivity()
    func checkDonationOrderExist()
    func continueDonationOrder()
    func requestDonationOrderDetail(id: String)
    func createDonationOrder()
    func requestLocalRank(requestPage: Int)
}

class DonationDetailInteractor: IDonationDetailInteractor {
    
    private let presenter: IDonationDetailPresenter
    private let network: DataTransferService
    var feedId: String = ""
    var donationId: String = ""
    var requestPage: Int = 0
    var totalPage: Int = 0
    var donationAmount: Double = 0.0
    
    let isPublic = !AUTH.isLogin()
    
    init(presenter: IDonationDetailPresenter, network: DataTransferService) {
        self.presenter = presenter
        self.network = network
    }
    
    func requestDonation() {
        let endpoint: Endpoint<RemoteDonationDetail?> = Endpoint(
            path: "\(isPublic ? "public/" : "")donations/\(donationId)",
            method: .get,
            headerParamaters: ["Authorization" : "Bearer \(getToken() ?? "")", "Content-Type":"application/json"]
        )
        
        network.request(with: endpoint) { [weak self] result in
            
            if let response = try? result.get() {
                self?.feedId = response.data?.feedId ?? ""
            }
            
            self?.presenter.presentDonation(with: result)
        }
    }
    
    func requestDonationActivity() {
        let endpoint: Endpoint<RemoteDonationDetailActivity?> = Endpoint(
            path: "\(isPublic ? "public/" : "")donations/\(donationId)/activity",
            method: .get,
            headerParamaters: ["Authorization" : "Bearer \(getToken() ?? "")", "Content-Type":"application/json"],
            queryParameters: ["page": requestPage, "size": 10]
        )
        
        network.request(with: endpoint) { [weak self] result in
            guard let self = self else { return }
            if case .success(let response) = result, let data = response?.data {
                self.totalPage = (data.totalPages ?? 0) - 1
            }
            
            self.presenter.presentDonationActivity(with: result)
        }
    }
    
    func requestDonationOrderDetail(id: String) {
        let endpoint: Endpoint<RemoteDonationOrderDetail?> = Endpoint(
            path: "orders/\(id)",
            method: .get,
            headerParamaters: ["Authorization" : "Bearer \(getToken() ?? "")", "Content-Type":"application/json"]
        )
        
        network.request(with: endpoint) { [weak self] result in
            guard let self = self else { return }
            self.presenter.presentDonationOrderDetail(with: result)
        }
    }
    
    func continueDonationOrder() {
        let endpoint: Endpoint<RemoteDonationContinueOrder?> = Endpoint(
            path: "orders/continue",
            method: .post,
            headerParamaters: ["Authorization" : "Bearer \(getToken() ?? "")", "Content-Type":"application/json"],
            bodyParamaters: [
                "type": "donation",
                "amount": donationAmount,
                "orderDetail": ["feedId": feedId]
            ]
        )
        
        network.request(with: endpoint) { [weak self] result in
            guard let self = self else { return }
            self.presenter.presentDonationContinueOrder(with: result)
        }
    }
    
    func createDonationOrder() {
        let endpoint: Endpoint<RemoteDonationCreateOrder?> = Endpoint(
            path: "orders",
            method: .post,
            headerParamaters: ["Authorization" : "Bearer \(getToken() ?? "")", "Content-Type":"application/json"],
            bodyParamaters: [
                "type": "donation",
                "amount": donationAmount,
                "orderDetail": ["feedId": feedId]
            ]
        )
        
        network.request(with: endpoint) { [weak self] result in
            guard let self = self else { return }
            self.presenter.presentDonationCreateOrder(with: result)
        }
    }
    
    func checkDonationOrderExist() {
        let endpoint: Endpoint<RemoteDonationOrderExist?> = Endpoint(
            path: "orders/me",
            method: .get,
            headerParamaters: ["Authorization" : "Bearer \(getToken() ?? "")", "Content-Type":"application/json"],
            queryParameters: ["type": "donation"]
        )
        
        network.request(with: endpoint) { [weak self] result in
            guard let self = self else { return }
            self.presenter.presentDonationOrderExist(with: result)
        }
    }
    
    func requestLocalRank(requestPage: Int) {
        let endpoint: Endpoint<RemoteDonationDetailLocalRank?> = Endpoint(
            path: "\(isPublic ? "public/" : "")donations/\(donationId)/rank",
            method: .get,
            headerParamaters: ["Authorization" : "Bearer \(getToken() ?? "")", "Content-Type":"application/json"],
            queryParameters: ["page": requestPage, "size": 10]
        )
        
        network.request(with: endpoint) { [weak self] result in
            guard let self = self else { return }
            
            self.presenter.presentLocalRank(with: result)
        }
    }
    
}
