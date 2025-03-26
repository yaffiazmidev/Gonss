//
//  SplashScreenPresenter.swift
//  KipasKipas
//
//  Created by Yaffi Azmi on 09/11/21.
//

import UIKit

protocol SplashScreenPresenterPresentingLogic {
    func presentHomeFeedFirstPage(_ feed: [Feed]?)
}

class SplashScreenPresenter: SplashScreenPresenterPresentingLogic {
	weak var controller: SplashScreenViewControllerDisplayLogic?
	
	init(controller: SplashScreenViewControllerDisplayLogic) {
		self.controller = controller
	}
    
    func presentHomeFeedFirstPage(_ feed: [Feed]?) {
        controller?.displayFeed(feed ?? [])
    }
}
