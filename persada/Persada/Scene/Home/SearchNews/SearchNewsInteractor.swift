//
//  SearchNewsInteractor.swift
//  KipasKipas
//
//  Created by movan on 16/12/20.
//  Copyright (c) 2020 Muhammad Noor. All rights reserved.
//

import Foundation
import Combine

typealias SearchNewsInteractable = SearchNewsBusinessLogic & SearchNewsDataStore

protocol SearchNewsBusinessLogic {
	
	func doRequest(_ request: SearchNewsModel.Request)
}

protocol SearchNewsDataStore {
	var dataSource: SearchNewsModel.DataSource { get set }
}

final class SearchNewsInteractor: Interactable, SearchNewsDataStore {
	
	var dataSource: SearchNewsModel.DataSource
	private var subscriptions: Set<AnyCancellable> = []
	private var presenter: SearchNewsPresentationLogic
	private let network: NewsNetworkModel = NewsNetworkModel()
	
	init(viewController: SearchNewsDisplayLogic?, dataSource: SearchNewsModel.DataSource) {
		self.dataSource = dataSource
		self.presenter = SearchNewsPresenter(viewController)
	}
}


// MARK: - SearchNewsBusinessLogic
extension SearchNewsInteractor: SearchNewsBusinessLogic {
	
	func doRequest(_ request: SearchNewsModel.Request) {
		DispatchQueue.global(qos: .userInitiated).async {
			
			switch request {
				
			case .searchNews(let text, let page):
				self.searchNews(text, page: page)
			case .searchNewsPaging(let text, let page):
				self.searchNewsPaging(text, page: page)
			}
		}
	}
}


// MARK: - Private Zone
private extension SearchNewsInteractor {
	
	func searchNews(_ text: String, page: Int) {
		if AUTH.isLogin() {
			network.requestSearchNews(request: .searchNews(title: text, page: page))
				.sink { (completion) in
					switch completion {
					case .failure(let error): print(error.localizedDescription)
					case .finished: break
					}
				} receiveValue: { (model: NewsArray) in
					
					guard let validData = model.data?.content else { return }
					
					let data = validData.compactMap {
						return NewsCellViewModel(value: $0)
					}
					self.dataSource.data.removeAll()
					self.dataSource.data.append(contentsOf: data)
					
					self.presenter.presentResponse(.searchNews(model))
			}.store(in: &subscriptions)
		} else {
			network.requestSearchNews(request: .searchNewsPublic(title: text, page: page))
				.sink { (completion) in
					switch completion {
					case .failure(let error): print(error.localizedDescription)
					case .finished: break
					}
				} receiveValue: { (model: NewsArray) in
					
					guard let validData = model.data?.content else { return }
					
					let data = validData.compactMap {
						return NewsCellViewModel(value: $0)
					}
					self.dataSource.data.removeAll()
					self.dataSource.data.append(contentsOf: data)
					
					self.presenter.presentResponse(.searchNews(model))
			}.store(in: &subscriptions)
		}
		
	}
	
	
	func searchNewsPaging(_ text: String, page: Int) {
		if AUTH.isLogin() {
			network.requestSearchNews(request: .searchNews(title: text, page: page))
				.sink { (completion) in
					switch completion {
					case .failure(let error): print(error.localizedDescription)
					case .finished: break
					}
				} receiveValue: { (model: NewsArray) in
					
					guard let validData = model.data?.content else { return }
					
					let data = validData.compactMap {
						return NewsCellViewModel(value: $0)
					}
					self.dataSource.data.append(contentsOf: data)
					
					self.presenter.presentResponse(.searchNews(model))
			}.store(in: &subscriptions)
		} else {
			network.requestSearchNews(request: .searchNewsPublic(title: text, page: page))
				.sink { (completion) in
					switch completion {
					case .failure(let error): print(error.localizedDescription)
					case .finished: break
					}
				} receiveValue: { (model: NewsArray) in
					
					guard let validData = model.data?.content else { return }
					
					let data = validData.compactMap {
						return NewsCellViewModel(value: $0)
					}
					self.dataSource.data.append(contentsOf: data)
					
					self.presenter.presentResponse(.searchNews(model))
			}.store(in: &subscriptions)
		}
		
	}
}
