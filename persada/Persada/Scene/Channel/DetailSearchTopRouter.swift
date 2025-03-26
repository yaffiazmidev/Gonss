//
//  DetailSearchTopRouter.swift
//  KipasKipas
//
//  Created by movan on 04/08/20.
//  Copyright (c) 2020 Muhammad Noor. All rights reserved.
//

import UIKit

protocol DetailSearchTopRouting {
	
	func routeTo(_ route: DetailSearchTopModel.Route)
}

final class DetailSearchTopRouter: Routeable {
	
	private weak var viewController: UIViewController?
	
	init(_ viewController: UIViewController?) {
		self.viewController = viewController
	}
}


// MARK: - DetailSearchTopRouting
extension DetailSearchTopRouter: DetailSearchTopRouting {
	
	func routeTo(_ route: DetailSearchTopModel.Route) {
		DispatchQueue.main.async {
			switch route {
				
			case .dismissChannelSearchTopScene:
				self.dismissDetailSearchTopScene()
			}
		}
	}
}


// MARK: - Private Zone
private extension DetailSearchTopRouter {
	
	func dismissDetailSearchTopScene() {
		viewController?.navigationController?.popViewController(animated: false)
	}
}
