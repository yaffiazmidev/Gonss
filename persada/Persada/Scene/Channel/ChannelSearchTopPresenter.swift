//
//  ChannelSearchTopPresenter.swift
//  Persada
//
//  Created by NOOR on 24/06/20.
//  Copyright (c) 2020 Muhammad Noor. All rights reserved.


import Foundation

protocol ChannelSearchTopPresentationLogic {
	func presentResponse(_ response: ChannelSearchTopModel.Response)
    func failedSeachTop(message: String)
}

final class ChannelSearchTopPresenter: Presentable {
	private weak var viewController: ChannelSearchTopDisplayLogic?
	
	init(_ viewController: ChannelSearchTopDisplayLogic?) {
		self.viewController = viewController
	}
}


// MARK: - ChannelSearchTopPresentationLogic
extension ChannelSearchTopPresenter: ChannelSearchTopPresentationLogic {
	
	func presentResponse(_ response: ChannelSearchTopModel.Response) {
		
		switch response {
        case .topAccountResponse(let data):
            self.presentDoTopAccount(data)
		case .topFeedResponse(let data):
			self.presentDoTopFeed(data)
		}
	}
    
    func failedSeachTop(message: String) {
        viewController?.failedSeachTop(message: message)
    }
}


// MARK: - Private Zone
private extension ChannelSearchTopPresenter {
	
	func presentDoTopFeed(_ value: FeedArray) {
		
		guard let validData = value.data?.content else {
			return
		}
		
        viewController?.displayViewModel(.topFeeds(viewModel: validData))
	}
    
    func presentDoTopAccount(_ value: SearchArray) {
        
        guard let validData = value.data else {
            return
        }
        
        viewController?.displayViewModel(.topAccounts(viewModel: validData))
    }

}
