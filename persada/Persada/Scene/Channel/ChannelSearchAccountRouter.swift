//
//  ChannelSearchAccountRouter.swift
//  KipasKipas
//
//  Created by movan on 04/08/20.
//  Copyright (c) 2020 Muhammad Noor. All rights reserved.
//

import UIKit

protocol ChannelSearchAccountRouting {
	
	func routeTo(_ route: ChannelSearchAccountModel.Route)
}

final class ChannelSearchAccountRouter: Routeable {
	
	private weak var viewController: UIViewController?
	
	init(_ viewController: UIViewController?) {
		self.viewController = viewController
	}
}


// MARK: - ChannelSearchAccountRouting
extension ChannelSearchAccountRouter: ChannelSearchAccountRouting {
	
	func routeTo(_ route: ChannelSearchAccountModel.Route) {
		DispatchQueue.main.async {
			switch route {
				
			case .dismissChannelSearchTopScene:
				self.dismissChannelSearchAccountScene()
			case .showProfile(let id):
                KipasKipas.showProfile?(id)
			}
		}
	}
}


// MARK: - Private Zone
private extension ChannelSearchAccountRouter {
	
	func dismissChannelSearchAccountScene() {
		viewController?.navigationController?.popViewController(animated: false)
	}
	
	func showProfile(_ id: String) {
        let vc = ProfileRouter.create(userId: id)
        vc.bindNavigationBar("", icon: "ic_chevron_left_outline_black", customSize: .init(width: 20, height: 14), contentHorizontalAlignment: .fill, contentVerticalAlignment: .fill)
        vc.hidesBottomBarWhenPushed = true
        viewController?.navigationController?.pushViewController(vc, animated: true)
	}
    
    
}
