//
//  AppDelegate+Explore.swift
//  KipasKipas
//
//  Created by DENAZMI on 04/07/24.
//  Copyright © 2024 Koanba. All rights reserved.
//

import UIKit
import KipasKipasShared

var showExplore: (() -> Void)?

extension AppDelegate {
    func configureExploreFeature() {
        KipasKipas.showExplore = showExploreController
    }
    
    private func showExploreController() {
        let destination = ExploreViewController()
        destination.hidesBottomBarWhenPushed = true
        destination.configureDismissablePresentation(tintColor: .contentGrey)
        
        let navigationController = UINavigationController(rootViewController: destination)
        presentWithSlideAnimation(navigationController)
    }
}
