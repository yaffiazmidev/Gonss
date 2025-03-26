//
//  PostPreviewMediaPresenter.swift
//  Persada
//
//  Created by movan on 10/07/20.
//  Copyright (c) 2020 Muhammad Noor. All rights reserved.
//

import Foundation

protocol PostPreviewMediaPresentationLogic {
	func presentResponse(_ response: PostPreviewMediaModel.Response)
}

final class PostPreviewMediaPresenter: Presentable {
	private weak var viewController: PostPreviewMediaDisplayLogic?
	
	init(_ viewController: PostPreviewMediaDisplayLogic?) {
		self.viewController = viewController
	}
}


// MARK: - PostPreviewMediaPresentationLogic
extension PostPreviewMediaPresenter: PostPreviewMediaPresentationLogic {
	
	func presentResponse(_ response: PostPreviewMediaModel.Response) {
		
		switch response {
			
		case .doSomething(let newItem, let isItem):
			presentDoSomething(newItem, isItem)
		}
	}
}


// MARK: - Private Zone
private extension PostPreviewMediaPresenter {
	
	func presentDoSomething(_ newItem: Int, _ isItem: Bool) {
		
		//prepare data for display and send it further
		
		viewController?.displayViewModel(.doSomething(viewModelData: NSObject()))
	}
}
