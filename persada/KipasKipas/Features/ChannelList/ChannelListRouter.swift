//
//  ChannelListRouter.swift
//  KipasKipas
//
//  Created by DENAZMI on 10/10/22.
//  Copyright © 2022 Koanba. All rights reserved.
//

import Foundation
import KipasKipasShared

protocol IChannelListRouter {
    func navigateToChannelContents(id: String, name: String)
    func showAuthPopUp()
}

class ChannelListRouter: IChannelListRouter {
    weak var controller: ChannelListViewController!
    
    init(_ controller: ChannelListViewController) {
        self.controller = controller
    }
    
    func navigateToChannelContents(id: String, name: String) {
        guard AUTH.isLogin() else {
            showAuthPopUp()
            return
        }
        
        let vc = ChannelContentsViewController(channelId: id)
        vc.bindNavigationBar(name)
        vc.hidesBottomBarWhenPushed = true
        vc.navigationController?.displayShadowToNavBar(status: true)
        controller.navigationController?.pushViewController(vc, animated: true)
    }
    
    func showAuthPopUp() {
        showLogin?()
//        let popup = AuthPopUpViewController(mainView: AuthPopUpView())
//        popup.modalPresentationStyle = .overFullScreen
//        controller.present(popup, animated: false, completion: nil)
//        
//        popup.handleWhenNotLogin = {
//            popup.dismiss(animated: false, completion: nil)
//        }
    }
}

extension ChannelListRouter {
    static func configure(_ controller: ChannelListViewController) {
        let presenter = ChannelListPresenter(controller: controller)
        let router = ChannelListRouter(controller)
        
        let baseURL = URL(string: APIConstants.baseURL)!
        let authClient = HTTPClientFactory.makeAuthHTTPClient()
        let channelsLoader = RemoteChannelsLoader(url: baseURL, client: authClient)
        let channelsFollowingLoader = RemoteChannelsFollowingLoader(url: baseURL, client: authClient)
        
        let interactor = ChannelListInteractor(
            presenter: presenter,
            channelsLoader: MainQueueDispatchDecorator(decoratee: channelsLoader),
            channelsFollowingLoader: MainQueueDispatchDecorator(decoratee: channelsFollowingLoader)
        )
        
        controller.interactor = interactor
        controller.router = router
    }
}
