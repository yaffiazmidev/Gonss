//
//  ProfileSettingAccountRouter.swift
//  KipasKipas
//
//  Created by Daniel Partogi on 11/08/20.
//  Copyright (c) 2020 Muhammad Noor. All rights reserved.

import UIKit

protocol ProfileSettingAccountRouting {

	func routeTo(_ route: ProfileSettingAccountModel.Route)
}

final class ProfileSettingAccountRouter: Routeable {

	private weak var viewController: UIViewController?

	init(_ viewController: UIViewController?) {
		self.viewController = viewController
	}
}


// MARK: - ProfileSettingAccountRouting
extension ProfileSettingAccountRouter: ProfileSettingAccountRouting {

	func routeTo(_ route: ProfileSettingAccountModel.Route) {
		DispatchQueue.main.async {
			switch route {

				case .dismissProfileSettingAccountScene:
					self.dismissProfileSettingAccountScene()

				case .xScene(let data):
					self.showXSceneBy(data)
			}
		}
	}
}


// MARK: - Private Zone
private extension ProfileSettingAccountRouter {

	func dismissProfileSettingAccountScene() {
		viewController?.navigationController?.popViewController(animated: true)
	}

	func showXSceneBy(_ data: Int) {
		print("will show the next screen")
	}
}
