//
//  ProfileMenuInteractor.swift
//  KipasKipas
//
//  Created by Daniel Partogi on 10/08/20.
//  Copyright (c) 2020 Muhammad Noor. All rights reserved.


import Foundation
import KipasKipasCall
import KipasKipasShared

typealias ProfileMenuInteractable = ProfileMenuBusinessLogic & ProfileMenuDataStore

protocol ProfileMenuBusinessLogic {

	func doRequest(_ request: ProfileMenuModel.Request)
    func logoutCallFeature()
}

protocol ProfileMenuDataStore {
	var dataSource: ProfileMenuModel.DataSource { get }
}

final class ProfileMenuInteractor: Interactable, ProfileMenuDataStore {

	var dataSource: ProfileMenuModel.DataSource
	var authNetworkModel: AuthNetworkModel
	var presenter: ProfileMenuPresentationLogic
    
    private(set) lazy var callAuthenticator: CallAuthenticator = {
        let auth = TUICallAuthenticator()
        return MainQueueDispatchDecorator(decoratee: auth)
    }()

	init(viewController: ProfileMenuDisplayLogic?, dataSource: ProfileMenuModel.DataSource) {
		self.dataSource = dataSource
		self.authNetworkModel = AuthNetworkModel()
		self.presenter = ProfileMenuPresenter(viewController)
	}
}


// MARK: - ProfileMenuBusinessLogic
extension ProfileMenuInteractor: ProfileMenuBusinessLogic {

	func doRequest(_ request: ProfileMenuModel.Request) {
		DispatchQueue.global(qos: .userInitiated).async {

			switch request {

				case .doSomething(let item):
					self.doSomething(item)
			}
		}
	}
    
    func logoutCallFeature() {
        callAuthenticator.logout { result in
            switch result {
            case .failure(let error):
                print("Call Feature: Failure Logout", error.localizedDescription)
            case .success(_):
                print("Call Feature: Success Logout")
            }
        }
    }
}



// MARK: - Private Zone
private extension ProfileMenuInteractor {

	func doSomething(_ item: Int) {

		//construct the Service right before using it
		//let serviceX = factory.makeXService()

		// get new data async or sync
		//let newData = serviceX.getNewData()

		presenter.presentResponse(.doSomething(newItem: item + 1, isItem: true))
	}
}
