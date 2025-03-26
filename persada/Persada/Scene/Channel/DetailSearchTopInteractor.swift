//
//  DetailSearchTopInteractor.swift
//  KipasKipas
//
//  Created by movan on 04/08/20.
//  Copyright (c) 2020 Muhammad Noor. All rights reserved.
//

import Foundation
import Combine

typealias DetailSearchTopInteractable = DetailSearchTopBusinessLogic & DetailSearchTopDataStore

protocol DetailSearchTopBusinessLogic {
	
	func doRequest(_ request: DetailSearchTopModel.Request)
	func setPage(_ data: Int)
}

protocol DetailSearchTopDataStore {
	var dataSource: DetailSearchTopModel.DataSource { get set }
	var page: Int { get set }
}

final class DetailSearchTopInteractor: Interactable, DetailSearchTopDataStore {
	
	var page: Int = 0
	var cancellables = Set<AnyCancellable>()
	var dataSource: DetailSearchTopModel.DataSource
	private var presenter: DetailSearchTopPresentationLogic
	private let network = ChannelNetworkModel()
	
	init(viewController: DetailSearchTopDisplayLogic?, dataSource: DetailSearchTopModel.DataSource) {
		self.dataSource = dataSource
		self.presenter = DetailSearchTopPresenter(viewController)
	}
}


// MARK: - DetailSearchTopBusinessLogic
extension DetailSearchTopInteractor: DetailSearchTopBusinessLogic {
	func setPage(_ data: Int) {
		page = data
	}
	
	func doRequest(_ request: DetailSearchTopModel.Request) {
		DispatchQueue.global(qos: .userInitiated).async {
			
			switch request {
				
			case .searchDetailTop(let isPagination):
				self.searchDetailTop(isPagination)
			}
		}
	}
}


// MARK: - Private Zone
private extension DetailSearchTopInteractor {
	
	func searchDetailTop(_ isPagination: Bool) {
				
		network.searchTopChannel(.searchTop(text: dataSource.text ?? "", page: page))
			.sink(receiveCompletion: { (completion) in
				if case .failure(let error) = completion, let apiError = error as? ErrorMessage {
					print(apiError)
				}
			}) {[weak self] (model: FeedArray) in
				guard let self = self else { return }
				
				if isPagination {
					self.presenter.presentResponse(.paginationChannels(data: model))
				} else {
					self.presenter.presentResponse(.channels(data: model))
				}
		}.store(in: &cancellables)
	}
}
