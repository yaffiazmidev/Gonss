//
//  PostPreviewMediaInteractor.swift
//  Persada
//
//  Created by movan on 10/07/20.
//  Copyright (c) 2020 Muhammad Noor. All rights reserved.
//

import Foundation

typealias PostPreviewMediaInteractable = PostPreviewMediaBusinessLogic & PostPreviewMediaDataStore

protocol PostPreviewMediaBusinessLogic {
	
	func doRequest(_ request: PostPreviewMediaModel.Request)
	func removeMedai(_ index: Int)
}

protocol PostPreviewMediaDataStore {
	var dataSource: PostPreviewMediaModel.DataSource { get }
}

final class PostPreviewMediaInteractor: Interactable, PostPreviewMediaDataStore {
	
	var dataSource: PostPreviewMediaModel.DataSource
	
	private var presenter: PostPreviewMediaPresentationLogic
	
	init(viewController: PostPreviewMediaDisplayLogic?, dataSource: PostPreviewMediaModel.DataSource) {
		self.dataSource = dataSource
		self.presenter = PostPreviewMediaPresenter(viewController)
	}
}


// MARK: - PostPreviewMediaBusinessLogic
extension PostPreviewMediaInteractor: PostPreviewMediaBusinessLogic {
	func removeMedai(_ index: Int) {
		self.dataSource.responseMedias.remove(at: index)
		self.dataSource.itemMedias.remove(at: index)
	}
	
	
	func doRequest(_ request: PostPreviewMediaModel.Request) {
		DispatchQueue.global(qos: .userInitiated).async {
			
			switch request {
				
			case .doSomething(let item):
				self.doSomething(item)
			}
		}
	}
}


// MARK: - Private Zone
private extension PostPreviewMediaInteractor {
	
	func doSomething(_ item: Int) {
		
		presenter.presentResponse(.doSomething(newItem: item + 1, isItem: true))
	}
}
