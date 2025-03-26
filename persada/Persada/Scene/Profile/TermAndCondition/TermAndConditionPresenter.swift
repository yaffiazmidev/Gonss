//
//  TermAndConditionPresenter.swift
//  KipasKipas
//
//  Created by Daniel Partogi on 11/08/20.
//  Copyright (c) 2020 Muhammad Noor. All rights reserved.


import Foundation

protocol TermAndConditionPresentationLogic {
  func presentResponse(_ response: TermAndConditionModel.Response)
}

final class TermAndConditionPresenter: Presentable {
  private weak var viewController: TermAndConditionDisplayLogic?
  
  init(_ viewController: TermAndConditionDisplayLogic?) {
    self.viewController = viewController
  }
}


// MARK: - TermAndConditionPresentationLogic
extension TermAndConditionPresenter: TermAndConditionPresentationLogic {
  
  func presentResponse(_ response: TermAndConditionModel.Response) {
    
    switch response {
      
    case .doSomething(let newItem, let isItem):
      presentDoSomething(newItem, isItem)
    }
  }
}


// MARK: - Private Zone
private extension TermAndConditionPresenter {
  
  func presentDoSomething(_ newItem: Int, _ isItem: Bool) {
    
    //prepare data for display and send it further
    
    viewController?.displayViewModel(.doSomething(viewModelData: NSObject()))
  }
}
