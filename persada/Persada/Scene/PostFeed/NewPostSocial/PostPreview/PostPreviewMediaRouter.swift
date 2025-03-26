//
//  PostPreviewMediaRouter.swift
//  Persada
//
//  Created by movan on 10/07/20.
//  Copyright (c) 2020 Muhammad Noor. All rights reserved.
//

import UIKit

protocol PostPreviewMediaRouting {
	
	func routeTo(_ route: PostPreviewMediaModel.Route)
}

final class PostPreviewMediaRouter: Routeable {
	
	private weak var viewController: UIViewController?
	
	init(_ viewController: UIViewController?) {
		self.viewController = viewController
	}
}


// MARK: - PostPreviewMediaRouting
extension PostPreviewMediaRouter: PostPreviewMediaRouting {
	
	
	func routeTo(_ route: PostPreviewMediaModel.Route) {
		DispatchQueue.main.async {
			switch route {
				
			case .dismissPostPreviewMediaScene:
				self.dismissPostPreviewMediaScene()
			case .change(let index):
				self.change(index)
			case .remove(let index):
				self.remove(index)
			}
		}
	}
}


// MARK: - Private Zone
private extension PostPreviewMediaRouter {
	
	func dismissPostPreviewMediaScene() {
        viewController?.dismiss(animated: true, completion: nil)
	}
	
	func remove(_ index: Int) {
		// Get the destination view controller and data store
		let source = viewController as! PostPreviewMediaController
		source.removeMedia(index)
        source.dismiss(animated: true, completion: nil)
		guard let destinationVC = viewController?.navigationController?.viewControllers.first as? PostController
        else { return }
		
		destinationVC.removeMedia(index)
		destinationVC.mainView.collectionView.reloadData()
	}
	
	func change(_ index: Int) {
		let dataSource = PostPreviewMediaModel.DataSource()
		// Get the destination view controller and data store
		let destinationVC = viewController?.navigationController?.viewControllers[1] as! PostController
		
		var destinationDS = destinationVC.interactor.dataSource
		
		// Pass data to the destination data store
		changeDataToPost(source: dataSource, destination: &destinationDS)
		
		// Navigate to the destination view controller
		navigateToChangePost(source: viewController! as! PostPreviewMediaController, destination: destinationVC)
	}
	
	func changeDataToPost(source: PostPreviewMediaModel.DataSource, destination: inout PostModel.DataSource)
	{
		destination.responseMedias = source.responseMedias
        destination.itemMedias = source.itemMedias
	}
	
	func navigateToChangePost(source: PostPreviewMediaController, destination: PostController)
	{
//		destination.showPicker()
	}
	
}
