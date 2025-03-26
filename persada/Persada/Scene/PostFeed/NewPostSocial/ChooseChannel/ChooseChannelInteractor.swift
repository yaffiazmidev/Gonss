//
//  ChooseChannelInteractor.swift
//  Persada
//
//  Created by movan on 03/07/20.
//  Copyright (c) 2020 Muhammad Noor. All rights reserved.
//

import Foundation
import Combine

typealias ChooseChannelInteractable = ChooseChannelBusinessLogic & ChooseChannelDataStore

protocol ChooseChannelBusinessLogic {
	
	func doRequest(_ request: ChooseChannelModel.Request)
}

protocol ChooseChannelDataStore {
	var dataSource: ChooseChannelModel.DataSource { get }
}

final class ChooseChannelInteractor: Interactable, ChooseChannelDataStore {
	
	var dataSource: ChooseChannelModel.DataSource
	private let network = ChannelNetworkModel()
	private var presenter: ChooseChannelPresentationLogic
	private var subscriptions = Set<AnyCancellable>()
	
	init(viewController: ChooseChannelDisplayLogic?, dataSource: ChooseChannelModel.DataSource) {
		self.dataSource = dataSource
		self.presenter = ChooseChannelPresenter(viewController)
	}
}


// MARK: - ChooseChannelBusinessLogic
extension ChooseChannelInteractor: ChooseChannelBusinessLogic {

	func doRequest(_ request: ChooseChannelModel.Request) {
		DispatchQueue.main.async {
			
			switch request {
				
			case .fetchChannel(let text, let page):
				self.fetchChannel(text, page)
			}
		}
	}
}

// MARK: - Private Zone
private extension ChooseChannelInteractor {
	
	func fetchChannel(_ text: String,_ page: Int) {

		network.fetchChannels(.channels(text: text, page: page)).sink { (completion) in
			switch completion {
			case .failure(let error): print(error.localizedDescription)
			case .finished: break
			}
		} receiveValue: { [weak self] (model) in
			guard let self = self else { return }
			
			self.presenter.presentResponse(.channels(results: model))
		}.store(in: &subscriptions)
	}
}
