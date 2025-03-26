//
//  FollowingsRouter.swift
//  KipasKipas
//
//  Created by movan on 31/08/20.
//  Copyright (c) 2020 Muhammad Noor. All rights reserved.
//

import UIKit

protocol FollowingsRouting {
	
	func routeTo(_ route: FollowingsModel.Route)
}

final class FollowingsRouter: Routeable {
	
	private weak var viewController: UIViewController?
	
	init(_ viewController: UIViewController?) {
		self.viewController = viewController
	}
}


// MARK: - FollowingsRouting
extension FollowingsRouter: FollowingsRouting {
	
	func routeTo(_ route: FollowingsModel.Route) {
		DispatchQueue.main.async {
			switch route {
				
			case let .dismiss(id, showNavBar):
				self.dismiss(id, showNavBar)
			case .detail(let id):
				self.detailProfile(id)
			}
		}
	}
}


// MARK: - Private Zone
private extension FollowingsRouter {
	
	func dismiss(_ id: String, _ showNavBar: Bool) {
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
