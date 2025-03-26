//
//  ProfileDetailRouter.swift
//  KipasKipas
//
//  Created by Daniel Partogi on 10/02/21.
//  Copyright © 2021 Koanba. All rights reserved.
//

import UIKit


protocol ProfileDetailRouting {

	func routeToComment(_ id: String, _ item: Feed)
	func routeToShare(_ text: String)
	func dismiss(_ id: String, _ showNavBar: Bool)
	func showProfile(id: String, type: String)
	func emptyProfile()
}

final class ProfileDetailRouter: Routeable, ProfileDetailRouting {

	private weak var viewController: UIViewController?

	init(_ viewController: UIViewController?) {
		self.viewController = viewController
	}

	func routeToComment(_ id: String, _ item: Feed) {

//		_ = FeedModel.DataSource()
//		let dataSourceDestination = CommentModel.DataSource()
//		dataSourceDestination.id = id
//		dataSourceDestination.postId = id
//		dataSourceDestination.dataHeader = item
//		dataSourceDestination.headerItems = CommentHeaderCellViewModel(
//			description: item.post?.postDescription ?? "",
//			username: item.account?.username ?? "",
//			imageUrl: item.account?.photo ?? "",
//			date: 0, feed: item)
//
//		let commentController = CommentController(mainView: CommentView(), dataSource: dataSourceDestination)
//		commentController.bindNavigationBar(.get(.commenter))
        
        let comment = CommentDataSource(id: id)
        let controller = CommentViewController(commentDataSource: comment)
        controller.bindNavigationBar(.get(.commenter), true)
        controller.hidesBottomBarWhenPushed = true
		// Navigate to the destination view controller
		navigateToComment(source: viewController as! ProfileDetailViewController, destination: controller)

	}

	func routeToShare(_ text: String) {
		shared(text)
	}
	
	func showProfile(id: String, type: String) {
		let controller =  AnotherUserProfileViewController(mainView: AnotherUserProfileView(), dataSource: NewUserProfileModel.DataSource())
		controller.setProfile(id: id, type: type)
		controller.bindNavigationBar("", true)

        viewController?.navigationController?.pushViewController(controller, animated: true)
	}
	
	func emptyProfile() {
		let controller = EmptyUserProfileViewController()
		controller.bindNavigationBar("", false)
		
		viewController?.present(UINavigationController(rootViewController: controller), animated: true, completion: nil)
	}
	
}


extension ProfileDetailRouter {
	func navigateToComment(source: ProfileDetailViewController, destination: CommentViewController)
	{
		// Navigate forward (presenting)
		source.navigationController?.pushViewController(destination, animated: true)
	}

	func shared(_ text: String) {
		let activityController = UIActivityViewController(activityItems: [text], applicationActivities: nil)

		viewController?.present(activityController, animated: true, completion: nil)
	}
	
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
}
