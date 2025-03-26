//
//  ChannelSearchHashtagRouter.swift
//  KipasKipas
//
//  Created by movan on 04/08/20.
//  Copyright (c) 2020 Muhammad Noor. All rights reserved.
//

import UIKit

protocol ChannelSearchHashtagRouting {
    
    func routeTo(_ route: ChannelSearchHashtagModel.Route)
}

final class ChannelSearchHashtagRouter: Routeable {
    
    private weak var viewController: UIViewController?
    
    init(_ viewController: UIViewController?) {
        self.viewController = viewController
    }
}


// MARK: - ChannelSearchHashtagRouting
extension ChannelSearchHashtagRouter: ChannelSearchHashtagRouting {
    
    func routeTo(_ route: ChannelSearchHashtagModel.Route) {
        DispatchQueue.main.async {
            switch route {
                
            case .dismissChannelSearchHashtagScene:
                self.dismissChannelSearchHashtagScene()
            case .showHashtag(let tag):
                self.showHashtag(tag)
            }
        }
    }
}


// MARK: - Private Zone
private extension ChannelSearchHashtagRouter {
    
    func dismissChannelSearchHashtagScene() {
        viewController?.dismiss(animated: true)
    }
    func showHashtag(_ tag: String) {
        let hashtagVC = HashtagViewController(hashtag: tag)
        hashtagVC.hidesBottomBarWhenPushed = true
        viewController?.navigationController?.push(hashtagVC)
    }
}
