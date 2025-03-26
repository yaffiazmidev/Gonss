//
//  ChannelDetailPresenter.swift
//  KipasKipas
//
//  Created by Daniel Partogi on 31/08/20.
//  Copyright (c) 2020 Muhammad Noor. All rights reserved.


import Foundation

protocol ChannelDetailPresentationLogic {
  func presentResponse(_ response: ChannelDetailModel.Response)
}

final class ChannelDetailPresenter: Presentable {
  private weak var viewController: ChannelDetailDisplayLogic?
  
  init(_ viewController: ChannelDetailDisplayLogic?) {
    self.viewController = viewController
  }
}


// MARK: - ChannelDetailPresentationLogic
extension ChannelDetailPresenter: ChannelDetailPresentationLogic {
  
  func presentResponse(_ response: ChannelDetailModel.Response) {
    
    switch response {
      
    case .doSomething(let newItem, let isItem):
      presentDoSomething(newItem, isItem)
    }
  }
}


// MARK: - Private Zone
private extension ChannelDetailPresenter {
  
  func presentDoSomething(_ newItem: Int, _ isItem: Bool) {
    
    //prepare data for display and send it further
    
    viewController?.displayViewModel(.doSomething(viewModelData: NSObject()))
  }
}
