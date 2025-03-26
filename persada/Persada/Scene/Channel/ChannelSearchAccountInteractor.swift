//
//  ChannelSearchAccountInteractor.swift
//  KipasKipas
//
//  Created by movan on 04/08/20.
//  Copyright (c) 2020 Muhammad Noor. All rights reserved.
//

import Foundation
import Combine

typealias ChannelSearchAccountInteractable = ChannelSearchAccountBusinessLogic & ChannelSearchAccountDataStore

protocol ChannelSearchAccountBusinessLogic {
	
	func doRequest(_ request: ChannelSearchAccountModel.Request)
	func setPage(_ data: Int)
}

protocol ChannelSearchAccountDataStore {
	var dataSource: ChannelSearchAccountModel.DataSource { get set }
	var page: Int { get set }
}

final class ChannelSearchAccountInteractor: Interactable, ChannelSearchAccountDataStore {
	
	var page: Int = 0
	var cancellables = Set<AnyCancellable>()
	
	var dataSource: ChannelSearchAccountModel.DataSource
	
	private var presenter: ChannelSearchAccountPresentationLogic
	
	init(viewController: ChannelSearchAccountDisplayLogic?, dataSource: ChannelSearchAccountModel.DataSource) {
		self.dataSource = dataSource
		self.presenter = ChannelSearchAccountPresenter(viewController)
	}
}


// MARK: - ChannelSearchAccountBusinessLogic
extension ChannelSearchAccountInteractor: ChannelSearchAccountBusinessLogic {
	
	func setPage(_ data: Int) {
		page = data
	}
	
	func doRequest(_ request: ChannelSearchAccountModel.Request) {
		DispatchQueue.global(qos: .userInitiated).async {
			
			switch request {
				
			case .searchAccount:
				self.searchAccount()
			}
		}
	}
}


// MARK: - Private Zone
private extension ChannelSearchAccountInteractor {
	
	func searchAccount() {
        let service = DIContainer.shared.apiDataTransferService
        
        let endpoint = Endpoint<SearchArray?>(
            path: "search/account/username",
            method: .get, 
            headerParamaters: ["Authorization" : "Bearer \(getToken() ?? "")", "Content-Type":"application/json"],
            queryParameters: [
                "page" : "\(page)",
                "value": dataSource.text ?? ""
            ]
        )
        
        service.request(with: endpoint) { result in
            switch result {
            case .failure(let error):
                self.presenter.presentResponse(.failedSearchAccounts(message: error.localizedDescription))
            case .success(let response):
                guard let response = response, let validData = response.data else {
                    self.presenter.presentResponse(.failedSearchAccounts(message: "Data not found.."))
                    return
                }
                
                self.presenter.presentResponse(.accounts(data: response))
                ChannelSearchAccountSimpleCache.instance.saveAccounts(accounts: validData)
            }
        }
	}
}
