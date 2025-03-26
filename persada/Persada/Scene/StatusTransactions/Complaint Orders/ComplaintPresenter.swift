//
//  ComplaintPresenter.swift
//  KipasKipas
//
//  Created by NOOR on 01/02/21.
//  Copyright (c) 2021 Koanba. All rights reserved.
//

import Foundation

protocol ComplaintPresentationLogic {
	func presentResponse(_ response: ComplaintModel.Response)
}

final class ComplaintPresenter: Presentable {
	private weak var viewController: ComplaintDisplayLogic?
	
	init(_ viewController: ComplaintDisplayLogic?) {
		self.viewController = viewController
	}
}


// MARK: - ComplaintPresentationLogic
extension ComplaintPresenter: ComplaintPresentationLogic {
	
	func presentResponse(_ response: ComplaintModel.Response) {
		
		switch response {
			
		case .complaint(let data):
			presentComplaint(data)
		case .media(let result):
			presentingMedia(result)
		}
	}
}


// MARK: - Private Zone
private extension ComplaintPresenter {
	
	func presentComplaint(_ data: DefaultResponse) {
		
		viewController?.displayViewModel(.complaint(viewModel: data))
	}
	
	func presentingMedia(_ result: ResultData<ResponseMedia>) {
		switch result {
		case .failure(let error):
			viewController?.displayViewModel(.error(error))
		case .success(let response):
			viewController?.displayViewModel(.media(viewModel: response))
		}
	}
}
