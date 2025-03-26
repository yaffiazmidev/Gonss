//
//  HashtagRouter.swift
//  KipasKipas
//
//  Created by DENAZMI on 19/08/22.
//  Copyright © 2022 Koanba. All rights reserved.
//

import Foundation

protocol IHashtagRouter: AnyObject {
    func navigateToFeedTiktok(hashtag: String, index: Int, feeds: [Feed], requestedPage: Int, totalPage: Int)
}

class HashtagRouter: IHashtagRouter {
    
    let controller: HashtagViewController
    
    init(controller: HashtagViewController) {
        self.controller = controller
    }
    
    func navigateToFeedTiktok(hashtag: String, index: Int, feeds: [Feed], requestedPage: Int, totalPage: Int) {
    }
}

extension HashtagRouter {
    static func configure(_ controller: HashtagViewController) {
        let networkService = DIContainer.shared.apiDataTransferService
        let presenter = HashtagPresenter(controller: controller)
        let interactor = HashtagInteractor(presenter: presenter, network: networkService)
        let router = HashtagRouter(controller: controller)
        
        controller.interactor = interactor
        controller.router = router
        controller.presenter = presenter
        
    }
}
