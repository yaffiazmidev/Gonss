//
//  ChannelSearchHashtagPresenter.swift
//  KipasKipas
//
//  Created by movan on 04/08/20.
//  Copyright (c) 2020 Muhammad Noor. All rights reserved.
//

import Foundation

protocol ChannelSearchHashtagPresentationLogic {
  func presentResponse(_ response: ChannelSearchHashtagModel.Response)
}

final class ChannelSearchHashtagPresenter: Presentable {
  private weak var viewController: ChannelSearchHashtagDisplayLogic?
  
  init(_ viewController: ChannelSearchHashtagDisplayLogic?) {
    self.viewController = viewController
  }
}


// MARK: - ChannelSearchHashtagPresentationLogic
extension ChannelSearchHashtagPresenter: ChannelSearchHashtagPresentationLogic {
  
  func presentResponse(_ response: ChannelSearchHashtagModel.Response) {
    
    switch response {
      
		case .hashtag(let data):
			self.presentDoHashtagChannel(data)
    case .hashtagError(message: let message):
        viewController?.displayViewModel(.hashtagError(message: message))
    }
  }
}


// MARK: - Private Zone
private extension ChannelSearchHashtagPresenter {
  
  func presentDoHashtagChannel(_ value: HashtagResult) {
      viewController?.displayViewModel(.hashtag(viewModel: value.data ?? []))
	}
}
