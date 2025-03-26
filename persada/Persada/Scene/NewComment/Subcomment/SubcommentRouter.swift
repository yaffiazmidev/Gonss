//
//  SubcommentRouter.swift
//  Persada
//
//  Created by NOOR on 25/06/20.
//  Copyright (c) 2020 Muhammad Noor. All rights reserved.

import UIKit

protocol SubcommentRouting {
	
	func routeTo(_ route: SubcommentModel.Route)
}

final class SubcommentRouter: Routeable {
	
	private weak var viewController: UIViewController?
	
	init(_ viewController: UIViewController?) {
		self.viewController = viewController
	}
}


// MARK: - SubcommentRouting
extension SubcommentRouter: SubcommentRouting {
	
	func routeTo(_ route: SubcommentModel.Route) {
		DispatchQueue.main.async {
			switch route {

			case .dismissSubcomment:
				self.dismissSubcomment()
			}
		}
	}
}


// MARK: - Private Zone
private extension SubcommentRouter {
	
	func dismissSubcomment() {
		viewController?.navigationController?.popViewController(animated: true)
	}

}
