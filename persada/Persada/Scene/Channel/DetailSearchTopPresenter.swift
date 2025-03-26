//
//  DetailSearchTopPresenter.swift
//  KipasKipas
//
//  Created by movan on 04/08/20.
//  Copyright (c) 2020 Muhammad Noor. All rights reserved.
//

import Foundation

protocol DetailSearchTopPresentationLogic {
	func presentResponse(_ response: DetailSearchTopModel.Response)
}

final class DetailSearchTopPresenter: Presentable {
	private weak var viewController: DetailSearchTopDisplayLogic?
	
	init(_ viewController: DetailSearchTopDisplayLogic?) {
		self.viewController = viewController
	}
}


// MARK: - DetailSearchTopPresentationLogic
extension DetailSearchTopPresenter: DetailSearchTopPresentationLogic {
	
	func presentResponse(_ response: DetailSearchTopModel.Response) {
		
		switch response {
			
		case .channels(let data):
			self.presentDoTopChannel(data)
		case .paginationChannels(let data):
			self.presentDoPaginationChannel(data)
		}
	}
}


// MARK: - Private Zone
private extension DetailSearchTopPresenter {
	
	func presentDoTopChannel(_ value: FeedArray) {
		
		guard let validData = value.data?.content else {
			return
		}
		
		viewController?.displayViewModel(.channels(viewModel: validData))
	}
	
	func presentDoPaginationChannel(_ value: FeedArray) {
		
		guard let validData = value.data?.content else {
			return
		}
		
		viewController?.displayViewModel(.paginationChannel(viewModel: validData))
	}
}
