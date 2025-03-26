//
//  CommentRouter.swift
//  Persada
//
//  Created by NOOR on 25/06/20.
//  Copyright (c) 2020 Muhammad Noor. All rights reserved.

import UIKit

protocol CommentRouting {
	
	func routeTo(_ route: CommentModel.Route)
}

final class CommentRouter: Routeable {
	
	private weak var viewController: UIViewController?
	
	init(_ viewController: UIViewController?) {
		self.viewController = viewController
	}
}


// MARK: - CommentRouting
extension CommentRouter: CommentRouting {
	
	func routeTo(_ route: CommentModel.Route) {
		DispatchQueue.main.async {
			switch route {

			case .dismissComment:
				self.dismissCommentScene()
			case .subcomment(let postId, let id, let dataSource):
				self.showSubcomment(postId: postId, commentId: id, dataStore: dataSource)
			case .showProfile(let word, let type):
				self.showProfile(word, type)
			case .shared(let text):
				self.shared(text)
			case .hashtag(let text):
				self.hashtag(hashtag: text)
			}
		}
	}
}


// MARK: - Private Zone
private extension CommentRouter {
	
	func dismissCommentScene() {
		viewController?.navigationController?.popViewController(animated: true)
	}
	
	func showProfile(_ id: String,_ type: String) {
		let controller =  AnotherUserProfileViewController(mainView: AnotherUserProfileView(), dataSource: NewUserProfileModel.DataSource(id: id, type: type))
		controller.setProfile(id: id, type: type)
		controller.bindNavigationBar("", true)
		
        viewController?.navigationController?.push(controller)
	}
	
	func showSubcomment(postId: String, commentId: String, dataStore: CommentHeaderCellViewModel) {

		let dataSourceDestination = SubcommentModel.DataSource()
		dataSourceDestination.headerComment = dataStore
		dataSourceDestination.id = commentId
		dataSourceDestination.feed = dataStore.feed
		dataSourceDestination.postId = postId
		let subcommentController = SubcommentController(mainView: SubcommentView(), dataSource: dataSourceDestination)
		subcommentController.bindNavigationBar(.get(.commenter))
		navigateToComment(source: viewController as! CommentViewController, destination: subcommentController)
	}
	
	func navigateToComment(source: CommentViewController, destination: SubcommentController)
	{
		// Navigate forward (presenting)
//		destination.delegate = source
		source.navigationController?.pushViewController(destination, animated: true)
	}
	
	func shared(_ text: String) {
		let activityController = UIActivityViewController(activityItems: [text], applicationActivities: nil)
		
		viewController?.present(activityController, animated: true, completion: nil)
	}
	
	func hashtag(hashtag: String){
		let hashtagVC = HashtagViewController(hashtag: hashtag)
		hashtagVC.hidesBottomBarWhenPushed = true
		viewController?.navigationController?.pushViewController(hashtagVC, animated: true)
	}
}
