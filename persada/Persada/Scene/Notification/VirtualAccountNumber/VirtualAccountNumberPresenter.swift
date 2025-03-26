//
//  VirtualAccountNumberPresenter.swift
//  KipasKipas
//
//  Created by movan on 19/08/20.
//  Copyright (c) 2020 Muhammad Noor. All rights reserved.
//

import Foundation

protocol VirtualAccountNumberPresentationLogic {
	func presentResponse(_ response: VirtualAccountNumberModel.Response)
}

final class VirtualAccountNumberPresenter: Presentable {
	private weak var viewController: VirtualAccountNumberDisplayLogic?
	
	init(_ viewController: VirtualAccountNumberDisplayLogic?) {
		self.viewController = viewController
	}
}


// MARK: - VirtualAccountNumberPresentationLogic
extension VirtualAccountNumberPresenter: VirtualAccountNumberPresentationLogic {
	
	func presentResponse(_ response: VirtualAccountNumberModel.Response) {
		
	
	}
}


// MARK: - Private Zone
private extension VirtualAccountNumberPresenter {

}
