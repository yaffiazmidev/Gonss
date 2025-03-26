//
//  PostRouter.swift
//  Persada
//
//  Created by NOOR on 30/06/20.
//  Copyright (c) 2020 Muhammad Noor. All rights reserved.

import UIKit
import KipasKipasShared

protocol PostRouting {

	func routeTo(_ route: PostModel.Route)
}

final class PostRouter: Routeable {
	
	private weak var viewController: UIViewController?
	
	init(_ viewController: UIViewController?) {
		self.viewController = viewController
	}
}


// MARK: - PostRouting
extension PostRouter: PostRouting {
	
	func routeTo(_ route: PostModel.Route) {
		DispatchQueue.main.async {
			switch route {
			case .chooseChannel:
				self.chooseChannel()
			case .back:
				self.back()
			case .preview(let index, let itemMedias, let responseMedias):
				self.preview(index, itemMedias, responseMedias)
			case .gallery(let index):
				self.gallery(index)
            case .dismiss:
                self.dismiss()
			}
		}
	}
}

protocol ChangeMedia {
	func removeMedia(_ index: Int)
}


// MARK: - Private Zone
private extension PostRouter {
	
	func gallery(_ index: Int) {
		// RnD Gallery
	}

    func preview(_ index: Int, _ itemMedias: [KKMediaItem],_ responseMedias: [ResponseMedia]) {
		let dataSource = PostModel.DataSource()
		var destinationDS = PostPreviewMediaModel.DataSource(itemMedias: itemMedias, responseMedias: responseMedias)
		let mainView = PostPreviewMediaView()
        mainView.index = index
        mainView.firstIndex = index
		let destinationVC = PostPreviewMediaController(mainView: mainView, dataSource: destinationDS)
		viewController!.definesPresentationContext = true
		
		// Pass data to the destination data store
		passDataToPreview(source: dataSource, destination: &destinationDS)
		
		// Navigate to the destination view controller
		navigateToPreview(source: viewController as! PostController, destination: destinationVC)
	}

	func back() {
        self.viewController?.navigationController?.popViewController(animated: true)
	}

    func dismiss() {
        self.viewController?.dismiss(animated: true, completion: nil)
    }

	func chooseChannel() {
		
		let dataSource = PostModel.DataSource()
		var destinationDS = ChooseChannelModel.DataSource()
		
		let destinationVC = ChooseChannelController(mainView: ChooseChannelView(), dataSource: destinationDS)
		viewController!.definesPresentationContext = true
		
		// Pass data to the destination data store
		passDataToChooseChannel(source: dataSource, destination: &destinationDS)
		
		// Navigate to the destination view controller
		navigateToChooseChannel(source: viewController as! PostController, destination: destinationVC)
	}
	
	func passDataToPreview(source: PostModel.DataSource, destination: inout PostPreviewMediaModel.DataSource)
	{
		// Pass data forward
        destination.itemMedias = source.itemMedias ?? []
        destination.responseMedias = source.responseMedias!
	}
	
	func navigateToPreview(source: PostController, destination: PostPreviewMediaController)
	{
        destination.sourceController = source
		// Navigate forward (presenting)
		source.present(destination, animated: false, completion: nil)
	}
	
	func passDataToChooseChannel(source: PostModel.DataSource, destination: inout ChooseChannelModel.DataSource)
	{
		// Pass data forward
		destination.channelName = source.channel?.name ?? ""
	}
	
	func navigateToChooseChannel(source: PostController, destination: ChooseChannelController)
	{
		// Navigate forward (presenting)
		destination.delegate = source
		source.navigationController?.pushViewController(destination, animated: true)
	}
	
}
