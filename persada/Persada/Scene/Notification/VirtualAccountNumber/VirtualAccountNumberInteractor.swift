//
//  VirtualAccountNumberInteractor.swift
//  KipasKipas
//
//  Created by movan on 19/08/20.
//  Copyright (c) 2020 Muhammad Noor. All rights reserved.
//

import Foundation
import Combine

typealias VirtualAccountNumberInteractable = VirtualAccountNumberBusinessLogic & VirtualAccountNumberDataStore

protocol VirtualAccountNumberBusinessLogic {
	
	func doRequest(_ request: VirtualAccountNumberModel.Request)
}

protocol VirtualAccountNumberDataStore {
	var dataSource: VirtualAccountNumberModel.DataSource { get set }
}

final class VirtualAccountNumberInteractor: Interactable, VirtualAccountNumberDataStore {
	
	var dataSource: VirtualAccountNumberModel.DataSource
	private var subscriptions = Set<AnyCancellable>()
	private var presenter: VirtualAccountNumberPresentationLogic
	
	init(viewController: VirtualAccountNumberDisplayLogic?, dataSource: VirtualAccountNumberModel.DataSource) {
		self.dataSource = dataSource
		self.presenter = VirtualAccountNumberPresenter(viewController)
	}
}


// MARK: - VirtualAccountNumberBusinessLogic
extension VirtualAccountNumberInteractor: VirtualAccountNumberBusinessLogic {
	
	func doRequest(_ request: VirtualAccountNumberModel.Request) {
		DispatchQueue.global(qos: .userInitiated).async {
		}
	}
}


// MARK: - Private Zone
private extension VirtualAccountNumberInteractor {

}
