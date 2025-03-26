//
//  SearchNewsRouter.swift
//  KipasKipas
//
//  Created by movan on 16/12/20.
//  Copyright (c) 2020 Muhammad Noor. All rights reserved.
//

import UIKit

protocol SearchNewsRouting {
	
	func routeTo(_ route: SearchNewsModel.Route)
}

final class SearchNewsRouter: Routeable {
	
	private weak var viewController: UIViewController?
	
	init(_ viewController: UIViewController?) {
		self.viewController = viewController
	}
}


// MARK: - SearchNewsRouting
extension SearchNewsRouter: SearchNewsRouting {
	
	func routeTo(_ route: SearchNewsModel.Route) {
		DispatchQueue.main.async {
			switch route {
			
			case .dismiss:
				self.dismissSearchNewsScene()
			}
		}
	}
}


// MARK: - Private Zone
private extension SearchNewsRouter {
	
	func dismissSearchNewsScene() {
		viewController?.dismiss(animated: true)
	}
}
