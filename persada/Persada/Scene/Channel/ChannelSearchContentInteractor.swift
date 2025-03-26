//
//  ChannelSearchContentInteractor.swift
//  KipasKipas
//
//  Created by movan on 05/08/20.
//  Copyright (c) 2020 Muhammad Noor. All rights reserved.
//

import Foundation
import Combine

typealias ChannelSearchContentInteractable = ChannelSearchContentBusinessLogic & ChannelSearchContentDataStore

protocol ChannelSearchContentBusinessLogic {
	
	func doRequest(_ request: ChannelSearchContentModel.Request)
}

protocol ChannelSearchContentDataStore {
	var dataSource: ChannelSearchContentModel.DataSource { get set }
}

final class ChannelSearchContentInteractor: Interactable, ChannelSearchContentDataStore {
	
	var dataSource: ChannelSearchContentModel.DataSource
	var subscriptions: Set<AnyCancellable> = []
	private var presenter: ChannelSearchContentPresentationLogic
    private let profileNetwork = ProfileNetworkModel()
    private let network = ChannelNetworkModel()
    private var followSubscriptions: AnyCancellable?
	
	init(viewController: ChannelSearchContentDisplayLogic?, dataSource: ChannelSearchContentModel.DataSource) {
		self.dataSource = dataSource
		self.presenter = ChannelSearchContentPresenter(viewController)
	}
}


// MARK: - ChannelSearchContentBusinessLogic
extension ChannelSearchContentInteractor: ChannelSearchContentBusinessLogic {
	
	func doRequest(_ request: ChannelSearchContentModel.Request) {
		DispatchQueue.global(qos: .userInitiated).async {
			
			switch request {
				
			case .searchChannel(let text):
				self.searchChannel(text)
            case .followChannel(let id):
                self.followChannel(id)
			}
		}
	}
}


// MARK: - Private Zone
private extension ChannelSearchContentInteractor {
	
    func searchChannel(_ value: String) {
		
		network.searchContentChannel(.searchContent(text: value))
			.sink(receiveCompletion: { (completion) in
				switch completion {
				case .failure(let error):
					let apiError = error as? ErrorMessage
					print(apiError)
				case .finished: print("Already finish search channel")
				}
			}) { [weak self] (model: ChannelsAccount) in
				guard let self = self else { return }
			
                guard let validData = model.data else { return }
                ChannelSearchContentSimpleCache.instance.saveChannels(accounts: validData)
				self.presenter.presentResponse(.channelList(data: model))
		}.store(in: &subscriptions)
	}
    
    func followChannel(_ id: String) {

        followSubscriptions = profileNetwork.followAccount(.followChannel(id: id))
            .sink(receiveCompletion: { (completion) in
                if case .failure(let error) = completion, let apiError = error as? ErrorMessage {
                    print(apiError)
                }
            }) { [weak self] (model: DefaultResponse) in
                guard let self = self else { return }
                
                self.presenter.presentResponse(.statusFollow(data: model))
            }
    }
}
