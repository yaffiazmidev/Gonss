//
//  ProfileFeedRouter.swift
//  KipasKipasFeed
//
//  Created by DENAZMI on 01/11/23.
//

import Foundation
import KipasKipasNetworking

protocol IProfileFeedRouter {
	// do someting...
}

public class ProfileFeedRouter: IProfileFeedRouter {
    weak var controller: ProfileFeedViewController?
    
    public init(controller: ProfileFeedViewController?) {
        self.controller = controller
    }
}

extension ProfileFeedRouter {
    public static func create(feedType: FeedType, baseUrl: String, authToken: String?, userId: String, selectedFeedId: String, page: Int, feeds: [FeedItem]) -> ProfileFeedViewController {
        
        DataCache.instance.write(string: userId, forKey: "USER_LOGIN_ID")
        
        let controller = ProfileFeedViewController(feedType: feedType)
        let router = ProfileFeedRouter(controller: controller)
        let presenter = ProfileFeedPresenter(controller: controller)
        let network = DIContainer.shared.apiAUTHDTS(baseUrl: baseUrl, authToken: authToken)
        let interactor = ProfileFeedInteractor(presenter: presenter, network: network)
        interactor.page = page
        interactor.userId = userId
        interactor.feeds = feeds
        interactor.selectedFeedId = selectedFeedId
        interactor.feedType = feedType
        
        controller.router = router
        controller.interactor = interactor
        return controller
    }
}
