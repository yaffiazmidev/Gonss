//
//  ChannelSearchTopRouter.swift
//  Persada
//
//  Created by NOOR on 24/06/20.
//  Copyright (c) 2020 Muhammad Noor. All rights reserved.

import UIKit

protocol ChannelSearchTopRouting {
	
	func routeTo(_ route: ChannelSearchTopModel.Route)
}

final class ChannelSearchTopRouter: Routeable {
	
	private weak var viewController: UIViewController?
	
	init(_ viewController: UIViewController?) {
		self.viewController = viewController
	}
}


// MARK: - ChannelSearchTopRouting
extension ChannelSearchTopRouter: ChannelSearchTopRouting {
	
	func routeTo(_ route: ChannelSearchTopModel.Route) {
		DispatchQueue.main.async {
			switch route {
				
			case .dismissChannelSearchTopScene:
				self.dismissChannelSearchTopScene()
            case .showFeed(let index, let feeds, let requestedPage, let searchText, let onClickLike):
                self.showFeed(index: index, feeds: feeds, requestedPage: requestedPage, searchText: searchText, onClickLike: onClickLike)
            case .showProfile(let id, let isSeleb):
                KipasKipas.showProfile?(id)
            }
		}
	}
}


// MARK: - Private Zone
private extension ChannelSearchTopRouter {
	
	func dismissChannelSearchTopScene() {
		viewController?.dismiss(animated: true)
	}
    
    func showFeed(index: Int, feeds: [Feed], requestedPage: Int, searchText: String, onClickLike: ((Feed) -> Void)?) {
        let vc = FeedFactory.createFeedSearchController(feed: [], showBottomCommentSectionView: true,requestedPage: requestedPage, searchText: searchText, onClickLike: onClickLike)
        feeds.forEach { kipasFeed in
            let feed = FeedItemMapper.map(feed: kipasFeed)
            vc.setupItems(feed: feed)
        }
        vc.bindNavigationBar("", true, icon: .get(.arrowLeftWhite))
        vc.hidesBottomBarWhenPushed = true
        vc.showFromStartIndex(startIndex: index)
        viewController?.navigationController?.displayShadowToNavBar(status: false)
        viewController?.navigationController?.pushViewController(vc, animated: false)
    }
    
    func showProfile(_ id: String, isSeleb: Bool) {
        let vc = ProfileRouter.create(userId: id)
        vc.bindNavigationBar("", icon: "ic_chevron_left_outline_black", customSize: .init(width: 20, height: 14), contentHorizontalAlignment: .fill, contentVerticalAlignment: .fill)
        viewController?.navigationController?.pushViewController(vc, animated: true)
    }
}
