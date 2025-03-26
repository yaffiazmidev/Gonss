//
//  FollowersRouter.swift
//  KipasKipas
//
//  Created by movan on 31/08/20.
//  Copyright (c) 2020 Muhammad Noor. All rights reserved.
//

import UIKit

protocol FollowersRouting {
	
	func routeTo(_ route: FollowersModel.Route)
}

final class FollowersRouter: Routeable {
	
	private weak var viewController: UIViewController?
	
	init(_ viewController: UIViewController?) {
		self.viewController = viewController
	}
}


// MARK: - FollowersRouting
extension FollowersRouter: FollowersRouting {
	
	func routeTo(_ route: FollowersModel.Route) {
		DispatchQueue.main.async {
			switch route {
				
			case let .dismiss(id, showNavBar):
				self.dismiss(id,showNavBar)
			case .detail(let id):
				self.detailProfile(id)
			}
		}
	}
}


// MARK: - Private Zone
private extension FollowersRouter {
	
	func dismiss(_ id: String, _ showNavBar: Bool = false) {
		if id == getIdUser() && showNavBar {
			viewController?.navigationController?.popViewController(animated: true)
		} else if ( id != getIdUser() && showNavBar ) {
			viewController?.navigationController?.popViewController(animated: true)
		} else {
			viewController?.navigationController?.setNavigationBarHidden(true, animated: false)
			viewController?.navigationController?.popViewController(animated: true)
		}
		
	}
	
	func detailProfile(_ id: String) {
        let vc = ProfileRouter.create(userId: id)
        vc.bindNavigationBar("", icon: "ic_chevron_left_outline_black", customSize: .init(width: 20, height: 14), contentHorizontalAlignment: .fill, contentVerticalAlignment: .fill)
        vc.hidesBottomBarWhenPushed = true
        viewController?.navigationController?.pushViewController(vc, animated: true)
	}
}
