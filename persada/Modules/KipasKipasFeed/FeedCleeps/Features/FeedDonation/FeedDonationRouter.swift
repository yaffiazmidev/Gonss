//
//  FeedDonationRouter.swift
//  KipasKipasFeed
//
//  Created by DENAZMI on 11/10/23.
//

import Foundation

protocol IFeedDonationRouter {
	// do someting...
}

class FeedDonationRouter: IFeedDonationRouter {
    weak var controller: FeedDonationViewController?
    
    init(controller: FeedDonationViewController?) {
        self.controller = controller
    }
}

extension FeedDonationRouter {
    static func create() -> FeedDonationViewController {
        let controller = FeedDonationViewController()
        let router = FeedDonationRouter(controller: controller)
        let presenter = FeedDonationPresenter(controller: controller)
        let interactor = FeedDonationInteractor(presenter: presenter)
        
        controller.router = router
        controller.interactor = interactor
        
        return controller
    }
}
