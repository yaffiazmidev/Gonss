//
//  ChannelContentRouter.swift
//  KipasKipas
//
//  Created by Daniel Partogi on 27/01/21.
//  Copyright © 2021 Koanba. All rights reserved.
//

import UIKit

protocol ChannelContentRouting {

	func routeTo(_ route: ChannelDetailModel.Route)
}

final class ChannelContentRouter: Routeable {

	private weak var viewController: UIViewController?

	init(_ viewController: UIViewController?) {
		self.viewController = viewController
	}
}


// MARK: - ChannelDetailRouting
extension ChannelContentRouter: ChannelContentRouting {

	func routeTo(_ route: ChannelDetailModel.Route) {
		DispatchQueue.main.async {
			switch route {
				case .selectedComment(let id, let item): self.selectedComment(id, item)
				case .shared(let text):
					self.shared(text)
				case .showProfile(let id, let type): self.showProfile(id: id, type: type)
			}
			}
		}
	
}

// MARK: - ROUTER ENUM
extension ChannelContentRouter {
	func selectedComment(_ id: String, _ item: Feed) {
        
        let comment = CommentDataSource(id: id)
        let controller = CommentViewController(commentDataSource: comment)
        controller.bindNavigationBar(.get(.commenter), true)
        controller.hidesBottomBarWhenPushed = true
        

		// Navigate to the destination view controller
		navigateToComment(source: viewController as! ChannelContentsController, destination: controller)

	}

	func navigateToComment(source: ChannelContentsController, destination: CommentViewController)
	{
		// Navigate forward (presenting)
		source.navigationController?.pushViewController(destination, animated: true)
	}

	func shared(_ text: String) {
		let activityController = UIActivityViewController(activityItems: [text], applicationActivities: nil)

		viewController?.present(activityController, animated: true, completion: nil)
	}

	func showProfile(id: String, type: String) {
		let controller =  AnotherUserProfileViewController(mainView: AnotherUserProfileView(), dataSource: NewUserProfileModel.DataSource(id: id, type: type))
		controller.setProfile(id: id, type: type)
        controller.bindNavigationBar("", true)
        
        viewController?.navigationController?.pushViewController(controller, animated: true)
	}
}
