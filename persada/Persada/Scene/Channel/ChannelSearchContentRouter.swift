//
//  ChannelSearchContentRouter.swift
//  KipasKipas
//
//  Created by movan on 05/08/20.
//  Copyright (c) 2020 Muhammad Noor. All rights reserved.
//

import UIKit
import FeedCleeps

protocol ChannelSearchContentRouting {
	
	func routeTo(_ route: ChannelSearchContentModel.Route)
}

final class ChannelSearchContentRouter: Routeable {
	
	private weak var viewController: UIViewController?
	
	init(_ viewController: UIViewController?) {
		self.viewController = viewController
	}
}


// MARK: - ChannelSearchContentRouting
extension ChannelSearchContentRouter: ChannelSearchContentRouting {
	
	func routeTo(_ route: ChannelSearchContentModel.Route) {
		DispatchQueue.main.async {
			switch route {
				
			case .dismissChannelSearchContentScene:
				self.dismissChannelSearchContentScene()
			case .detailChannel(let id, let name):
				self.detailChannel(id,name)
			}
		}
	}
}


// MARK: - Private Zone
private extension ChannelSearchContentRouter {
	
	func dismissChannelSearchContentScene() {
		viewController?.dismiss(animated: true)
	}
	
	func detailChannel(_ postId: String ,_ name: String) {
        let codeCountry = name.lowercased()
        if codeCountry.contains(CleepsCountry.indo.rawValue) ||
            codeCountry.contains(CleepsCountry.china.rawValue) ||
            codeCountry.contains(CleepsCountry.korea.rawValue) ||
            codeCountry.contains(CleepsCountry.thailand.rawValue) {
            let country: CleepsCountry = codeCountry == CleepsCountry.indo.rawValue ? .indo : codeCountry == CleepsCountry.china.rawValue ? .china : codeCountry == CleepsCountry.korea.rawValue ? .korea : .thailand
            let tiktokController = FeedFactory.createFeedCleepsController(countryCode: country, showBottomCommentSectionView: true, isHome: false)
            viewController?.navigationController?.displayShadowToNavBar(status: false)
            viewController?.navigationController?.pushViewController(tiktokController, animated: true)
            return
        }


		let channelContentsController = ChannelContentsController(name: name, channelId: postId, presenter: ChannelContentPresenter(nil), view: BaseFeedView())
		channelContentsController.bindNavigationBar()
		
		viewController?.navigationController?.pushViewController(channelContentsController, animated: false)
	}
}
