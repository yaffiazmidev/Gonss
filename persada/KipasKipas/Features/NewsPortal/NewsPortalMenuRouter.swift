//
//  NewsPortalMenuRouter.swift
//  KipasKipas
//
//  Created by Rahmat Trinanda Pramudya Amar on 11/01/24.
//  Copyright © 2024 Koanba. All rights reserved.
//

import UIKit
import FeedCleeps
import KipasKipasShared

protocol NewsPortalMenuRouting {
    func presentPortal(_ url: String)
}

class NewsPortalMenuRouter: NewsPortalMenuRouting {
    let controller: UIViewController!
    
    required init(controller: UIViewController!) {
        self.controller = controller
    }
    
    func presentPortal(_ url: String) {
        //let browserController = FeedCleepOpenBrowserController(url: url)
        let browserController = FeedCleepOpenBrowserController(url: url, isFullScreen: true, showAction: true)
        browserController.bindNavigationRightBar("", false, icon: .get(.iconClose))
        
        let navigate = UINavigationController(rootViewController: browserController)
        controller.present(navigate, animated: true)
    }
}

extension NewsPortalMenuRouter {
    static func create(showTitle: Bool = true) -> NewsPortalMenuController {
        let url = URL(string: "https://tools.kipaskipas.com/api/v1")!
        let client = HTTPClientFactory.makeHTTPClient()
        let remote = RemoteNewsPortalLoader(url: url, client: client)
        let loader = NewsPortalLoaderFallbackComposite(fallback: remote)
        let controller = NewsPortalMenuController(loader: MainQueueDispatchDecorator(decoratee: loader))
        controller.router = NewsPortalMenuRouter(controller: controller)
        controller.showTitle = showTitle
        
        return controller
    }
}
