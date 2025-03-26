//
//  SearchNewsPresenter.swift
//  KipasKipas
//
//  Created by movan on 16/12/20.
//  Copyright (c) 2020 Muhammad Noor. All rights reserved.
//

import Foundation

protocol SearchNewsPresentationLogic {
	func presentResponse(_ response: SearchNewsModel.Response)
}

final class SearchNewsPresenter: Presentable {
	private weak var viewController: SearchNewsDisplayLogic?
	
	init(_ viewController: SearchNewsDisplayLogic?) {
		self.viewController = viewController
	}
}


// MARK: - SearchNewsPresentationLogic
extension SearchNewsPresenter: SearchNewsPresentationLogic {
	
	func presentResponse(_ response: SearchNewsModel.Response) {
		
		switch response {
			
		case .searchNews(let result):
			self.presentSearchNews(result)
		}
	}
}


// MARK: - Private Zone
private extension SearchNewsPresenter {
	
	func presentSearchNews(_ result: NewsArray) {
		
		guard let response = result.data?.content else { return }
		
		let validData: [NewsCellViewModel] = response.map { (value) -> NewsCellViewModel in
			return NewsCellViewModel(value: value)!		}
		
		viewController?.displayViewModel(.news(viewModel: validData))
	}
}
