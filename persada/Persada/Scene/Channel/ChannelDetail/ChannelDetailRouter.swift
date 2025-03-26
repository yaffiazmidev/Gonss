//
//  ChannelDetailRouter.swift
//  KipasKipas
//
//  Created by Daniel Partogi on 31/08/20.
//  Copyright (c) 2020 Muhammad Noor. All rights reserved.

import UIKit

protocol ChannelDetailRouting {
  
  func routeTo(_ route: ChannelDetailModel.Route)
}

final class ChannelDetailRouter: Routeable {
  
  private weak var viewController: UIViewController?
  
  init(_ viewController: UIViewController?) {
    self.viewController = viewController
  }
}


// MARK: - ChannelDetailRouting
extension ChannelDetailRouter: ChannelDetailRouting {
  
  func routeTo(_ route: ChannelDetailModel.Route) {
    DispatchQueue.main.async {
    }
  }
}


// MARK: - Private Zone
private extension ChannelDetailRouter {
  
  func dismissChannelDetailScene() {
    viewController?.dismiss(animated: true)
  }
  
  func showXSceneBy(_ data: Int) {
    print("will show the next screen")
  }
}
