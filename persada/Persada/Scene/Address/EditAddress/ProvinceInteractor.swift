//
//  ProvinceInteractor.swift
//  MOVANS
//
//  Created by movan on 11/08/20.
//  Copyright (c) 2020 Muhammad Noor. All rights reserved.
//

import Foundation

typealias ProvinceInteractable = ProvinceBusinessLogic & ProvinceDataStore

protocol ProvinceBusinessLogic {
  
  func doRequest(_ request: ProvinceModel.Request)
}

protocol ProvinceDataStore {
  var dataSource: ProvinceModel.DataSource { get }
}

final class ProvinceInteractor: Interactable, ProvinceDataStore {
  
  var dataSource: ProvinceModel.DataSource
  
  private var presenter: ProvincePresentationLogic
  
  init(viewController: ProvinceDisplayLogic?, dataSource: ProvinceModel.DataSource) {
    self.dataSource = dataSource
    self.presenter = ProvincePresenter(viewController)
  }
}


// MARK: - ProvinceBusinessLogic
extension ProvinceInteractor: ProvinceBusinessLogic {
  
  func doRequest(_ request: ProvinceModel.Request) {
    DispatchQueue.global(qos: .userInitiated).async {
      
      switch request {
        
      case .doSomething(let item):
        self.doSomething(item)
      }
    }
  }
}


// MARK: - Private Zone
private extension ProvinceInteractor {
  
  func doSomething(_ item: Int) {
    
    //construct the Service right before using it
    //let serviceX = factory.makeXService()
    
    // get new data async or sync
    //let newData = serviceX.getNewData()
    
    presenter.presentResponse(.doSomething(newItem: item + 1, isItem: true))
  }
}
