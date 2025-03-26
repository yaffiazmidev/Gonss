//
//  ProvincePresenter.swift
//  MOVANS
//
//  Created by movan on 11/08/20.
//  Copyright (c) 2020 Muhammad Noor. All rights reserved.
//

import Foundation

protocol ProvincePresentationLogic {
  func presentResponse(_ response: ProvinceModel.Response)
}

final class ProvincePresenter: Presentable {
  private weak var viewController: ProvinceDisplayLogic?
  
  init(_ viewController: ProvinceDisplayLogic?) {
    self.viewController = viewController
  }
}


// MARK: - ProvincePresentationLogic
extension ProvincePresenter: ProvincePresentationLogic {
  
  func presentResponse(_ response: ProvinceModel.Response) {
    
    switch response {
      
    case .doSomething(let newItem, let isItem):
      presentDoSomething(newItem, isItem)
    }
  }
}


// MARK: - Private Zone
private extension ProvincePresenter {
  
  func presentDoSomething(_ newItem: Int, _ isItem: Bool) {
    
    //prepare data for display and send it further
    
    viewController?.displayViewModel(.doSomething(viewModelData: NSObject()))
  }
}
