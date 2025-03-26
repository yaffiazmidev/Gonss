//
//  ChooseChannelPresenter.swift
//  Persada
//
//  Created by movan on 03/07/20.
//  Copyright (c) 2020 Muhammad Noor. All rights reserved.
//

import Foundation

protocol ChooseChannelPresentationLogic {
	func presentResponse(_ response: ChooseChannelModel.Response)
}

final class ChooseChannelPresenter: Presentable {
	private weak var viewController: ChooseChannelDisplayLogic?
	
	init(_ viewController: ChooseChannelDisplayLogic?) {
		self.viewController = viewController
	}
}


// MARK: - ChooseChannelPresentationLogic
extension ChooseChannelPresenter: ChooseChannelPresentationLogic {
	
	func presentResponse(_ response: ChooseChannelModel.Response) {
		
		switch response {
			
		case .channels(let data):
			searchChannel(data)
		}
	}
}


// MARK: - Private Zone
private extension ChooseChannelPresenter {
	
	func searchChannel(_ result: ChannelResult) {
		guard let validData = result.data?.content else { return }
		
		viewController?.displayViewModel(.channels(viewModel: validData))
	}
}
