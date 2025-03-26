//
//  TermAndConditionInteractor.swift
//  KipasKipas
//
//  Created by Daniel Partogi on 11/08/20.
//  Copyright (c) 2020 Muhammad Noor. All rights reserved.


import Foundation

typealias TermAndConditionInteractable = TermAndConditionBusinessLogic & TermAndConditionDataStore

protocol TermAndConditionBusinessLogic {
    
    func doRequest(_ request: TermAndConditionModel.Request)
}

protocol TermAndConditionDataStore {
    var dataSource: TermAndConditionModel.DataSource { get }
}

final class TermAndConditionInteractor: Interactable, TermAndConditionDataStore {
    
    var dataSource: TermAndConditionModel.DataSource
    
    var presenter: TermAndConditionPresentationLogic
    
    init(viewController: TermAndConditionDisplayLogic?, dataSource: TermAndConditionModel.DataSource) {
        self.dataSource = dataSource
        self.presenter = TermAndConditionPresenter(viewController)
    }
}


// MARK: - TermAndConditionBusinessLogic
extension TermAndConditionInteractor: TermAndConditionBusinessLogic {
    
    func doRequest(_ request: TermAndConditionModel.Request) {
        DispatchQueue.global(qos: .userInitiated).async {
            
            switch request {
                
            case .doSomething(let item):
                self.doSomething(item)
            }
        }
    }
}


// MARK: - Private Zone
private extension TermAndConditionInteractor {
    
    func doSomething(_ item: Int) {
        
        //construct the Service right before using it
        //let serviceX = factory.makeXService()
        
        // get new data async or sync
        //let newData = serviceX.getNewData()
        
        presenter.presentResponse(.doSomething(newItem: item + 1, isItem: true))
    }
}
