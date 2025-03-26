//
//  ChannelSearchHashtagInteractor.swift
//  KipasKipas
//
//  Created by movan on 04/08/20.
//  Copyright (c) 2020 Muhammad Noor. All rights reserved.
//

import Foundation
import Combine

typealias ChannelSearchHashtagInteractable = ChannelSearchHashtagBusinessLogic & ChannelSearchHashtagDataStore

protocol ChannelSearchHashtagBusinessLogic {
	
	func doRequest(_ request: ChannelSearchHashtagModel.Request)
}

protocol ChannelSearchHashtagDataStore {
	var dataSource: ChannelSearchHashtagModel.DataSource { get set }
}

final class ChannelSearchHashtagInteractor: Interactable, ChannelSearchHashtagDataStore {
	
	var dataSource: ChannelSearchHashtagModel.DataSource
	var cancellables = Set<AnyCancellable>()
	private var presenter: ChannelSearchHashtagPresentationLogic
	
	init(viewController: ChannelSearchHashtagDisplayLogic?, dataSource: ChannelSearchHashtagModel.DataSource) {
		self.dataSource = dataSource
		self.presenter = ChannelSearchHashtagPresenter(viewController)
	}
}


// MARK: - ChannelSearchHashtagBusinessLogic
extension ChannelSearchHashtagInteractor: ChannelSearchHashtagBusinessLogic {
	
	func doRequest(_ request: ChannelSearchHashtagModel.Request) {
		DispatchQueue.global(qos: .userInitiated).async {
			
			switch request {
				
			case .searchHashtag(let text):
				self.searchHashtag(text)
			}
		}
	}
}


// MARK: - Private Zone
private extension ChannelSearchHashtagInteractor {
	
	func searchHashtag(_ text: String) {
        let service = DIContainer.shared.apiDataTransferService
        
        let endpoint = Endpoint<HashtagResult?>(
            path: "search/feed/hashtag",
            method: .get,
            headerParamaters: ["Authorization" : "Bearer \(getToken() ?? "")", "Content-Type":"application/json"],
            queryParameters: ["value": text]
        )
        
        service.request(with: endpoint) { result in
            switch result {
            case .failure(let error):
                self.presenter.presentResponse(.hashtagError(message: error.localizedDescription))
            case .success(let response):
                guard let response = response, let validData = response.data else {
                    self.presenter.presentResponse(.hashtagError(message: "Data not found.."))
                    return
                }
                
                self.presenter.presentResponse(.hashtag(data: response))
                ChannelSearchHashtagSimpleCache.instance.saveHastags(hashtag: validData)
            }
        }
	}
}
