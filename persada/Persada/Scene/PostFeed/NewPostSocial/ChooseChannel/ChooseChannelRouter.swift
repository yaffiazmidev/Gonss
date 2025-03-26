//
//  ChooseChannelRouter.swift
//  Persada
//
//  Created by movan on 03/07/20.
//  Copyright (c) 2020 Muhammad Noor. All rights reserved.
//

import UIKit

protocol ChooseChannelRouting {
	
	func routeTo(_ route: ChooseChannelModel.Route)
}

final class ChooseChannelRouter: Routeable {
	
	private weak var viewController: UIViewController?
	
	init(_ viewController: UIViewController?) {
		self.viewController = viewController
	}
}


// MARK: - ChooseChannelRouting
extension ChooseChannelRouter: ChooseChannelRouting {
	
	func routeTo(_ route: ChooseChannelModel.Route) {
		DispatchQueue.main.async {
			switch route {
			case .dismiss:
				self.dismiss()
			}
		}
	}
}


// MARK: - Private Zone
private extension ChooseChannelRouter {
	
	func dismiss()
	{
		self.viewController?.navigationController?.popViewController(animated: true)
	}

}
