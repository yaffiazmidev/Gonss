//
//  ChannelSearchContentPresenter.swift
//  KipasKipas
//
//  Created by movan on 05/08/20.
//  Copyright (c) 2020 Muhammad Noor. All rights reserved.
//

import Foundation

protocol ChannelSearchContentPresentationLogic {
	func presentResponse(_ response: ChannelSearchContentModel.Response)
}

final class ChannelSearchContentPresenter: Presentable {
	private weak var viewController: ChannelSearchContentDisplayLogic?
	
	init(_ viewController: ChannelSearchContentDisplayLogic?) {
		self.viewController = viewController
	}
}


// MARK: - ChannelSearchContentPresentationLogic
extension ChannelSearchContentPresenter: ChannelSearchContentPresentationLogic {
	
	func presentResponse(_ response: ChannelSearchContentModel.Response) {
		
		switch response {
			
		case .channelList(let data):
			self.presentDoSearchChannel(data)
            
        case .statusFollow(let data):
            self.presentStatusFollow(data)
		}
	}
}


// MARK: - Private Zone
private extension ChannelSearchContentPresenter {
	
	func presentDoSearchChannel(_ value: ChannelsAccount) {
		
		guard let validData = value.data else {
			return
		}
		
		viewController?.displayViewModel(.channelList(viewModel: validData))
	}
    
    func presentStatusFollow(_ result: DefaultResponse) {
        
        viewController?.displayViewModel(.statusFollow(viewModel: result))
    }
}
