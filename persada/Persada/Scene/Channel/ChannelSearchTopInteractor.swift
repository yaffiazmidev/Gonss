//
//  ChannelSearchTopInteractor.swift
//  Persada
//
//  Created by NOOR on 24/06/20.
//  Copyright (c) 2020 Muhammad Noor. All rights reserved.


import Foundation
import Combine

typealias ChannelSearchTopInteractable = ChannelSearchTopBusinessLogic & ChannelSearchTopDataStore

protocol ChannelSearchTopBusinessLogic {
	
	func doRequest(_ request: ChannelSearchTopModel.Request)
	func setPage(_ data: Int)
}

protocol ChannelSearchTopDataStore {
	var dataSource: ChannelSearchTopModel.DataSource { get set }
	var page: Int { get set }
}

final class ChannelSearchTopInteractor: Interactable, ChannelSearchTopDataStore {
	
	var page: Int = 0
	var cancellables = Set<AnyCancellable>()
    var topAccountCancellables = Set<AnyCancellable>()
	private let network = ChannelNetworkModel()
	
	var dataSource: ChannelSearchTopModel.DataSource
	var presenter: ChannelSearchTopPresentationLogic
	
	init(viewController: ChannelSearchTopDisplayLogic?, dataSource: ChannelSearchTopModel.DataSource) {
		self.dataSource = dataSource
		self.presenter = ChannelSearchTopPresenter(viewController)
	}
}


// MARK: - ChannelSearchTopBusinessLogic
extension ChannelSearchTopInteractor: ChannelSearchTopBusinessLogic {

	func setPage(_ data: Int) {
		page = data
	}
	
	func doRequest(_ request: ChannelSearchTopModel.Request) {
        
        DispatchQueue.global(qos: .userInitiated).async {
            
            switch request {
            
            case .searchAccount:
                self.searchAccount()
                
            case .searchFeed:
                self.searchFeed()
            
            }
        }
	}
}


// MARK: - Private Zone
private extension ChannelSearchTopInteractor {
	
	func searchFeed() {
        let service = DIContainer.shared.apiDataTransferService
        
        let endpoint = Endpoint<FeedArray?>(
            path: "search/top",
            method: .get,
            headerParamaters: ["Authorization" : "Bearer \(getToken() ?? "")", "Content-Type":"application/json"],
            queryParameters: [
                "page" : "\(page)",
                "value" : "\(dataSource.text ?? "")",
                "size": "10",
                "sort" : "createAt,desc"
            ]
        )
        
        service.request(with: endpoint) { result in
            switch result {
            case .failure(let error):
                print(error.localizedDescription)
            case .success(let response):
                guard let response = response else {
                    self.presenter.failedSeachTop(message: "Data not found..")
                    return
                }
                
                self.presenter.presentResponse(.topFeedResponse(data: response))
                guard let feed = response.data?.content else { return }
                ChannelSearchTopSimpleCache.instance.saveFeeds(feed: feed)
            }
        }
	}
    
    func searchAccount() {
        let service = DIContainer.shared.apiDataTransferService
        
        let endpoint = Endpoint<SearchArray?>(
            path: "search/account/username",
            method: .get,
            headerParamaters: ["Authorization" : "Bearer \(getToken() ?? "")", "Content-Type":"application/json"],
            queryParameters: ["value": dataSource.text ?? ""]
        )
        
        service.request(with: endpoint) { result in
            switch result {
            case .failure(let error):
                self.presenter.failedSeachTop(message: error.localizedDescription)
            case .success(let response):
                guard let response = response, let validData = response.data else {
                    self.presenter.failedSeachTop(message: "Data not found..")
                    return
                }
                
                self.presenter.presentResponse(.topAccountResponse(data: response))
                ChannelSearchTopSimpleCache.instance.saveAccounts(account: validData)
            }
        }
    }
}
