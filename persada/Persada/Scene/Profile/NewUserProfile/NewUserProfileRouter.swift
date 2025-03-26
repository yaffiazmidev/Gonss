//
//  NewUserProfileRouter.swift
//  Persada
//
//  Created by monggo pesen 3 on 19/06/20.
//  Copyright (c) 2020 Muhammad Noor. All rights reserved.

import UIKit
import KipasKipasShared

protocol NewUserProfileRouting {

	func routeTo(_ route: NewUserProfileModel.Route)
}

final class NewUserProfileRouter: Routeable {

	private weak var viewController: UIViewController?

	init(_ viewController: UIViewController?) {
		self.viewController = viewController
	}
}


// MARK: - NewUserProfileRouting
extension NewUserProfileRouter: NewUserProfileRouting {

	func routeTo(_ route: NewUserProfileModel.Route) {
		DispatchQueue.main.async{
			switch route {
			case let .profileSetting(id, showNavbar, isVerified, accountType):
                self.showProfileSetting(id: id, showNavbar, isVerified, accountType)
			case let .myShop(id, isVerified):
				self.goToShop(id, isVerified)
			case let .followers(id, showNavbar):
				self.followers(id: id, showNavbar)
			case let .followings(id, showNavbar):
				self.followings(id: id, showNavbar)
			case let .socialMedia(url):
				self.socialMedia(url)
            case let .donationRankAndBadge(accountId):
                showDonationRankAndBadge?(accountId)
            case let .pictureOptions(image, delegate):
                self.showPictureOptions(image: image, delegate: delegate)
            case let .picturePreview(picture):
                self.showPicturePreview(image: picture)
            case let .openCamera(onMediaSelected):
                self.showCamera(onMediaSelected: onMediaSelected)
            case let .openLibrary(delegate):
                self.showLibrary(delegate: delegate)
            case let .cropPicture(item, delegate):
                self.showPictureCropper(with: item, delegate: delegate)
            }
		}
	}
}


// MARK: - Private Zone
private extension NewUserProfileRouter {

	func dismissNewUserProfileScene() {
		viewController?.dismiss(animated: true)
	}

    func showProfileSetting(id: String, _ showNavbar: Bool = false, _ isVerified: Bool, _ accountType: String){
        let presentedViewController = ProfileMenuViewController(mainView: ProfileMenuView(), dataSource: ProfileMenuModel.DataSource(id: id, showNavBar: showNavbar, isVerified: isVerified, accountType: accountType))
		presentedViewController.hidesBottomBarWhenPushed = true
		self.viewController?.navigationController?.pushViewController(presentedViewController, animated: true)
	}

    func goToShop(_ id: String, _ isVerified: Bool) {
		
		if id == getIdUser() {
            let storeController = MyProductFactory.createMyProductController(isVerified)
			storeController.hidesBottomBarWhenPushed = true
			viewController?.navigationController?.pushViewController(storeController, animated: true)
		} else {
            var profile = Profile.emptyObject()
            profile.id = id
            let storeController = AnotherProductFactory.createAnotherProductController(account: profile)
			storeController.hidesBottomBarWhenPushed = true
			viewController?.navigationController?.pushViewController(storeController, animated: false)
		}
	}
	
	func followers(id: String, _ showNavbar: Bool = false) {
		let dataSource = FollowersModel.DataSource()
		dataSource.id = id
		dataSource.showNavBar = showNavbar
		let followers = FollowersController(mainView: FollowersView(), dataSource: dataSource)
        followers.hidesBottomBarWhenPushed = true
		viewController?.navigationController?.pushViewController(followers, animated: false)
	}
	
	func followings(id: String, _ showNavbar: Bool = false) {
		let dataSource = FollowingsModel.DataSource()
		dataSource.id = id
		dataSource.showNavBar = showNavbar
		let followings = FollowingsController(mainView: FollowingsView(), dataSource: dataSource)
        followings.hidesBottomBarWhenPushed = true
		viewController?.navigationController?.pushViewController(followings, animated: false)
	}
    
	func socialMedia(_ url: String) {
		let browserController = AlternativeBrowserController(url: url)
		browserController.bindNavigationBar("", false)
		
		let navigate = UINavigationController(rootViewController: browserController)
		navigate.modalPresentationStyle = .fullScreen
		
		viewController?.present(navigate, animated: false, completion: nil)
	}
    
    func showStoryDetail(_ id: String, _ accountId: String, _ type: String , _ post: [StoriesItem], _ imageURL: String, index: Int, interactor: NewSelebInteractable?) {

        let storyDetailController = StoryPreviewController(stories: post, handPickedStoryIndex:  index)
        storyDetailController.modalPresentationStyle = .fullScreen
        storyDetailController.modalTransitionStyle   = .crossDissolve
//        storyDetailController.actionRefresh = {
//            interactor.doRequest(.story(page: 0))
//            interactor.setPage(data: 0)
//        }
        viewController?.present(storyDetailController, animated: true, completion: nil)
    }
    
    func showPictureOptions(image: UIImage?, delegate: ProfilePictureOptionsDelegate) {
        let options = ProfilePictureOptionsController()
        options.delegate = delegate
        options.image = image
        options.modalPresentationStyle = .overFullScreen
        viewController?.present(options, animated: false)
    }
    
    func showCamera(onMediaSelected: @escaping ((KKMediaItem) -> Void)) {
        let vc = KKCameraViewController(type: .photo, position: .front)
        vc.modalPresentationStyle = .fullScreen
        viewController?.present(vc, animated: true)
        vc.handleMediaSelected = { (result) in
            onMediaSelected(result)
        }
    }
    
    func showLibrary(delegate: KKMediaPickerDelegate) {
        if let controller = viewController {
            let picker = KKMediaPicker()
            picker.delegate = delegate
            picker.types = [.photo]
            picker.show(in: controller)
        }
    }
    
    func showPictureCropper(with item: KKMediaItem, delegate: ProfilePictureCropDelegate) {
        let vc = ProfilePictureCropController(item: item)
        vc.delegate = delegate
        vc.hidesBottomBarWhenPushed = true
        vc.modalPresentationStyle = .fullScreen
        viewController?.present(vc, animated: true)  
    }
    
    func showPicturePreview(image: UIImage?) {
        let options = ProfilePicturePreviewController(image: image)
        options.modalPresentationStyle = .overFullScreen
        viewController?.present(options, animated: false)
    }
}
