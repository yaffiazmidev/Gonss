//
//  NotificationSocialRouter.swift
//  KipasKipas
//
//  Created by movan on 13/08/20.
//  Copyright (c) 2020 Muhammad Noor. All rights reserved.
//

import UIKit

final class NotificationSocialRouter: Routeable {
	
	private weak var viewController: UIViewController?
	
	init(_ viewController: UIViewController?) {
		self.viewController = viewController
	}
}

// MARK: - Private Zone
extension NotificationSocialRouter {
	
	func dismissNotificationSocialScene() {
		viewController?.dismiss(animated: true)
	}
	
    func showComment(_ feeds: [Feed]?) {
        let hasDeleted = feeds == nil
        let vc = FeedFactory.createFeedController(feed: feeds ?? [], hasDeleted: hasDeleted, displaySingle: true, type: .notif, showBottomCommentSectionView: true, isHome: false)
        DispatchQueue.main.async {
            vc.bindNavigationBar(hasDeleted ? "Postingan" : "", true, icon: .get(.arrowLeftWhite))
            self.viewController?.navigationController?.displayShadowToNavBar(status: false)
            self.viewController?.navigationController?.setNavigationBarHidden(false, animated: true)
            vc.hidesBottomBarWhenPushed = true
            self.navigateOnce(vc)
        }
    }
    
	func showSubcomment(_ id: String) {
		let dataSource = SubcommentModel.DataSource()
		dataSource.id = id
		
        DispatchQueue.main.async {
            let controller = SubcommentController(mainView: SubcommentView(), dataSource: dataSource, fromNotif: true)
            controller.bindNavigationBar(.get(.commenter))
            controller.hidesBottomBarWhenPushed = true
            self.navigateOnce(controller)
        }
	}
	
	func showFollow(_ id: String) {
        DispatchQueue.main.async {
            let vc = ProfileRouter.create(userId: id)
            vc.bindNavigationBar("", icon: "ic_chevron_left_outline_black", customSize: .init(width: 20, height: 14), contentHorizontalAlignment: .fill, contentVerticalAlignment: .fill)
            vc.hidesBottomBarWhenPushed = true
            self.navigateOnce(vc)
        }
	}
    
    func showProducts() {
        DispatchQueue.main.async {
            let products = ProductController(mainView: ProductView(), dataSource: ProductModel.DataSource(id: ""))
            products.hidesBottomBarWhenPushed = true
            self.navigateOnce(products)
        }
        
    }
    
    private func navigateOnce(_ destinationViewController: UIViewController) {
        let controllers = self.viewController?.navigationController?.viewControllers
        
        guard let lastStack = controllers?.last, type(of: lastStack) != type(of: destinationViewController) else {
            return
        }
        
        viewController?.navigationController?.pushViewController(destinationViewController, animated: true)
    }
}
