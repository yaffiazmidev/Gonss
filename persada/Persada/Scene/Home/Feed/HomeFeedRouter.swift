//
//  NewSelebRouter.swift
//  Persada
//
//  Created by Muhammad Noor on 17/06/20.
//  Copyright (c) 2020 Muhammad Noor. All rights reserved.

import UIKit
import AVKit

protocol NewSelebRouting {
	
	func routeTo(_ route: FeedModel.Route)
}

final class NewSelebRouter: Routeable {
	
	private weak var viewController: UIViewController?
	
	init(_ viewController: UIViewController?) {
		self.viewController = viewController
	}
	

}


// MARK: - NewSelebRouting
extension NewSelebRouter: NewSelebRouting {
	
	func routeTo(_ route: FeedModel.Route) {
		if viewController is HomeFeedViewController {
			let vc = viewController as! HomeFeedViewController
			vc.pausePlayeVideos(pause: true)
		}
		switch route {
		case .selectedComment(let id, let item, let row):
			selectedComment(id, item, row)
		case .showProfile(let id, let type):
			showProfile(id: id, type: type)
		case .detailStory(let id, let accountId, let type, let post, let imageURL, let index, let interactor):
            showStoryDetail(id, accountId, type, post, imageURL, index: index, interactor: interactor)
		case .showNews:
			showNews()
		case .showFollowing:
			showFollowing()
		case .report:
			report()
		case .gallery(let value):
			gallery(value)
		case .shared(let text):
			self.shared(text)
		case .emptyProfile:
			self.emptyProfile()
		case .hashtag(let hashtag):
			self.hashtag(hashtag: hashtag)
		}
	}
	

}


// MARK: - Private Zone
private extension NewSelebRouter {

	func showProfile(id: String, type: String) {
		let controller =  AnotherUserProfileViewController(mainView: AnotherUserProfileView(), dataSource: NewUserProfileModel.DataSource())
		controller.setProfile(id: id, type: type)
		controller.bindNavigationBar("", true)
		
        viewController?.navigationController?.push(controller)
	}

	func selectedComment(_ id: String, _ item: Feed, _ row: Int) {

		
        
        let comment = CommentDataSource(id: id)
        let controller = CommentViewController(commentDataSource: comment)
        controller.bindNavigationBar(.get(.commenter), true)
        controller.hidesBottomBarWhenPushed = true
        
		navigateToComment(source: viewController as! HomeFeedViewController, destination: controller)

	}
	
	func navigateToComment(source: HomeFeedViewController, destination: CommentViewController)
	{
		// Navigate forward (presenting)
		source.navigationController?.pushViewController(destination, animated: true)
	}
	
    func showStoryDetail(_ id: String, _ accountId: String, _ type: String , _ post: [StoriesItem], _ imageURL: String, index: Int, interactor: NewSelebInteractable) {

		let storyDetailController = StoryPreviewController(stories: post, handPickedStoryIndex:  index)
		storyDetailController.modalPresentationStyle = .fullScreen
		storyDetailController.modalTransitionStyle   = .crossDissolve
        storyDetailController.actionRefresh = {
            interactor.doRequest(.story(page: 0))
            interactor.setPage(data: 0)
        }
		
		viewController?.present(storyDetailController, animated: true, completion: nil)
	}
	
	func report() {
		
	}
	
	func gallery(_ interactor: NewSelebInteractable) {
        // Open Camera & upload
//		let controller = VCCamera()
//		controller.actionUploadSuccess = { product, image, data in
//            if let v = self.viewController as? HomeFeedViewController{
//                v.uploadStory(product, image, data)
//            }
//		}
//        controller.modalPresentationStyle = .overFullScreen
//		viewController?.present(controller, animated: true, completion: nil)
	}
	
	func showNews() {
	}
	
	func showFollowing() {
		
	}
	
	func shared(_ text: String) {
		let activityController = UIActivityViewController(activityItems: [text], applicationActivities: nil)
		
		viewController?.present(activityController, animated: true, completion: nil)
	}
	
	func emptyProfile() {
		let controller = EmptyUserProfileViewController()

		viewController?.present(UINavigationController(rootViewController: controller), animated: true, completion: nil)
	}
	
	func hashtag(hashtag: String){
        let hashtagVC = HashtagViewController(hashtag: hashtag)
		hashtagVC.hidesBottomBarWhenPushed = true
		viewController?.navigationController?.pushViewController(hashtagVC, animated: true)
	}

}
