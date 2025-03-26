//
//  ChannelSearchAccountPresenter.swift
//  KipasKipas
//
//  Created by movan on 04/08/20.
//  Copyright (c) 2020 Muhammad Noor. All rights reserved.
//

import Foundation

protocol ChannelSearchAccountPresentationLogic {
	func presentResponse(_ response: ChannelSearchAccountModel.Response)
}

final class ChannelSearchAccountPresenter: Presentable {
	private weak var viewController: ChannelSearchAccountDisplayLogic?
	
	init(_ viewController: ChannelSearchAccountDisplayLogic?) {
		self.viewController = viewController
	}
}


// MARK: - ChannelSearchAccountPresentationLogic
extension ChannelSearchAccountPresenter: ChannelSearchAccountPresentationLogic {
	
	func presentResponse(_ response: ChannelSearchAccountModel.Response) {
		
		switch response {
			
		case .accounts(let data):
            viewController?.displayViewModel(.accounts(viewModel: data.data ?? []))
        case .failedSearchAccounts(let message):
            viewController?.displayViewModel(.failedSeachAccounts(message: message))
		}
	}
}
